import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(ref.read(apiClientProvider));
});

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  // POST /auth/register - Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'fullName': name,
      'phone': phone,
      'role': 'USER',
    });
    return response.data;
  }

  // POST /auth/login - User login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  // POST /auth/refresh - Refresh access token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _dio.post('/auth/refresh', data: {
      'refresh_token': refreshToken,
    });
    return response.data;
  }

  // POST /auth/forgot-password - Request password reset
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _dio.post('/auth/forgot-password', data: {
      'email': email,
    });
    return response.data;
  }

  // POST /auth/reset-password - Reset password
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await _dio.post('/auth/reset-password', data: {
      'token': token,
      'new_password': newPassword,
    });
    return response.data;
  }

  // POST /auth/logout - Logout user
  Future<Map<String, dynamic>> logout() async {
    final response = await _dio.post('/auth/logout');
    return response.data;
  }

  // POST /auth/change-password - Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _dio.post('/auth/change-password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
    return response.data;
  }

  // GET /auth/me - Get current user info
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _dio.get('/auth/me');
    return response.data;
  }
}