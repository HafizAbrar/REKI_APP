import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/notification.dart';
import '../../../core/services/notification_repository.dart';

final notificationManagementProvider = StateNotifierProvider<NotificationManagementNotifier, AsyncValue<List<AppNotification>>>((ref) {
  return NotificationManagementNotifier(ref.read(notificationRepositoryProvider));
});

class NotificationManagementNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final NotificationRepository _repository;

  NotificationManagementNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    final result = await _repository.getAllNotifications();
    state = result.when(
      success: (notifications) => AsyncValue.data(notifications),
      failure: (error) => AsyncValue.error(error, StackTrace.current),
    );
  }

  Future<bool> markAsRead(String id) async {
    final result = await _repository.markAsRead(id);
    return result.when(
      success: (_) {
        loadNotifications();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> markAllAsRead() async {
    final result = await _repository.markAllAsRead();
    return result.when(
      success: (_) {
        loadNotifications();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> deleteNotification(String id) async {
    final result = await _repository.deleteNotification(id);
    return result.when(
      success: (_) {
        loadNotifications();
        return true;
      },
      failure: (_) => false,
    );
  }
}

final unreadCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(notificationRepositoryProvider);
  final result = await repository.getUnreadCount();
  return result.when(
    success: (count) => count,
    failure: (_) => 0,
  );
});
