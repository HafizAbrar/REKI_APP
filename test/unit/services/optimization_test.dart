import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reki_mvp/core/models/city.dart';
import 'package:reki_mvp/core/network/interceptors/auth_interceptor.dart';
import 'package:reki_mvp/core/network/interceptors/city_interceptor.dart';
import 'package:reki_mvp/core/network/offer_api_service.dart';
import 'package:reki_mvp/core/utils/async_ttl_cache.dart';

class Adapter implements HttpClientAdapter {
  final FutureOr<ResponseBody> Function(RequestOptions) respond;
  Adapter(this.respond);
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
          Future<void>? cancelFuture) async =>
      respond(options);
  @override
  void close({bool force = false}) {}
}

ResponseBody body(Object data, [int status = 200]) =>
    ResponseBody.fromString(jsonEncode(data), status, headers: {
      Headers.contentTypeHeader: ['application/json']
    });
Dio client(FutureOr<ResponseBody> Function(RequestOptions) respond) =>
    Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = Adapter(respond);
Future<DioException> rejected(Future<Response<dynamic>> request) async {
  try {
    await request;
    fail('Expected rejection');
  } on DioException catch (e) {
    return e;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('cache coalesces simultaneous loads and expires at TTL', () async {
    var now = DateTime.utc(2026);
    final cache = AsyncTtlCache<String, int>(
        ttl: const Duration(seconds: 10), now: () => now);
    final completion = Completer<int>();
    var loads = 0;
    Future<int> load() {
      loads++;
      return completion.future;
    }

    final a = cache.get('a', load);
    final b = cache.get('a', load);
    completion.complete(7);
    expect(await Future.wait([a, b]), [7, 7]);
    expect(loads, 1);
    expect(await cache.get('a', () async => 9), 7);
    now = now.add(const Duration(seconds: 10));
    expect(await cache.get('a', () async => 9), 9);
  });
  test('cache evicts least recently used metadata and retries failed loads',
      () async {
    final cache = AsyncTtlCache<String, int>(
        ttl: const Duration(minutes: 1), capacity: 2);
    await cache.get('a', () async => 1);
    await cache.get('b', () async => 2);
    await cache.get('a', () async => 99);
    await cache.get('c', () async => 3);
    expect(await cache.get('b', () async => 4), 4);
    await expectLater(
        cache.get('failure', () async => throw StateError('offline')),
        throwsStateError);
    expect(await cache.get('failure', () async => 5), 5);
  });
  test(
      'repeat offers refresh uses metadata cache and at most four detail requests concurrently',
      () async {
    var active = 0;
    var peak = 0;
    var details = 0;
    var requests = 0;
    final dio = client((options) async {
      requests++;
      if (options.path == '/offers') {
        return body({
          'offers': List.generate(
              8,
              (i) => {
                    'id': '$i',
                    'title': 'Offer',
                    'venue': {'id': 'v$i'}
                  })
        });
      }
      details++;
      active++;
      if (active > peak) peak = active;
      await Future<void>.delayed(const Duration(milliseconds: 3));
      active--;
      return body({'city': 'London'});
    });
    dio.interceptors
        .add(CityInterceptor(() async => City.findBySlug('london')));
    final api = OfferApiService(dio);
    expect(await api.getAllOffers(), hasLength(8));
    expect(requests, 9);
    expect(await api.getAllOffers(), hasLength(8));
    expect(requests, 10);
    expect(details, 8);
    expect(peak, lessThanOrEqualTo(4));
  });
  for (final scenario in ['missing', 'malformed', 'unauthorized']) {
    test('all concurrent 401 requests settle when refresh is $scenario',
        () async {
      FlutterSecureStorage.setMockInitialValues({
        'access_token': 'expired',
        if (scenario != 'missing') 'refresh_token': 'refresh'
      });
      var refreshes = 0;
      final refresh = client((_) async {
        refreshes++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return body({}, scenario == 'unauthorized' ? 401 : 200);
      });
      final dio = client((_) => body({}, 401));
      final auth = AuthInterceptor(refreshClient: refresh, retryClient: dio);
      dio.interceptors.add(auth);
      final results = await Future.wait(
              List.generate(4, (i) => rejected(dio.get('/private/$i'))))
          .timeout(const Duration(seconds: 3));
      expect(results, hasLength(4));
      expect(refreshes, scenario == 'missing' ? 0 : 1);
      expect(
          await const FlutterSecureStorage().read(key: 'access_token'), isNull);
      auth.dispose();
    });
  }
  test('concurrent 401s refresh once and replay all requests', () async {
    FlutterSecureStorage.setMockInitialValues(
        {'access_token': 'expired', 'refresh_token': 'refresh'});
    var refreshes = 0;
    final refresh = client((_) async {
      refreshes++;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return body({'accessToken': 'fresh', 'refreshToken': 'next'});
    });
    final dio = client((options) => body(
        {}, options.headers['Authorization'] == 'Bearer fresh' ? 200 : 401));
    final auth = AuthInterceptor(refreshClient: refresh, retryClient: dio);
    dio.interceptors.add(auth);
    final results =
        await Future.wait(List.generate(4, (i) => dio.get('/private/$i')))
            .timeout(const Duration(seconds: 3));
    expect(results.every((r) => r.statusCode == 200), true);
    expect(refreshes, 1);
    auth.dispose();
  });
  test('server outage during refresh preserves stored credentials', () async {
    FlutterSecureStorage.setMockInitialValues(
        {'access_token': 'expired', 'refresh_token': 'refresh'});
    final dio = client((_) => body({}, 401));
    final auth = AuthInterceptor(
        refreshClient: client((_) => body({}, 503)), retryClient: dio);
    dio.interceptors.add(auth);
    await rejected(dio.get('/private'));
    expect(await const FlutterSecureStorage().read(key: 'refresh_token'),
        'refresh');
    auth.dispose();
  });
  test('failed replay does not invalidate a successfully refreshed session',
      () async {
    FlutterSecureStorage.setMockInitialValues(
        {'access_token': 'expired', 'refresh_token': 'refresh'});
    final dio = client((_) => body({}, 401));
    final auth = AuthInterceptor(
        refreshClient: client((_) => body({'accessToken': 'fresh'})),
        retryClient: client((_) => body({}, 503)));
    dio.interceptors.add(auth);
    expect((await rejected(dio.get('/private'))).response?.statusCode, 503);
    expect(
        await const FlutterSecureStorage().read(key: 'access_token'), 'fresh');
    auth.dispose();
  });
}
