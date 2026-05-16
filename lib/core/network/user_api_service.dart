import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/notification_preferences.dart';
import 'api_client.dart';

final userApiServiceProvider = Provider<UserApiService>((ref) {
  return UserApiService(ref.read(apiClientProvider));
});

class UserApiService {
  final Dio _dio;

  UserApiService(this._dio);

  // GET /users
  Future<List<User>> getAllUsers() async {
    final response = await _dio.get('/users');
    return (response.data as List).map((json) => User.fromJson(json)).toList();
  }

  // GET /users/{id}
  Future<User> getUserById(String id) async {
    final path = id == 'current' ? '/users/me' : '/users/$id';
    final response = await _dio.get(path);
    return User.fromJson(response.data);
  }

  // PATCH /users/{id}
  Future<User> updateUser(String id, Map<String, dynamic> updates) async {
    final data = <String, dynamic>{};
    if (updates.containsKey('email')) data['email'] = updates['email'];
    if (updates.containsKey('isActive')) data['isActive'] = updates['isActive'];
    final response = await _dio.patch('/users/$id', data: data);
    return User.fromJson(response.data);
  }

  // DELETE /users/{id}
  Future<void> deleteUser(String id) async {
    await _dio.delete('/users/$id');
  }

  // PUT /users/profile (multipart/form-data)
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    double? currentLat,
    double? currentLng,
    bool? locationEnabled,
    bool? backgroundLocationEnabled,
    String? avatarPath,
  }) async {
    final formData = FormData();
    if (name != null) formData.fields.add(MapEntry('name', name));
    if (phone != null) formData.fields.add(MapEntry('phone', phone));
    if (currentLat != null) formData.fields.add(MapEntry('currentLat', currentLat.toString()));
    if (currentLng != null) formData.fields.add(MapEntry('currentLng', currentLng.toString()));
    if (locationEnabled != null) formData.fields.add(MapEntry('locationEnabled', locationEnabled.toString()));
    if (backgroundLocationEnabled != null) {
      formData.fields.add(MapEntry('backgroundLocationEnabled', backgroundLocationEnabled.toString()));
    }
    if (avatarPath != null) {
      formData.files.add(MapEntry('avatar', await MultipartFile.fromFile(avatarPath)));
    }
    final response = await _dio.put('/users/profile', data: formData);
    final data = response.data;
    return (data is Map && data['user'] != null)
        ? data['user'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
  }

  // GET /users/profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/users/profile');
    return response.data as Map<String, dynamic>;
  }

  // GET /users/preferences
  Future<Map<String, dynamic>> getPreferences() async {
    final response = await _dio.get('/users/preferences');
    final data = response.data as Map<String, dynamic>;
    return {
      ...?data['preferences'] as Map<String, dynamic>?,
      'hasPreferences': data['hasPreferences'] ?? false,
    };
  }

  // POST /users/preferences
  Future<Map<String, dynamic>> savePreferences(Map<String, dynamic> preferences) async {
    final response = await _dio.post('/users/preferences', data: {
      'vibes': preferences['vibes'] ?? [],
      'music': preferences['music'] ?? [],
    });
    return response.data as Map<String, dynamic>;
  }

  // PUT /users/preferences
  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> preferences) async {
    final response = await _dio.put('/users/preferences', data: {
      'vibes': preferences['vibes'] ?? [],
      'music': preferences['music'] ?? [],
    });
    return response.data as Map<String, dynamic>;
  }

  // DELETE /users/account
  Future<void> deleteAccount() async {
    await _dio.delete('/users/account');
  }

  // GET /users/saved-venues
  Future<List<Map<String, dynamic>>> getSavedVenues() async {
    final response = await _dio.get('/users/saved-venues');
    final data = response.data;
    if (data is List) {
      return data.map((e) => e is Map<String, dynamic> ? e : {'id': e.toString()}).toList();
    }
    return [];
  }

  // POST /users/saved-venues/{venueId}
  Future<Map<String, dynamic>> saveVenue(String venueId) async {
    final response = await _dio.post('/users/saved-venues/$venueId');
    return response.data as Map<String, dynamic>;
  }

  // DELETE /users/saved-venues/{venueId}
  Future<void> unsaveVenue(String venueId) async {
    await _dio.delete('/users/saved-venues/$venueId');
  }

  // GET /users/redemptions
  Future<List<Map<String, dynamic>>> getRedemptions() async {
    final response = await _dio.get('/users/redemptions');
    final data = response.data;
    if (data is Map) {
      final list = data['redemptions'] ?? data['data'] ?? [];
      return List<Map<String, dynamic>>.from(list as List);
    }
    if (data is List) return List<Map<String, dynamic>>.from(data);
    return [];
  }

  // GET /users/notification-preferences
  Future<NotificationPreferences> getNotificationPreferences() async {
    final response = await _dio.get('/users/notification-preferences');
    return NotificationPreferences.fromJson(response.data as Map<String, dynamic>);
  }

  // PUT /users/notification-preferences
  Future<NotificationPreferences> updateNotificationPreferences(
      Map<String, dynamic> preferences) async {
    final response = await _dio.put('/users/notification-preferences', data: preferences);
    return NotificationPreferences.fromJson(response.data as Map<String, dynamic>);
  }
}
