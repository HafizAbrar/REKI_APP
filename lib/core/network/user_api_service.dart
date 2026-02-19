import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import 'api_client.dart';

final userApiServiceProvider = Provider<UserApiService>((ref) {
  return UserApiService(ref.read(apiClientProvider));
});

class UserApiService {
  final Dio _dio;

  UserApiService(this._dio);

  // GET /users - Get all users
  Future<List<User>> getAllUsers() async {
    final response = await _dio.get('/users');
    return (response.data as List).map((json) => User.fromJson(json)).toList();
  }

  // GET /users/{id} - Get user by ID
  Future<User> getUserById(String id) async {
    final path = id == 'current' ? '/users/me' : '/users/$id';
    final response = await _dio.get(path);
    return User.fromJson(response.data);
  }

  // PATCH /users/{id} - Update user
  Future<User> updateUser(String id, Map<String, dynamic> updates) async {
    final response = await _dio.patch('/users/$id', data: updates);
    return User.fromJson(response.data);
  }

  // DELETE /users/{id} - Delete user
  Future<void> deleteUser(String id) async {
    await _dio.delete('/users/$id');
  }

  // PATCH /users/preferences - Update user preferences
  Future<User> updatePreferences(Map<String, dynamic> preferences) async {
    final response = await _dio.patch('/users/preferences', data: preferences);
    return User.fromJson(response.data);
  }
}
