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
    final data = res.data;
    if (data is Map<String, dynamic>) return AdminStats.fromJson(data);
    throw Exception('Unexpected stats response format: $data');
  }

  // GET /admin/stats/location
  Future<LocationStats> getLocationStats() async {
    final res = await _dio.get('/admin/stats/location');
    final data = res.data;
    if (data is Map<String, dynamic>) return LocationStats.fromJson(data);
    throw Exception('Unexpected location stats response format: $data');
  }

  // GET /admin/stats/realtime
  Future<RealtimeStats> getRealtimeStats() async {
    final res = await _dio.get('/admin/stats/realtime');
    final data = res.data;
    if (data is Map<String, dynamic>) return RealtimeStats.fromJson(data);
    throw Exception('Unexpected realtime stats response format: $data');
  }

  // GET /admin/stats/offline
  Future<OfflineStats> getOfflineStats() async {
    final res = await _dio.get('/admin/stats/offline');
    final data = res.data;
    if (data is Map<String, dynamic>) return OfflineStats.fromJson(data);
    throw Exception('Unexpected offline stats response format: $data');
  }

  // GET /admin/users
  Future<AdminUsersPage> getUsers({int page = 1, int limit = 20}) async {
    final res = await _dio.get('/admin/users',
        queryParameters: {'page': page, 'limit': limit});
    final data = res.data;
    if (data is Map<String, dynamic>) return AdminUsersPage.fromJson(data);
    // fallback: bare list
    final list = (data as List)
        .map((j) => AdminUser.fromJson(j as Map<String, dynamic>))
        .toList();
    return AdminUsersPage(
        users: list, total: list.length, page: 1, pages: 1,
        hasNext: false, hasPrev: false);
  }

  // GET /admin/users/{id}/activity
  Future<UserActivityData> getUserActivity(String userId) async {
    final res = await _dio.get('/admin/users/$userId/activity');
    return UserActivityData.fromJson(res.data as Map<String, dynamic>);
  }

  // GET /admin/venues
  Future<AdminVenuesPage> getVenues({int page = 1, int limit = 20}) async {
    final res = await _dio.get('/admin/venues',
        queryParameters: {'page': page, 'limit': limit});
    final data = res.data;
    if (data is Map<String, dynamic> && data.containsKey('venues')) {
      return AdminVenuesPage.fromJson(data);
    }
    final list = _extractList(data)
        .map((j) => AdminVenue.fromJson(j as Map<String, dynamic>))
        .toList();
    return AdminVenuesPage(
        venues: list, total: list.length, page: 1, pages: 1,
        hasNext: false, hasPrev: false);
  }

  // GET /admin/venues/{id}/logs
  Future<VenueLogsData> getVenueLogs(String venueId) async {
    final res = await _dio.get('/admin/venues/$venueId/logs');
    return VenueLogsData.fromJson(res.data as Map<String, dynamic>);
  }

  // GET /admin/offers
  Future<AdminOffersPage> getOffers({int page = 1, int limit = 20}) async {
    final res = await _dio.get('/admin/offers',
        queryParameters: {'page': page, 'limit': limit});
    final data = res.data;
    if (data is Map<String, dynamic> && data.containsKey('offers')) {
      return AdminOffersPage.fromJson(data);
    }
    final list = _extractList(data)
        .map((j) => AdminOffer.fromJson(j as Map<String, dynamic>))
        .toList();
    return AdminOffersPage(
        offers: list, total: list.length, page: 1, pages: 1,
        hasNext: false, hasPrev: false);
  }

  // GET /admin/offers/redemptions
  Future<AdminRedemptionsPage> getRedemptions(
      {int page = 1, int limit = 20}) async {
    final res = await _dio.get('/admin/offers/redemptions',
        queryParameters: {'page': page, 'limit': limit});
    final data = res.data;
    if (data is Map<String, dynamic> && data.containsKey('redemptions')) {
      return AdminRedemptionsPage.fromJson(data);
    }
    final list = _extractList(data)
        .map((j) => AdminRedemption.fromJson(j as Map<String, dynamic>))
        .toList();
    return AdminRedemptionsPage(
        redemptions: list, total: list.length, page: 1, pages: 1,
        hasNext: false, hasPrev: false);
  }

  // GET /admin/activity-logs
  Future<ActivityLogsPage> getActivityLogs(
      {int page = 1, int limit = 50}) async {
    final res = await _dio.get('/admin/activity-logs',
        queryParameters: {'page': page, 'limit': limit});
    final data = res.data;
    if (data is Map<String, dynamic> && data.containsKey('logs')) {
      return ActivityLogsPage.fromJson(data);
    }
    final list = _extractList(data)
        .map((j) => ActivityLog.fromJson(j as Map<String, dynamic>))
        .toList();
    return ActivityLogsPage(
        logs: list, total: list.length, page: 1, pages: 1,
        hasNext: false, hasPrev: false);
  }

  // GET /admin/notifications
  Future<AdminNotificationsPage> getNotificationLogs(
      {int page = 1, int limit = 20}) async {
    final res = await _dio.get('/admin/notifications',
        queryParameters: {'page': page, 'limit': limit});
    final data = res.data;
    if (data is Map<String, dynamic> && data.containsKey('notifications')) {
      return AdminNotificationsPage.fromJson(data);
    }
    final list = _extractList(data)
        .map((j) => AdminNotification.fromJson(j as Map<String, dynamic>))
        .toList();
    return AdminNotificationsPage(
        notifications: list, total: list.length, page: 1, pages: 1,
        hasNext: false, hasPrev: false);
  }

  // POST /admin/venues - Create a new venue
  Future<Map<String, dynamic>> createVenue(Map<String, dynamic> data) async {
    final res = await _dio.post('/admin/venues', data: data);
    return res.data as Map<String, dynamic>;
  }

  // POST /admin/test-push
  Future<TestPushResult> sendTestPush({
    required String userId,
    required String title,
    required String body,
  }) async {
    final res = await _dio.post('/admin/test-push',
        data: {'userId': userId, 'title': title, 'body': body});
    return TestPushResult.fromJson(res.data as Map<String, dynamic>);
  }

  // GET /admin/profile
  Future<Map<String, dynamic>> getAdminProfile() async {
    final res = await _dio.get('/admin/profile');
    return res.data as Map<String, dynamic>;
  }

  // PUT /admin/profile
  Future<Map<String, dynamic>> updateAdminProfile({
    String? name,
    String? phone,
    double? currentLat,
    double? currentLng,
    String? avatarPath,
  }) async {
    final formData = FormData();
    if (name != null) formData.fields.add(MapEntry('name', name));
    if (phone != null) formData.fields.add(MapEntry('phone', phone));
    if (currentLat != null) formData.fields.add(MapEntry('currentLat', currentLat.toString()));
    if (currentLng != null) formData.fields.add(MapEntry('currentLng', currentLng.toString()));
    if (avatarPath != null) {
      formData.files.add(MapEntry('avatar', await MultipartFile.fromFile(avatarPath)));
    }
    final res = await _dio.put('/admin/profile', data: formData);
    return res.data as Map<String, dynamic>;
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
