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
    final data = <String, dynamic>{};
    if (updates.containsKey('email')) data['email'] = updates['email'];
    if (updates.containsKey('isActive')) data['isActive'] = updates['isActive'];
    final response = await _dio.patch('/users/$id', data: data);
    return User.fromJson(response.data);
  }

  // DELETE /users/{id} - Delete user
  Future<void> deleteUser(String id) async {
    await _dio.delete('/users/$id');
  }

  // GET /users/preferences - Get current user preferences
  Future<Map<String, dynamic>> getPreferences() async {
    final response = await _dio.get('/users/preferences');
    return response.data as Map<String, dynamic>;
  }

  // POST /users/preferences - Save user preferences (onboarding)
  Future<Map<String, dynamic>> savePreferences(Map<String, dynamic> preferences) async {
    final response = await _dio.post('/users/preferences', data: preferences);
    return response.data as Map<String, dynamic>;
  }

  // PUT /users/preferences - Update user preferences
  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> preferences) async {
    final response = await _dio.put('/users/preferences', data: preferences);
    return response.data as Map<String, dynamic>;
  }

  // GET /users/saved-venues - Get saved venues list
  Future<List<Map<String, dynamic>>> getSavedVenues() async {
    final response = await _dio.get('/users/saved-venues');
    return List<Map<String, dynamic>>.from(response.data);
  }

  // POST /users/saved-venues/{venueId} - Save a venue
  Future<Map<String, dynamic>> saveVenue(String venueId) async {
    final response = await _dio.post('/users/saved-venues/$venueId');
    return response.data as Map<String, dynamic>;
  }

  // DELETE /users/saved-venues/{venueId} - Unsave a venue
  Future<void> unsaveVenue(String venueId) async {
    await _dio.delete('/users/saved-venues/$venueId');
  }

  // GET /users/redemptions - Get redemption history
  Future<List<Map<String, dynamic>>> getRedemptions() async {
    final response = await _dio.get('/users/redemptions');
    return List<Map<String, dynamic>>.from(response.data);
  }
}
