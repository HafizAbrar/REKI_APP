import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../config/env.dart';
import 'api_client.dart';

final businessApiServiceProvider = Provider<BusinessApiService>((ref) {
  return BusinessApiService(ref.read(apiClientProvider));
});

class BusinessApiService {
  final Dio _dio;
  BusinessApiService(this._dio);

  // GET /business/profile
  Future<Map<String, dynamic>> getBusinessProfile() async {
    final response = await _dio.get('/business/profile');
    return response.data as Map<String, dynamic>;
  }

  // PUT /business/profile - Update name, phone, avatar (multipart/form-data)
  Future<Map<String, dynamic>> updateBusinessProfile({
    String? name,
    String? phone,
    String? avatarPath,
  }) async {
    final token = await const FlutterSecureStorage().read(key: 'access_token');
    final bareDio = Dio(BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ));
    final formData = FormData();
    if (name != null) formData.fields.add(MapEntry('name', name));
    if (phone != null) formData.fields.add(MapEntry('phone', phone));
    if (avatarPath != null) {
      formData.files.add(MapEntry(
        'avatar',
        await MultipartFile.fromFile(avatarPath,
            filename: avatarPath.split('/').last),
      ));
    }
    final response = await bareDio.put('/business/profile', data: formData);
    final data = response.data;
    return (data is Map && data['user'] != null)
        ? data['user'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
  }

  // POST /auth/business/login - Business login
  Future<Map<String, dynamic>> businessLogin({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/business/login', data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  // POST /auth/business/register - Business registration
  Future<Map<String, dynamic>> businessRegister(Map<String, dynamic> data) async {
    final response = await _dio.post('/auth/business/register', data: data);
    return response.data as Map<String, dynamic>;
  }

  // POST /auth/business/forgot-password - Business forgot password
  Future<Map<String, dynamic>> businessForgotPassword(String email) async {
    final response = await _dio.post('/auth/business/forgot-password', data: {'email': email});
    return response.data as Map<String, dynamic>;
  }

  // POST /auth/business/reset-password - Business reset password
  Future<Map<String, dynamic>> businessResetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await _dio.post('/auth/business/reset-password', data: {
      'token': token,
      'newPassword': newPassword,
    });
    return response.data as Map<String, dynamic>;
  }

  // POST /business/venues - Create a new venue (multipart/form-data)
  // Uses a bare Dio instance (no retry interceptor) — FormData streams cannot be replayed.
  Future<Map<String, dynamic>> createVenue(
    Map<String, dynamic> data, {
    List<XFile> images = const [],
  }) async {
    final token = await const FlutterSecureStorage().read(key: 'access_token');

    final bareDio = Dio(BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      validateStatus: (s) => s != null && s < 500,
    ));

    final formData = FormData();
    formData.fields
      ..add(MapEntry('name', data['name'].toString()))
      ..add(MapEntry('address', data['address'].toString()))
      ..add(MapEntry('city', data['city'].toString()))
      ..add(MapEntry('area', data['area'].toString()))
      ..add(MapEntry('category', data['category'].toString()))
      ..add(MapEntry('lat', data['lat'].toString()))
      ..add(MapEntry('lng', data['lng'].toString()))
      ..add(MapEntry('openingHours', data['openingHours'].toString()))
      ..add(MapEntry('closingTime', data['closingTime'].toString()));

    if (data['priceLevel'] != null) {
      formData.fields.add(MapEntry('priceLevel', data['priceLevel'].toString()));
    }
    if (data['tags'] is List && (data['tags'] as List).isNotEmpty) {
      for (final tag in (data['tags'] as List)) {
        formData.fields.add(MapEntry('tags[]', tag.toString()));
      }
    }
    for (final img in images) {
      formData.files.add(MapEntry(
        'images',
        await MultipartFile.fromFile(img.path, filename: img.name),
      ));
    }

    final res = await bareDio.post('/business/venues', data: formData);

    if (res.statusCode == 201 || res.statusCode == 200) {
      final body = res.data;
      if (body is Map<String, dynamic>) return body;
      if (body is Map) return Map<String, dynamic>.from(body);
      return {};
    }
    final msg = (res.data is Map) ? res.data['message']?.toString() : null;
    throw Exception(msg ?? 'Failed to create venue (${res.statusCode})');
  }

