import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reki_mvp/core/models/live_info.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:reki_mvp/core/models/city.dart';
import 'package:reki_mvp/core/models/user.dart';
import 'package:reki_mvp/core/models/voucher_scan.dart';
import 'package:reki_mvp/core/network/interceptors/city_interceptor.dart';
import 'package:reki_mvp/core/network/interceptors/retry_interceptor.dart';
import 'package:reki_mvp/core/network/offer_api_service.dart';
import 'package:reki_mvp/core/services/city_api_service.dart';
import 'package:reki_mvp/core/services/city_repository.dart';
import 'package:reki_mvp/core/services/city_selection_service.dart';
import 'package:reki_mvp/core/storage/secure_storage.dart';
import 'package:reki_mvp/core/utils/city_date_format.dart';

class MemoryStorage extends SecureStorage {
  final values = <String, String>{};
  @override
  Future<String?> read({required String key}) async => values[key];
  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }
}

class OfflineCities extends CityApiService {
  @override
  Future<void> setUserCity(String id) async => throw StateError('offline');
  @override
  Future<City?> getCityById(String id) async => throw StateError('offline');
  @override
  Future<City?> detectCityFromLocation(double lat, double lng) async =>
      throw StateError('offline');
}

class StubAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions) respond;
  final requests = <RequestOptions>[];
  StubAdapter(this.respond);
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
      Future<void>? cancelFuture) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody body(Object data, [int status = 200]) =>
    ResponseBody.fromString(jsonEncode(data), status, headers: {
      Headers.contentTypeHeader: ['application/json']
    });
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('live city coordinates and preferences match deployed DTOs', () async {
    FlutterSecureStorage.setMockInitialValues({'access_token': 'test-only'});
    final city = City.fromJson({
      'id': 'uuid',
      'slug': 'manchester',
      'latitude': '53.4808',
      'longitude': '-2.2426',
      'defaultLocale': 'en-GB'
    });
    expect(city.defaultLat, closeTo(53.4808, .00001));
    expect(city.defaultLng, closeTo(-2.2426, .00001));
    expect(city.supportedLanguages, ['en-GB']);
    final adapter = StubAdapter((o) => body(o.path.contains('detect')
        ? {'city': city.toJson(), 'distanceKm': 0}
        : {}));
    final api = CityApiService(dio: Dio()..httpClientAdapter = adapter);
    await api.setUserCity('manchester');
    await api.setUserLocale(language: 'en-GB', timezone: 'Europe/London');
    expect(adapter.requests[0].path, '/users/city');
    expect(adapter.requests[0].data, {'city': 'manchester'});
    expect(adapter.requests[1].data,
        {'locale': 'en-GB', 'timezone': 'Europe/London'});
    expect((await api.detectCityFromLocation(53.4808, -2.2426))?.slug,
        'manchester');
    FlutterSecureStorage.setMockInitialValues({});
  });
  test('signed QR tokens are preserved and use the documented scan field',
      () async {
    const token = 'eyJhbGciOiJIUzI1NiJ9.eyJpZCI6IjEifQ.signature';
    expect(VoucherScan.parse(token), token);
    expect(VoucherScan.parse(jsonEncode({'qrCodeData': token})), token);
    final adapter = StubAdapter((_) => body({'transactionId': 'confirmed'}));
    await OfferApiService(Dio()..httpClientAdapter = adapter)
        .redeemByCode(token, venueId: 'venue');
    expect(adapter.requests.single.data, {'qrCodeData': token});
  });
  test('announcement lists hide expired, future and inactive content', () {
    final now = DateTime.utc(2026, 9, 23, 12);
    final payload = LiveInfo.publishPayload(
        'Live music', 'music', now.add(const Duration(hours: 2)));
    expect(payload.keys.toSet(), {'type', 'title', 'endsAt', 'isActive'});
    final items = LiveInfo.entries([
      payload,
      {...payload, 'isActive': false},
      {...payload, 'endsAt': now.toIso8601String()},
      {
        ...payload,
        'startsAt': now.add(const Duration(hours: 1)).toIso8601String()
      }
    ]);
    expect(items.where((item) => LiveInfo.isVisible(item, now)), hasLength(1));
    expect(LiveInfo.entries([]), isEmpty);
  });

  final manchester = City.findBySlug('manchester')!;
  final london = City.findBySlug('london')!;
  test('city selection survives missing server and restores complete metadata',
      () async {
    final storage = MemoryStorage();
    final service =
        CitySelectionService(CityRepository(OfflineCities()), storage);
    await service.selectCity(london);
    expect((await service.getSelectedCity())?.slug, 'london');
    expect((await service.getSelectedCity())?.timezone, 'Europe/London');
    await service.clearSelectedCity();
    expect(await service.getSelectedCity(), isNull);
  });
  test(
      'inactive cities cannot be selected and distant GPS does not select a city',
      () async {
    final service =
        CitySelectionService(CityRepository(OfflineCities()), MemoryStorage());
    await expectLater(
        service.selectCity(City.findBySlug('dubai')!), throwsStateError);
    expect(await service.detectCity(24.86, 67.01), isNull);
    expect(City.findNearest(25.2048, 55.2708), isNull);
    expect((await service.detectCity(51.5074, -0.1278))?.slug, 'london');
  });
  test('city API accepts bare arrays and wrapped lists', () async {
    for (final payload in [
      [london.toJson()],
      {
        'data': [london.toJson()]
      }
    ]) {
      final dio = Dio()..httpClientAdapter = StubAdapter((_) => body(payload));
      expect(
          (await CityApiService(dio: dio).getCities()).single.slug, 'london');
    }
  });
  test(
      'city interceptor follows selection without scoping business or detail routes',
      () async {
    var city = manchester;
    final adapter = StubAdapter((_) => body({}));
    final dio = Dio()..httpClientAdapter = adapter;
    dio.interceptors.add(CityInterceptor(() async => city));
    await dio.get('/venues');
    city = london;
    await dio.get('/venues/search', queryParameters: {'q': 'music'});
    await dio.get('/business/venues');
    await dio.get('/venues/id');
    expect(adapter.requests[0].queryParameters['city'], 'manchester');
    expect(
        adapter.requests[1].queryParameters, {'q': 'music', 'city': 'london'});
    expect(adapter.requests[2].queryParameters.containsKey('city'), false);
    expect(adapter.requests[3].queryParameters.containsKey('city'), false);
  });
  test('legacy offers without venue city resolve it and exclude other cities',
      () async {
    final dio = Dio()
      ..httpClientAdapter = StubAdapter((o) {
        if (o.path == '/offers') {
          return body({
            'offers': [
              {
                'id': 'a',
                'title': 'Manchester',
                'venue': {'id': 'm'}
              },
              {
                'id': 'b',
                'title': 'London',
                'venue': {'id': 'l'}
              },
            ]
          });
        }
        return body({'city': o.path.endsWith('/m') ? 'Manchester' : 'London'});
      });
    dio.interceptors.add(CityInterceptor(() async => london));
    expect((await OfferApiService(dio).getAllOffers()).map((o) => o.id), ['b']);
  });
  test('redemption sends venue context and never retries a server error',
      () async {
    final adapter = StubAdapter((_) => body({'message': 'Unavailable'}, 503));
    final dio = Dio()..httpClientAdapter = adapter;
    dio.interceptors.add(RetryInterceptor(dio: dio));
    await expectLater(
        OfferApiService(dio).redeemByCode('REKI-123', venueId: 'venue'),
        throwsA(isA<DioException>()));
    expect(
        adapter.requests.single.path, '/worker/venues/venue/redemptions/scan');
    expect(adapter.requests, hasLength(1));
    expect(adapter.requests.single.data, {'voucherCode': 'REKI-123'});
  });
  test('redemption requires an authoritative transaction confirmation',
      () async {
    final dio = Dio()
      ..httpClientAdapter = StubAdapter((_) => body({
            'data': {'transactionId': 'txn-1', 'success': true}
          }));
    expect(
        (await OfferApiService(dio)
            .redeemByCode('REKI-123', venueId: 'venue'))['transactionId'],
        'txn-1');
    dio.httpClientAdapter = StubAdapter((_) => body({'success': false}));
    await expectLater(
        OfferApiService(dio).redeemByCode('REKI-123', venueId: 'venue'),
        throwsStateError);
  });
  test('voucher parser accepts supported payloads and rejects unrelated URLs',
      () {
    expect(VoucherScan.parse(' REKI-123 '), 'REKI-123');
    expect(VoucherScan.parse('reki://redeem/REKI-123'), 'REKI-123');
    expect(VoucherScan.parse('https://reki.uk/redeem/REKI-123'), 'REKI-123');
    expect(VoucherScan.parse('{"voucherCode":"REKI-123"}'), 'REKI-123');
    expect(
        VoucherScan.parse('https://reki.uk/redeem?code=REKI-123'), 'REKI-123');
    for (final value in [
      'https://example.com/REKI-123',
      '{broken',
      '{}',
      '',
      'invalid code'
    ]) {
      expect(VoucherScan.parse(value), isNull);
    }
  });
  test('date conversion respects UK daylight saving and Arabic formatting',
      () async {
    await initializeDateFormatting();
    expect(
        CityDateFormat.inCity(DateTime.utc(2026, 7, 1, 12), london).hour, 13);
    expect(
        CityDateFormat.inCity(DateTime.utc(2026, 1, 1, 12), london).hour, 12);
    expect(CityDateFormat.date(DateTime.utc(2026, 7, 1), london, 'ar'),
        isNotEmpty);
  });
  test('WORKER remains a worker when deserializing session data', () {
    final user = User.fromJson({'id': 'staff', 'role': 'WORKER'});
    expect(user.role, UserRole.WORKER);
    expect(user.type, UserType.business);
  });
}
