import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_models.dart';
import 'api_client.dart';

final adminApiServiceProvider = Provider<AdminApiService>((ref) {
  return AdminApiService(ref.read(apiClientProvider));
});

class AdminApiService {
  final Dio _dio;
  AdminApiService(this._dio);

  // GET /admin/stats
  Future<AdminStats> getStats() async {
    final res = await _dio.get('/admin/stats');
    return AdminStats.fromJson(res.data as Map<String, dynamic>);
  }

  // GET /admin/stats/location
  Future<Map<String, dynamic>> getLocationStats() async {
    final res = await _dio.get('/admin/stats/location');
    return res.data as Map<String, dynamic>;
  }

  // GET /admin/stats/realtime
  Future<Map<String, dynamic>> getRealtimeStats() async {
    final res = await _dio.get('/admin/stats/realtime');
    return res.data as Map<String, dynamic>;
  }

  // GET /admin/stats/offline
  Future<Map<String, dynamic>> getOfflineStats() async {
    final res = await _dio.get('/admin/stats/offline');
    return res.data as Map<String, dynamic>;
  }

  // GET /admin/users
  Future<List<AdminUser>> getUsers({int page = 1, int limit = 20}) async {
    final res = await _dio.get('/admin/users',
        queryParameters: {'page': page, 'limit': limit});
    return _extractList(res.data).map((j) => AdminUser.fromJson(j)).toList();
  }

  // GET /admin/users/{id}/activity
  Future<Map<String, dynamic>> getUserActivity(String userId) async {
    final res = await _dio.get('/admin/users/$userId/activity');
    return res.data as Map<String, dynamic>;
  }

  // GET /admin/venues
  Future<List<AdminVenue>> getVenues({int page = 1, int limit = 20}) async {
    final res = await _dio.get('/admin/venues',
        queryParameters: {'page': page, 'limit': limit});
    return _extractList(res.data).map((j) => AdminVenue.fromJson(j)).toList();
  }

  // GET /admin/venues/{id}/logs
  Future<List<Map<String, dynamic>>> getVenueLogs(String venueId) async {
    final res = await _dio.get('/admin/venues/$venueId/logs');
    return List<Map<String, dynamic>>.from(_extractList(res.data));
  }

  // GET /admin/offers
  Future<List<AdminOffer>> getOffers({int page = 1, int limit = 20}) async {
    final res = await _dio.get('/admin/offers',
        queryParameters: {'page': page, 'limit': limit});
    return _extractList(res.data).map((j) => AdminOffer.fromJson(j)).toList();
  }

  // GET /admin/offers/redemptions
  Future<List<AdminRedemption>> getRedemptions(
      {int page = 1, int limit = 20}) async {
    final res = await _dio.get('/admin/offers/redemptions',
        queryParameters: {'page': page, 'limit': limit});
    return _extractList(res.data)
        .map((j) => AdminRedemption.fromJson(j))
        .toList();
  }

  // GET /admin/activity-logs
  Future<List<ActivityLog>> getActivityLogs(
      {int page = 1, int limit = 20}) async {
    final res = await _dio.get('/admin/activity-logs',
        queryParameters: {'page': page, 'limit': limit});
    return _extractList(res.data).map((j) => ActivityLog.fromJson(j)).toList();
  }

  // GET /admin/notifications
  Future<List<Map<String, dynamic>>> getNotificationLogs(
      {int page = 1, int limit = 20}) async {
    final res = await _dio.get('/admin/notifications',
        queryParameters: {'page': page, 'limit': limit});
    return List<Map<String, dynamic>>.from(_extractList(res.data));
  }

  // POST /admin/venues - Create a new venue
  Future<Map<String, dynamic>> createVenue(Map<String, dynamic> data) async {
    final res = await _dio.post('/admin/venues', data: data);
    return res.data as Map<String, dynamic>;
  }

  // POST /admin/test-push
  Future<void> sendTestPush({
    required String userId,
    required String title,
    required String body,
  }) async {
    await _dio.post('/admin/test-push',
        data: {'userId': userId, 'title': title, 'body': body});
  }

  List _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      return (data['data'] ??
              data['users'] ??
              data['venues'] ??
              data['offers'] ??
              data['logs'] ??
              data['items'] ??
              data['notifications'] ??
              []) as List;
    }
    return [];
  }
}