  // POST /upload/image - Upload a single image, returns { url: '...' }
  Future<String> uploadImage(XFile file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.name),
    });
    final res = await _dio.post('/upload/image', data: formData);
    final data = res.data as Map<String, dynamic>;
    return data['url']?.toString() ?? data['imageUrl']?.toString() ?? data['path']?.toString() ?? '';
  }

  // GET /business/venues - Get all my venues
  Future<List<Map<String, dynamic>>> getMyVenues() async {
    final res = await _dio.get('/business/venues');
    final data = res.data;
    // Handle: array, { venues: [] }, { data: [] }, { data: { venues: [] } }
    if (data is List) return List<Map<String, dynamic>>.from(data);
    if (data is Map) {
      final inner = data['data'];
      if (inner is List) return List<Map<String, dynamic>>.from(inner);
      if (inner is Map) {
        final nested = inner['venues'] ?? inner['items'] ?? inner['data'];
        if (nested is List) return List<Map<String, dynamic>>.from(nested);
      }
      final list = data['venues'] ?? data['items'] ?? data['results'] ?? [];
      if (list is List) return List<Map<String, dynamic>>.from(list);
    }
    return [];
  }

  // PUT /business/venues/{id} - Update venue details
  Future<Map<String, dynamic>> updateVenue(String id, Map<String, dynamic> data) async {
    final res = await _dio.put('/business/venues/$id', data: data);
    return res.data as Map<String, dynamic>;
  }

  // DELETE /business/venues/{id} - Remove venue from account
  Future<void> deleteVenue(String id) async {
    await _dio.delete('/business/venues/$id');
  }

  // GET /business/dashboard/{venueId} - Get venue dashboard (stats, vibe, weather)
  Future<Map<String, dynamic>> getDashboard(String venueId) async {
    final response = await _dio.get('/business/dashboard/$venueId');
    return response.data as Map<String, dynamic>;
  }

  // GET /business/analytics/{venueId}?period=today|week|month
  Future<Map<String, dynamic>> getAnalytics(String venueId, {String period = 'week'}) async {
    final response = await _dio.get(
      '/business/analytics/$venueId',
      queryParameters: {'period': period},
    );
    return response.data as Map<String, dynamic>;
  }

  // GET /tags/vibes - Get all vibe tags
  Future<List<Map<String, dynamic>>> getVibeTags() async {
    final res = await _dio.get('/tags/vibes');
    return List<Map<String, dynamic>>.from(res.data as List);
  }

  // GET /tags/music - Get all music tags
  Future<List<Map<String, dynamic>>> getMusicTags() async {
    final res = await _dio.get('/tags/music');
    return List<Map<String, dynamic>>.from(res.data as List);
  }

  // PUT /business/venues/{id}/status
  // Accepted fields: busyness (required), vibes (optional string[])
  Future<Map<String, dynamic>> updateVenueStatus(
    String venueId, {
    required String busyness,
    List<String>? vibes,
  }) async {
    final response = await _dio.put('/business/venues/$venueId/status', data: {
      'busyness': busyness,
      if (vibes != null) 'vibes': vibes,
    });
    return response.data as Map<String, dynamic>;
  }

  // GET /business/venues/{id}/status - Get current venue status
  Future<Map<String, dynamic>> getVenueStatus(String venueId) async {
    final response = await _dio.get('/business/venues/$venueId/status');
    return response.data as Map<String, dynamic>;
  }

  // GET /business/venues/{id}/offers - List venue offers (active + past)
  Future<List<Map<String, dynamic>>> getVenueOffers(String venueId) async {
    final response = await _dio.get('/business/venues/$venueId/offers');
    final raw = response.data;
    List? list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map) {
      final inner = raw['data'] ?? raw['offers'] ?? raw['items'] ?? raw['results'];
      if (inner is List) {
        list = inner;
      } else if (inner is Map) {
        final nested = inner['offers'] ?? inner['items'] ?? inner['data'];
        if (nested is List) list = nested;
      }
    }
    if (list == null) return [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // POST /business/offers - Create new offer
  Future<Map<String, dynamic>> createOffer(Map<String, dynamic> offerData) async {
    final response = await _dio.post(
      '/business/offers',
      data: offerData,
      options: Options(validateStatus: (s) => s != null && s < 500),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = response.data;
      return (data is Map && data['data'] != null)
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
    }
    throw Exception(response.data?['message'] ?? 'Failed to create offer');
  }

  // PUT /business/offers/{id} - Update an offer
  Future<Map<String, dynamic>> updateOffer(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/business/offers/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  // DELETE /business/offers/{id} - Delete an offer (soft delete)
  Future<void> deleteOffer(String id) async {
    await _dio.delete('/business/offers/$id');
  }

  // PUT /business/offers/{id}/toggle - Toggle offer active/inactive
  Future<Map<String, dynamic>> toggleOffer(String id) async {
    final response = await _dio.put('/business/offers/$id/toggle');
    return response.data as Map<String, dynamic>;
  }
}
