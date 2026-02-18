import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../network/notification_api_service.dart';
import '../utils/result.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.read(notificationApiServiceProvider));
});

class NotificationRepository {
  final NotificationApiService _apiService;

  NotificationRepository(this._apiService);

  Future<Result<List<AppNotification>>> getAllNotifications() async {
    try {
      final notifications = await _apiService.getAllNotifications();
      return Result.success(notifications);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<int>> getUnreadCount() async {
    try {
      final data = await _apiService.getUnreadCount();
      return Result.success(data['count'] ?? 0);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<AppNotification>> markAsRead(String id) async {
    try {
      final notification = await _apiService.markAsRead(id);
      return Result.success(notification);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<void>> markAllAsRead() async {
    try {
      await _apiService.markAllAsRead();
      return Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<void>> deleteNotification(String id) async {
    try {
      await _apiService.deleteNotification(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<AppNotification>> testNotification(Map<String, dynamic> data) async {
    try {
      final notification = await _apiService.testNotification(data);
      return Result.success(notification);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
