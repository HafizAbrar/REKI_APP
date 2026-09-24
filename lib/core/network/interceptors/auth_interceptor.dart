import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/env.dart';

final sessionExpiredStream = StreamController<void>.broadcast();
final tokenRefreshedStream = StreamController<void>.broadcast();

/// All simultaneous 401s await one bounded refresh. Every request settles even
/// when refresh credentials are missing or the refresh response is malformed.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _refreshClient;
  final Dio _retryClient;
  Future<String?>? _refreshing;

  AuthInterceptor(
      {FlutterSecureStorage? storage, Dio? refreshClient, Dio? retryClient})
      : _storage = storage ?? const FlutterSecureStorage(),
        _refreshClient = refreshClient ??
            Dio(BaseOptions(
                baseUrl: Env.apiBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15))),
        _retryClient = retryClient ?? Dio(BaseOptions(baseUrl: Env.apiBaseUrl));

  static const _publicPaths = {
    '/auth/login',
    '/auth/business/login',
    '/auth/business/register',
    '/auth/business/forgot-password',
    '/auth/business/reset-password',
    '/auth/register',
    '/auth/refresh-token',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/google',
    '/auth/apple',
    '/auth/guest',
    '/auth/logout',
  };
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      if (!_publicPaths.contains(options.path)) {
        final token = await _storage.read(key: 'access_token');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (e) {
      handler.reject(DioException(requestOptions: options, error: e));
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        _publicPaths.contains(options.path) ||
        options.extra['_authRetried'] == true ||
        options.data is FormData) {
      handler.next(err);
      return;
    }
    try {
      final current = await _storage.read(key: 'access_token');
      // A late 401 may have used the token which another request just refreshed.
      final token = current != null &&
              options.headers['Authorization'] != 'Bearer $current'
          ? current
          : await (_refreshing ??=
              _refreshTokens().whenComplete(() => _refreshing = null));
      if (token == null) {
        handler.next(err);
        return;
      }
      options.extra['_authRetried'] = true;
      options.headers['Authorization'] = 'Bearer $token';
      final response = await _retryClient.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      // A failed replay/temporary outage must not discard a valid refreshed session.
      handler.next(e.copyWith(requestOptions: options));
    } catch (_) {
      handler.next(err);
    }
  }

  Future<String?> _refreshTokens() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) {
      await _expire();
      return null;
    }
    Response<dynamic> response;
    try {
      response = await _refreshClient.post<dynamic>('/auth/refresh-token',
          data: {'refreshToken': refreshToken});
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 ||
          e.response?.statusCode == 401 ||
          e.response?.statusCode == 403) {
        await _expire(expectedRefresh: refreshToken);
        return null;
      }
      rethrow;
    }
    final body = response.data;
    final token =
        body is Map ? body['access_token'] ?? body['accessToken'] : null;
    if (token is! String || token.isEmpty) {
      await _expire(expectedRefresh: refreshToken);
      return null;
    }
    if (await _storage.read(key: 'refresh_token') != refreshToken) return null;
    await _storage.write(key: 'access_token', value: token);
    final nextRefresh = body['refresh_token'] ?? body['refreshToken'];
    if (nextRefresh is String && nextRefresh.isNotEmpty) {
      await _storage.write(key: 'refresh_token', value: nextRefresh);
    }
    tokenRefreshedStream.add(null);
    return token;
  }

  Future<void> _expire({String? expectedRefresh}) async {
    if (expectedRefresh != null &&
        await _storage.read(key: 'refresh_token') != expectedRefresh) {
      return;
    }
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    sessionExpiredStream.add(null);
  }

  void dispose() {
    _refreshClient.close(force: true);
    _retryClient.close(force: true);
  }
}
