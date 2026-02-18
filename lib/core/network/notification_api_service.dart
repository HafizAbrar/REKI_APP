import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import 'api_client.dart';

final notificationApiServiceProvider = Provider<NotificationApiService>((ref) {
  return NotificationApiService(ref.read(apiClientProvider));
});

class NotificationApiService {
  final Dio _dio;

  NotificationApiService(this._dio);

  Future<List<AppNotification>> getAllNotifications() async {
    final response = await _dio.get('/notifications');
    return (response.data as List).map((json) => AppNotification.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> getUnreadCount() async {
    final response = await _dio.get('/notifications/unread-count');
    return response.data;
  }

  Future<AppNotification> markAsRead(String id) async {
    final response = await _dio.patch('/notifications/$id/read');
    return AppNotification.fromJson(response.data);
  }

  Future<void> markAllAsRead() async {
    await _dio.patch('/notifications/mark-all-read');
  }

  Future<void> deleteNotification(String id) async {
    await _dio.delete('/notifications/$id');
  }

  Future<AppNotification> testNotification(Map<String, dynamic> data) async {
    final response = await _dio.post('/notifications/test', data: data);
    return AppNotification.fromJson(response.data);
  }
}
