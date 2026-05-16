import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../network/notification_api_service.dart';
import '../utils/app_logger.dart';
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
      final raw = await _apiService.getAllNotifications();
      appLogger.d('Notifications raw response: $raw');

      // Unwrap common envelopes: { data: {...} } or { notifications: [...] }
      Map<String, dynamic> data;
      if (raw['data'] is Map) {
        data = raw['data'] as Map<String, dynamic>;
      } else if (raw['notifications'] is List) {
        data = {'today': raw['notifications'], 'yesterday': [], 'earlier': []};
      } else {
        data = raw;
      }

      final grouped = <String, List<AppNotification>>{};
      for (final key in ['today', 'yesterday', 'earlier']) {
        final list = data[key];
        if (list is List) {
          grouped[key] = list
              .whereType<Map<String, dynamic>>()
              .map((item) {
                try {
                  return AppNotification.fromJson(item);
                } catch (e) {
                  appLogger.e('Failed to parse notification: $item', error: e);
                  return null;
                }
              })
              .whereType<AppNotification>()
              .toList();
        } else {
          grouped[key] = [];
        }
      }
      return Result.success(grouped);
    } catch (e, st) {
      appLogger.e('getAllNotifications error', error: e, stackTrace: st);
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
