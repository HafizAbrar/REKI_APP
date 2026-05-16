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

  // GET /notifications - Get notifications grouped by Today/Yesterday/Earlier
  Future<Map<String, dynamic>> getAllNotifications() async {
    final response = await _dio.get('/notifications');
    return response.data as Map<String, dynamic>;
  }

  // PUT /notifications/{id}/read - Mark a notification as read
  Future<AppNotification> markAsRead(String id) async {
    final response = await _dio.put('/notifications/$id/read');
    final data = response.data is Map
        ? (response.data['data'] ?? response.data['notification'] ?? response.data)
        : response.data;
    return AppNotification.fromJson(data as Map<String, dynamic>);
  }

  // PUT /notifications/read-all - Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _dio.put('/notifications/read-all');
  }

  Future<void> deleteNotification(String id) async {
    await _dio.delete('/notifications/$id');
  }

  Future<AppNotification> testNotification(Map<String, dynamic> data) async {
    final response = await _dio.post('/notifications/test', data: data);
    return AppNotification.fromJson(response.data);
  }
}
