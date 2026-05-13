import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/admin_models.dart';
import '../../../core/network/admin_api_service.dart';

class AdminState {
  final AsyncValue<AdminStats> stats;
  final AsyncValue<List<AdminUser>> users;
  final AsyncValue<List<AdminVenue>> venues;
  final AsyncValue<List<AdminOffer>> offers;
  final AsyncValue<List<AdminRedemption>> redemptions;
  final AsyncValue<List<ActivityLog>> activityLogs;
  final AsyncValue<List<Map<String, dynamic>>> notificationLogs;

  const AdminState({
    this.stats = const AsyncValue.loading(),
    this.users = const AsyncValue.loading(),
    this.venues = const AsyncValue.loading(),
    this.offers = const AsyncValue.loading(),
    this.redemptions = const AsyncValue.loading(),
    this.activityLogs = const AsyncValue.loading(),
    this.notificationLogs = const AsyncValue.loading(),
  });

  AdminState copyWith({
    AsyncValue<AdminStats>? stats,
    AsyncValue<List<AdminUser>>? users,
    AsyncValue<List<AdminVenue>>? venues,
    AsyncValue<List<AdminOffer>>? offers,
    AsyncValue<List<AdminRedemption>>? redemptions,
    AsyncValue<List<ActivityLog>>? activityLogs,
    AsyncValue<List<Map<String, dynamic>>>? notificationLogs,
  }) =>
      AdminState(
        stats: stats ?? this.stats,
        users: users ?? this.users,
        venues: venues ?? this.venues,
        offers: offers ?? this.offers,
        redemptions: redemptions ?? this.redemptions,
        activityLogs: activityLogs ?? this.activityLogs,
        notificationLogs: notificationLogs ?? this.notificationLogs,
      );
}

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminApiService _api;
  AdminNotifier(this._api) : super(const AdminState());

  Future<void> loadStats() async {
    state = state.copyWith(stats: const AsyncValue.loading());
    state = state.copyWith(stats: await AsyncValue.guard(_api.getStats));
  }

  Future<void> loadUsers() async {
    state = state.copyWith(users: const AsyncValue.loading());
    state = state.copyWith(users: await AsyncValue.guard(_api.getUsers));
  }

  Future<void> loadVenues() async {
    state = state.copyWith(venues: const AsyncValue.loading());
    state = state.copyWith(venues: await AsyncValue.guard(_api.getVenues));
  }

  Future<void> loadOffers() async {
    state = state.copyWith(offers: const AsyncValue.loading());
    state = state.copyWith(offers: await AsyncValue.guard(_api.getOffers));
  }

  Future<void> loadRedemptions() async {
    state = state.copyWith(redemptions: const AsyncValue.loading());
    state = state.copyWith(
        redemptions: await AsyncValue.guard(_api.getRedemptions));
  }

  Future<void> loadActivityLogs() async {
    state = state.copyWith(activityLogs: const AsyncValue.loading());
    state = state.copyWith(
        activityLogs: await AsyncValue.guard(_api.getActivityLogs));
  }

  Future<void> loadNotificationLogs() async {
    state = state.copyWith(notificationLogs: const AsyncValue.loading());
    state = state.copyWith(
        notificationLogs: await AsyncValue.guard(_api.getNotificationLogs));
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadStats(),
      loadUsers(),
      loadVenues(),
      loadOffers(),
      loadRedemptions(),
      loadActivityLogs(),
      loadNotificationLogs(),
    ]);
  }

  Future<void> sendTestPush({
    required String userId,
    required String title,
    required String body,
  }) =>
      _api.sendTestPush(userId: userId, title: title, body: body);

  Future<Map<String, dynamic>> getUserActivity(String userId) =>
      _api.getUserActivity(userId);

  Future<List<Map<String, dynamic>>> getVenueLogs(String venueId) =>
      _api.getVenueLogs(venueId);
}

final adminProvider =
    StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref.read(adminApiServiceProvider));
});
