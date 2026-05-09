import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

final locationApiServiceProvider = Provider<LocationApiService>((ref) {
  return LocationApiService(ref.read(apiClientProvider));
});

class LocationApiService {
  final Dio _dio;
  LocationApiService(this._dio);

  // POST /users/location - Update user GPS location
  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.post('/users/location', data: {
      'latitude': latitude,
      'longitude': longitude,
    });
    return response.data as Map<String, dynamic>;
  }

  // PUT /users/location-consent - Update location permission consent
  Future<Map<String, dynamic>> updateLocationConsent(bool granted) async {
    final response = await _dio.put('/users/location-consent', data: {
      'granted': granted,
    });
    return response.data as Map<String, dynamic>;
  }

  // POST /geofence/check - Check proximity to venues (200m radius)
  Future<Map<String, dynamic>> checkGeofence({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.post('/geofence/check', data: {
      'latitude': latitude,
      'longitude': longitude,
    });
    return response.data as Map<String, dynamic>;
  }

  // GET /analytics/popular-areas - Get popular neighborhoods with busyness data
  Future<List<Map<String, dynamic>>> getPopularAreas() async {
    final response = await _dio.get('/analytics/popular-areas');
    final data = response.data is Map
        ? response.data['data'] ?? response.data['areas'] ?? response.data
        : response.data;
    return List<Map<String, dynamic>>.from(data as List);
  }
}
