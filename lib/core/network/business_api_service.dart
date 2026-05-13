import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

final businessApiServiceProvider = Provider<BusinessApiService>((ref) {
  return BusinessApiService(ref.read(apiClientProvider));
});

class BusinessApiService {
  final Dio _dio;
  BusinessApiService(this._dio);

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

  // POST /business/venues - Create a new venue
  Future<Map<String, dynamic>> createVenue(Map<String, dynamic> data) async {
    final res = await _dio.post('/business/venues', data: data);
    return res.data as Map<String, dynamic>;
  }

  // GET /business/dashboard/{venueId} - Get venue dashboard (stats, vibe, weather)
  Future<Map<String, dynamic>> getDashboard(String venueId) async {
    final response = await _dio.get('/business/dashboard/$venueId');
    return response.data as Map<String, dynamic>;
  }

  // GET /business/analytics/{venueId} - Get venue analytics
  Future<Map<String, dynamic>> getAnalytics(String venueId) async {
    final response = await _dio.get('/business/analytics/$venueId');
    return response.data as Map<String, dynamic>;
  }

  // PUT /business/venues/{id}/status - Update busyness + vibe + liveInfo (Phase 6)
  Future<Map<String, dynamic>> updateVenueStatus(
    String venueId, {
    String? busyness,
    String? vibe,
    String? liveInfo,
  }) async {
    final response = await _dio.put('/business/venues/$venueId/status', data: {
      if (busyness != null) 'busyness': busyness,
      if (vibe != null) 'vibe': vibe,
      if (liveInfo != null) 'liveInfo': liveInfo,
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
    final data = response.data is Map
        ? response.data['data'] ?? response.data['offers'] ?? response.data
        : response.data;
    return List<Map<String, dynamic>>.from(data as List);
  }

  // POST /business/offers - Create new offer
  Future<Map<String, dynamic>> createOffer(Map<String, dynamic> offerData) async {
    final response = await _dio.post('/business/offers', data: offerData);
    return response.data as Map<String, dynamic>;
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
