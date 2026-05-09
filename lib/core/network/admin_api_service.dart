import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

final adminApiServiceProvider = Provider<AdminApiService>((ref) {
  return AdminApiService(ref.read(apiClientProvider));
});

class AdminApiService {
  final Dio _dio;
  AdminApiService(this._dio);

  // GET /admin/stats - Platform overview stats
  Future<Map<String, dynamic>> getStats() async {
    final response = await _dio.get('/admin/stats');
    return response.data as Map<String, dynamic>;
  }

  // GET /admin/stats/location - Location-related stats
  Future<Map<String, dynamic>> getLocationStats() async {
    final response = await _dio.get('/admin/stats/location');
    return response.data as Map<String, dynamic>;
  }

  // GET /admin/users - List all users
  Future<List<Map<String, dynamic>>> getUsers({int page = 1, int limit = 20}) async {
    final response = await _dio.get('/admin/users', queryParameters: {'page': page, 'limit': limit});
    final data = response.data is Map ? response.data['data'] ?? response.data['users'] ?? response.data : response.data;
    return List<Map<String, dynamic>>.from(data as List);
  }

  // GET /admin/users/{id}/activity - User activity (login history, redemptions)
  Future<Map<String, dynamic>> getUserActivity(String userId) async {
    final response = await _dio.get('/admin/users/$userId/activity');
    return response.data as Map<String, dynamic>;
  }

  // GET /admin/venues - List all venues with status
  Future<List<Map<String, dynamic>>> getVenues() async {
    final response = await _dio.get('/admin/venues');
    final data = response.data is Map ? response.data['data'] ?? response.data['venues'] ?? response.data : response.data;
    return List<Map<String, dynamic>>.from(data as List);
  }

  // GET /admin/venues/{id}/logs - Busyness/vibe update logs
  Future<List<Map<String, dynamic>>> getVenueLogs(String venueId) async {
    final response = await _dio.get('/admin/venues/$venueId/logs');
    final data = response.data is Map ? response.data['data'] ?? response.data['logs'] ?? response.data : response.data;
    return List<Map<String, dynamic>>.from(data as List);
  }

  // GET /admin/offers - List all offers across venues
  Future<List<Map<String, dynamic>>> getOffers() async {
    final response = await _dio.get('/admin/offers');
    final data = response.data is Map ? response.data['data'] ?? response.data['offers'] ?? response.data : response.data;
    return List<Map<String, dynamic>>.from(data as List);
  }

  // GET /admin/offers/redemptions - Redemption logs
  Future<List<Map<String, dynamic>>> getRedemptions() async {
    final response = await _dio.get('/admin/offers/redemptions');
    final data = response.data is Map ? response.data['data'] ?? response.data['redemptions'] ?? response.data : response.data;
    return List<Map<String, dynamic>>.from(data as List);
  }

  // GET /admin/activity-logs - All activity logs
  Future<List<Map<String, dynamic>>> getActivityLogs() async {
    final response = await _dio.get('/admin/activity-logs');
    final data = response.data is Map ? response.data['data'] ?? response.data['logs'] ?? response.data : response.data;
    return List<Map<String, dynamic>>.from(data as List);
  }

  // GET /admin/notifications - All notification logs
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await _dio.get('/admin/notifications');
    final data = response.data is Map ? response.data['data'] ?? response.data['notifications'] ?? response.data : response.data;
    return List<Map<String, dynamic>>.from(data as List);
  }

  // GET /admin/stats/realtime - Real-time stats (WebSocket connections, push analytics)
  Future<Map<String, dynamic>> getRealtimeStats() async {
    final response = await _dio.get('/admin/stats/realtime');
    return response.data as Map<String, dynamic>;
  }

  // GET /admin/stats/offline - Offline sync stats
  Future<Map<String, dynamic>> getOfflineStats() async {
    final response = await _dio.get('/admin/stats/offline');
    return response.data as Map<String, dynamic>;
  }

  // POST /admin/test-push - Send a test push notification
  Future<Map<String, dynamic>> sendTestPush({
    required String userId,
    required String title,
    required String body,
  }) async {
    final response = await _dio.post('/admin/test-push', data: {
      'userId': userId,
      'title': title,
      'body': body,
    });
    return response.data as Map<String, dynamic>;
  }
}
