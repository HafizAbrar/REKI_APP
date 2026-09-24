import 'package:dio/dio.dart';
import '../network/interceptors/auth_interceptor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/env.dart';
import '../../core/models/city.dart';

class CityApiService {
  final Dio _dio;
  AuthInterceptor? _auth;
  void dispose() {
    if (_auth != null) {
      _auth!.dispose();
      _dio.close(force: true);
    }
  }

  CityApiService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: Env.apiBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Content-Type': 'application/json'},
            )) {
    if (dio == null) {
      _auth = AuthInterceptor();
      _dio.interceptors.add(_auth!);
    }
  }

  /// Get all cities from backend
  Future<List<City>> getCities() async {
    try {
      final response = await _dio.get('/cities');
      if (response.statusCode == 200) {
        final raw = response.data;
        final List<dynamic> data =
            raw is List ? raw : (raw['data'] ?? raw['cities']) as List;
        return data
            .map((json) => City.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load cities: ${response.statusCode}');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get active cities only
  Future<List<City>> getActiveCities() async {
    final cities = await getCities();
    return cities.where((c) => c.isActive).toList();
  }

  /// Get city by slug
  Future<City?> getCityBySlug(String slug) async {
    try {
      final response = await _dio.get('/cities/$slug');
      if (response.statusCode == 200) {
        return City.fromJson(response.data['data'] ?? response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleError(e);
    }
  }

  /// Get city by ID
  Future<City?> getCityById(String id) async {
    try {
      final response = await _dio.get('/cities/id/$id');
      if (response.statusCode == 200) {
        return City.fromJson(response.data['data'] ?? response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleError(e);
    }
  }

  /// Persist the supported city slug required by UpdateCityDto.
  Future<void> setUserCity(String citySlug) async {
    final token = await const FlutterSecureStorage().read(key: 'access_token');
    if (token == null) return;
    try {
      await _dio.put('/users/city', data: {'city': citySlug});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Persist locale and timezone to server — PUT /users/locale
  Future<void> setUserLocale(
      {required String language, required String timezone}) async {
    try {
      final token =
          await const FlutterSecureStorage().read(key: 'access_token');
      if (token == null) return;
      await _dio.put('/users/locale',
          data: {'locale': language, 'timezone': timezone});
    } on DioException catch (_) {
      // Best-effort — locale sync failure must not block city selection.
    }
  }

  /// Get user's current city
  Future<City?> getUserCity() async {
    try {
      final response = await _dio.get('/users/location/city');
      if (response.statusCode == 200 && response.data is Map) {
        final raw = response.data;
        final data = raw['data'] ?? raw['city'] ?? raw;
        if (data is Map && data['id'] != null) {
          return City.fromJson(Map<String, dynamic>.from(data));
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleError(e);
    }
  }

  /// Detect city from coordinates
  Future<City?> detectCityFromLocation(double lat, double lng) async {
    try {
      final response = await _dio.get('/cities/detect', queryParameters: {
        'lat': lat,
        'lng': lng,
      });
      if (response.statusCode == 200 && response.data is Map) {
        final raw = response.data;
        final data = raw['data'] ?? raw['city'] ?? raw;
        if (data is Map && data['id'] != null) {
          return City.fromJson(Map<String, dynamic>.from(data));
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final body = e.response?.data;
      final message = body is Map
          ? body['message']?.toString() ?? 'Request failed'
          : 'Request failed with status ${e.response?.statusCode}';
      return Exception(message);
    }
    return Exception('Network error: ${e.message}');
  }
}
