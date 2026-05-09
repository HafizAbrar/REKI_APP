import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/admin_repository.dart';

// GET /admin/stats
final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final result = await ref.read(adminRepositoryProvider).getStats();
  return result.when(success: (d) => d, failure: (e) => throw Exception(e));
});

// GET /admin/stats/location
final adminLocationStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final result = await ref.read(adminRepositoryProvider).getLocationStats();
  return result.when(success: (d) => d, failure: (e) => throw Exception(e));
});

// GET /admin/stats/realtime
final adminRealtimeStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final result = await ref.read(adminRepositoryProvider).getRealtimeStats();
  return result.when(success: (d) => d, failure: (e) => throw Exception(e));
});

// GET /admin/stats/offline
final adminOfflineStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final result = await ref.read(adminRepositoryProvider).getOfflineStats();
  return result.when(success: (d) => d, failure: (e) => throw Exception(e));
});

// GET /admin/users
final adminUsersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final result = await ref.read(adminRepositoryProvider).getUsers();
  return result.when(success: (d) => d, failure: (e) => throw Exception(e));
});

// GET /admin/users/{id}/activity
final adminUserActivityProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final result = await ref.read(adminRepositoryProvider).getUserActivity(userId);
  return result.when(success: (d) => d, failure: (e) => throw Exception(e));
});

// GET /admin/venues
final adminVenuesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final result = await ref.read(adminRepositoryProvider).getVenues();
  return result.when(success: (d) => d, failure: (e) => throw Exception(e));
});

// GET /admin/venues/{id}/logs
final adminVenueLogsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, venueId) async {
  final result = await ref.read(adminRepositoryProvider).getVenueLogs(venueId);
  return result.when(success: (d) => d, failure: (e) => throw Exception(e));
});

// GET /admin/offers
final adminOffersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final result = await ref.read(adminRepositoryProvider).getOffers();
  return result.when(success: (d) => d, failure: (e) => throw Exception(e));
});

// GET /admin/offers/redemptions
final adminRedemptionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final result = await ref.read(adminRepositoryProvider).getRedemptions();
  return result.when(success: (d) => d, failure: (e) => throw Exception(e));
});

// GET /admin/activity-logs
final adminActivityLogsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final result = await ref.read(adminRepositoryProvider).getActivityLogs();
  return result.when(success: (d) => d, failure: (e) => throw Exception(e));
});

// GET /admin/notifications
final adminNotificationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final result = await ref.read(adminRepositoryProvider).getNotifications();
  return result.when(success: (d) => d, failure: (e) => throw Exception(e));
});

// POST /admin/test-push
final adminTestPushProvider =
    StateNotifierProvider<AdminTestPushNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return AdminTestPushNotifier(ref.read(adminRepositoryProvider));
});

class AdminTestPushNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final AdminRepository _repository;
  AdminTestPushNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> send({required String userId, required String title, required String body}) async {
    state = const AsyncValue.loading();
    final result = await _repository.sendTestPush(userId: userId, title: title, body: body);
    return result.when(
      success: (data) { state = AsyncValue.data(data); return true; },
      failure: (e) { state = AsyncValue.error(e, StackTrace.current); return false; },
    );
  }
}
