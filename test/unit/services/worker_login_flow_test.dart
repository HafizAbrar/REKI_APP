import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reki_mvp/core/models/user.dart';
import 'package:reki_mvp/core/network/auth_api_service.dart';
import 'package:reki_mvp/core/router/role_navigation.dart';
import 'package:reki_mvp/core/services/auth_service.dart';

class StubAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions) respond;
  StubAdapter(this.respond);
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
      Future<void>? cancelFuture) async {
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody body(Object data, [int status = 200]) => ResponseBody.fromString(
      data is String ? data : jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json']
      },
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Dio dio;
  late AuthApiService api;

  setUp(() {
    dio = Dio();
  });

  group('business login response parsing (worker flow)', () {
    test('plain {user, tokens} response is returned as-is', () async {
      dio.httpClientAdapter = StubAdapter((options) => body({
            'user': {'id': 'w1', 'email': 'w@reki.app', 'role': 'WORKER'},
            'tokens': {'accessToken': 'a', 'refreshToken': 'r'},
          }));
      api = AuthApiService(dio);
      final res = await api.businessLogin(email: 'w@reki.app', password: 'x');
      expect(res['user']['role'], 'WORKER');
      expect(res['tokens']['accessToken'], 'a');
    });

    test('data-envelope response is unwrapped', () async {
      dio.httpClientAdapter = StubAdapter((options) => body({
            'data': {
              'user': {'id': 'w1', 'email': 'w@reki.app', 'role': 'WORKER'},
              'tokens': {'accessToken': 'a', 'refreshToken': 'r'},
            },
          }));
      api = AuthApiService(dio);
      final res = await api.businessLogin(email: 'w@reki.app', password: 'x');
      expect(res['user']['role'], 'WORKER');
      expect(res['tokens']['accessToken'], 'a');
    });

    test('getCurrentUser unwraps data envelope', () async {
      dio.httpClientAdapter = StubAdapter((options) => body({
            'data': {'id': 'w1', 'email': 'w@reki.app', 'role': 'worker'},
          }));
      api = AuthApiService(dio);
      final res = await api.getCurrentUser();
      expect(res['role'], 'worker');
    });
  });

  group('worker role routing', () {
    test('WORKER role from business login routes to /worker-home', () {
      final user = User.fromJson({
        'id': 'w1',
        'email': 'w@reki.app',
        'role': 'WORKER',
        'venue': {'id': 'v1', 'name': 'Test Venue'},
      });
      expect(user.role, UserRole.WORKER);
      expect(user.type, UserType.business);
      expect(user.venueId, 'v1');
      expect(roleHome(user.role), '/worker-home');
    });

    test('lowercase role parses case-insensitively', () {
      final user = User.fromJson({'id': 'w1', 'email': 'w', 'role': 'worker'});
      expect(user.role, UserRole.WORKER);
      expect(roleHome(user.role), '/worker-home');
    });

    test('missing role defaults to USER home, never business dashboard', () {
      final user = User.fromJson({'id': 'u1', 'email': 'u@reki.app'});
      expect(user.role, UserRole.USER);
      expect(roleHome(user.role), '/home');
    });

    test('BUSINESS role routes to business dashboard', () {
      final user =
          User.fromJson({'id': 'b1', 'email': 'b', 'role': 'BUSINESS'});
      expect(roleHome(user.role), '/business-dashboard');
    });

    test('STAFF role maps to WORKER', () {
      final user = User.fromJson({
        'id': 'w1',
        'role': 'BUSINESS',
        'businessUser': {'staff_role': 'STAFF'},
      });
      expect(user.role, UserRole.WORKER);
      expect(roleHome(user.role), '/worker-home');
    });

    test('staff JWT wins when profile only exposes BUSINESS', () {
      final payload = base64Url
          .encode(utf8.encode(jsonEncode({
            'sub': 'w1',
            'role': 'STAFF',
          })))
          .replaceAll('=', '');
      final user = User.fromJson(
        {'id': 'w1', 'role': 'BUSINESS'},
        accessToken: 'header.$payload.signature',
      );
      expect(user.role, UserRole.WORKER);
      expect(roleHome(user.role), '/worker-home');
    });

    test('login identity is preserved when auth profile is generic BUSINESS',
        () async {
      FlutterSecureStorage.setMockInitialValues({});
      dio.httpClientAdapter = StubAdapter((options) => body({
            'id': 'w1',
            'email': 'staff@example.test',
            'role': 'BUSINESS',
          }));
      final service = AuthService(apiService: AuthApiService(dio));
      await service.clearSession();
      await service.setAccessToken('not-a-jwt');
      final user = await service.fetchCurrentUser(loginUser: {
        'id': 'w1',
        'email': 'staff@example.test',
        'role': 'STAFF',
      });
      expect(user?.role, UserRole.WORKER);
      expect(roleHome(user!.role), '/worker-home');
      await service.clearSession();
    });
  });
}
