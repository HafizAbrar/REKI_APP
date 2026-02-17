import 'package:dio/dio.dart';
import '../models/register_request_dto.dart';
import '../../../../core/config/env.dart';
import '../../../../core/errors/app_exception.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> register(RegisterRequestDto request);
  Future<Map<String, dynamic>> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> register(RegisterRequestDto request) async {
    try {
      final response = await _dio.post(
        '${Env.apiBaseUrl}auth/register',
        data: request.toJson(),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Registration failed';
        throw ValidationException(message);
      } else if (e.response?.statusCode == 409) {
        throw ValidationException('User already exists');
      }
      throw NetworkException('Registration failed');
    }
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '${Env.apiBaseUrl}auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ValidationException('User not registered. Please sign up first.');
      } else if (e.response?.statusCode == 401) {
        throw ValidationException('Invalid email or password');
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Login failed';
        throw ValidationException(message);
      }
      throw NetworkException('Login failed. Please try again.');
    }
  }
}
