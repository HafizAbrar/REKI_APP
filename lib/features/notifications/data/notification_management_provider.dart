import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/notification.dart';
import '../../../core/services/notification_repository.dart';

// Holds grouped notifications: { 'today': [...], 'yesterday': [...], 'earlier': [...] }
final notificationManagementProvider = StateNotifierProvider<
    NotificationManagementNotifier,
    AsyncValue<Map<String, List<AppNotification>>>>((ref) {
  return NotificationManagementNotifier(ref.read(notificationRepositoryProvider));
});

class NotificationManagementNotifier
    extends StateNotifier<AsyncValue<Map<String, List<AppNotification>>>> {
  final NotificationRepository _repository;

  NotificationManagementNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  // GET /notifications - grouped by Today/Yesterday/Earlier
  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    final result = await _repository.getAllNotifications();
    state = result.when(
      success: (grouped) => AsyncValue.data(grouped),
      failure: (error) => AsyncValue.error(error, StackTrace.current),
    );
  }

  // PUT /notifications/{id}/read
  Future<bool> markAsRead(String id) async {
    final result = await _repository.markAsRead(id);
    return result.when(
      success: (_) { loadNotifications(); return true; },
      failure: (_) => false,
    );
  }

  // PUT /notifications/read-all
  Future<bool> markAllAsRead() async {
    final result = await _repository.markAllAsRead();
    return result.when(
      success: (_) { loadNotifications(); return true; },
      failure: (_) => false,
    );
  }

  Future<bool> deleteNotification(String id) async {
    final result = await _repository.deleteNotification(id);
    return result.when(
      success: (_) { loadNotifications(); return true; },
      failure: (_) => false,
    );
  }

  // Flat list helper for screens that need all notifications
  List<AppNotification> get allNotifications {
    final data = state.valueOrNull;
    if (data == null) return [];
    return [
      ...data['today'] ?? [],
      ...data['yesterday'] ?? [],
      ...data['earlier'] ?? [],
    ];
  }

  int get unreadCount => allNotifications.where((n) => !n.isRead).length;
}
