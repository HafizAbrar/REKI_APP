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

  // PUT /notifications/{id}/read — optimistic update
  Future<bool> markAsRead(String id) async {
    // Optimistically mark as read in local state immediately
    final current = state.valueOrNull;
    if (current != null) {
      final updated = current.map((key, list) => MapEntry(
        key,
        list.map((n) => n.id == id ? (n..isRead = true) : n).toList(),
      ));
      state = AsyncValue.data(updated);
    }
    // Fire API in background — reload on failure to restore correct state
    final result = await _repository.markAsRead(id);
    return result.when(
      success: (_) => true,
      failure: (_) { loadNotifications(); return false; },
    );
  }

  // PUT /notifications/read-all — optimistic update
  Future<bool> markAllAsRead() async {
    // Optimistically mark all as read in local state immediately
    final current = state.valueOrNull;
    if (current != null) {
      final updated = current.map((key, list) => MapEntry(
        key,
        list.map((n) => n..isRead = true).toList(),
      ));
      state = AsyncValue.data(updated);
    }
    // Fire API in background — reload on failure to restore correct state
    final result = await _repository.markAllAsRead();
    return result.when(
      success: (_) => true,
      failure: (_) { loadNotifications(); return false; },
    );
  }

  Future<bool> deleteNotification(String id) async {
    // Optimistically remove from local state immediately
    final current = state.valueOrNull;
    if (current != null) {
      final updated = current.map((key, list) => MapEntry(
        key,
        list.where((n) => n.id != id).toList(),
      ));
      state = AsyncValue.data(updated);
    }
    final result = await _repository.deleteNotification(id);
    return result.when(
      success: (_) => true,
      failure: (_) { loadNotifications(); return false; },
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
