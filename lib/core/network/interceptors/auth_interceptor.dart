import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/env.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.path.contains('/auth/login') || 
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh') ||
        options.path.contains('/auth/forgot-password') ||
        options.path.contains('/auth/reset-password')) {
      handler.next(options);
      return;
    }
    
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        try {
          final dio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));
          final response = await dio.post('/auth/refresh', data: {'refresh_token': refreshToken});
          
          final newAccessToken = response.data['accessToken'];
          await _storage.write(key: 'access_token', value: newAccessToken);
          
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          
          final retryResponse = await dio.fetch(requestOptions);
          handler.resolve(retryResponse);
          return;
        } catch (e) {
          await _storage.delete(key: 'access_token');
          await _storage.delete(key: 'refresh_token');
        }
      }
    }
    handler.next(err);
  }
}