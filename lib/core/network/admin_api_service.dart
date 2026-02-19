import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

final adminApiServiceProvider = Provider<AdminApiService>((ref) {
  return AdminApiService(ref.read(apiClientProvider));
});

class AdminApiService {
  final Dio _dio;

  AdminApiService(this._dio);

  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _dio.get('/analytics/owner/dashboard');
    return response.data;
  }

  Future<List<dynamic>> getVenues() async {
    final response = await _dio.get('/venues');
    return response.data as List;
  }

  Future<List<dynamic>> getUserVenues(String userId) async {
    final response = await _dio.get('/users/$userId/venues');
    return response.data as List;
  }

  Future<List<dynamic>> getCities() async {
    final response = await _dio.get('/cities');
    return response.data as List;
  }

  Future<Map<String, dynamic>> getVenueAnalytics(String venueId) async {
    final response = await _dio.get('/analytics/venues/$venueId');
    return response.data;
  }

  Future<Map<String, dynamic>> createOffer(Map<String, dynamic> offerData) async {
    final response = await _dio.post('/offers', data: offerData);
    return response.data;
  }

  Future<Map<String, dynamic>> createBusinessUser(Map<String, dynamic> userData) async {
    final response = await _dio.post('/auth/register', data: userData);
    return response.data;
  }
}
