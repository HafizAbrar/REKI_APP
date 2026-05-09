import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../network/notification_api_service.dart';
import '../utils/error_handler.dart';
import '../utils/result.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.read(notificationApiServiceProvider));
});

class NotificationRepository {
  final NotificationApiService _apiService;

  NotificationRepository(this._apiService);

  Future<Result<Map<String, List<AppNotification>>>> getAllNotifications() async {
    try {
      final data = await _apiService.getAllNotifications();
      // API returns { today: [...], yesterday: [...], earlier: [...] }
      final grouped = <String, List<AppNotification>>{};
      for (final key in ['today', 'yesterday', 'earlier']) {
        if (data[key] != null) {
          grouped[key] = (data[key] as List)
              .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          grouped[key] = [];
        }
      }
      return Result.success(grouped);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<AppNotification>> markAsRead(String id) async {
    try {
      final notification = await _apiService.markAsRead(id);
      return Result.success(notification);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<void>> markAllAsRead() async {
    try {
      await _apiService.markAllAsRead();
      return Result.success(null);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<void>> deleteNotification(String id) async {
    try {
      await _apiService.deleteNotification(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<AppNotification>> testNotification(Map<String, dynamic> data) async {
    try {
      final notification = await _apiService.testNotification(data);
      return Result.success(notification);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }
}
