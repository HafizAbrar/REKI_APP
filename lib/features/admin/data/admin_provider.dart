import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/admin_models.dart';
import '../../../core/network/admin_api_service.dart';

class AdminState {
  final AsyncValue<AdminStats> stats;
  final AsyncValue<RealtimeStats> realtimeStats;
  final AsyncValue<OfflineStats> offlineStats;
  final AsyncValue<List<AdminUser>> users;
  final AsyncValue<AdminVenuesPage> venues;
  final AsyncValue<AdminOffersPage> offers;
  final AsyncValue<AdminRedemptionsPage> redemptions;
  final AsyncValue<ActivityLogsPage> activityLogs;
  final AsyncValue<AdminNotificationsPage> notificationLogs;
  final AsyncValue<LocationStats> locationStats;

  const AdminState({
    this.stats = const AsyncValue.loading(),
    this.realtimeStats = const AsyncValue.loading(),
    this.offlineStats = const AsyncValue.loading(),
    this.users = const AsyncValue.loading(),
    this.venues = const AsyncValue.loading(),
    this.offers = const AsyncValue.loading(),
    this.redemptions = const AsyncValue.loading(),
    this.activityLogs = const AsyncValue.loading(),
    this.notificationLogs = const AsyncValue.loading(),
    this.locationStats = const AsyncValue.loading(),
  });

  AdminState copyWith({
    AsyncValue<AdminStats>? stats,
    AsyncValue<RealtimeStats>? realtimeStats,
    AsyncValue<OfflineStats>? offlineStats,
    AsyncValue<List<AdminUser>>? users,
    AsyncValue<AdminVenuesPage>? venues,
    AsyncValue<AdminOffersPage>? offers,
    AsyncValue<AdminRedemptionsPage>? redemptions,
    AsyncValue<ActivityLogsPage>? activityLogs,
    AsyncValue<AdminNotificationsPage>? notificationLogs,
    AsyncValue<LocationStats>? locationStats,
  }) =>
      AdminState(
        stats: stats ?? this.stats,
        realtimeStats: realtimeStats ?? this.realtimeStats,
        offlineStats: offlineStats ?? this.offlineStats,
        users: users ?? this.users,
        venues: venues ?? this.venues,
        offers: offers ?? this.offers,
        redemptions: redemptions ?? this.redemptions,
        activityLogs: activityLogs ?? this.activityLogs,
        notificationLogs: notificationLogs ?? this.notificationLogs,
        locationStats: locationStats ?? this.locationStats,
      );
}

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminApiService _api;
  AdminNotifier(this._api) : super(const AdminState());

  Future<void> loadStats() async {
    state = state.copyWith(stats: const AsyncValue.loading());
    state = state.copyWith(stats: await AsyncValue.guard(_api.getStats));
  }

  Future<void> loadRealtimeStats() async {
    state = state.copyWith(realtimeStats: const AsyncValue.loading());
    state = state.copyWith(realtimeStats: await AsyncValue.guard(_api.getRealtimeStats));
  }

  Future<void> loadOfflineStats() async {
    state = state.copyWith(offlineStats: const AsyncValue.loading());
    state = state.copyWith(offlineStats: await AsyncValue.guard(_api.getOfflineStats));
  }

  Future<void> loadUsers() async {
    state = state.copyWith(users: const AsyncValue.loading());
    state = state.copyWith(
      users: await AsyncValue.guard(() async => (await _api.getUsers()).users),
    );
  }

  Future<void> loadVenues({int page = 1}) async {
    state = state.copyWith(venues: const AsyncValue.loading());
    state = state.copyWith(venues: await AsyncValue.guard(() => _api.getVenues(page: page)));
  }

  Future<void> loadOffers({int page = 1}) async {
    state = state.copyWith(offers: const AsyncValue.loading());
    state = state.copyWith(offers: await AsyncValue.guard(() => _api.getOffers(page: page)));
  }

  Future<void> loadRedemptions({int page = 1}) async {
    state = state.copyWith(redemptions: const AsyncValue.loading());
    state = state.copyWith(redemptions: await AsyncValue.guard(() => _api.getRedemptions(page: page)));
  }

  Future<void> loadActivityLogs({int page = 1}) async {
    state = state.copyWith(activityLogs: const AsyncValue.loading());
    state = state.copyWith(activityLogs: await AsyncValue.guard(() => _api.getActivityLogs(page: page)));
  }

  Future<void> loadNotificationLogs({int page = 1}) async {
    state = state.copyWith(notificationLogs: const AsyncValue.loading());
    state = state.copyWith(notificationLogs: await AsyncValue.guard(() => _api.getNotificationLogs(page: page)));
  }

  Future<void> loadLocationStats() async {
    state = state.copyWith(locationStats: const AsyncValue.loading());
    state = state.copyWith(locationStats: await AsyncValue.guard(_api.getLocationStats));
  }

  /// Fetches all data in parallel with a single loading state update
  /// and a single data state update — avoids 20 sequential rebuilds.
  Future<void> loadAll() async {
    // Set everything to loading in one state update
    state = const AdminState();

    final results = await Future.wait([
      AsyncValue.guard(_api.getStats),
      AsyncValue.guard(_api.getRealtimeStats),
      AsyncValue.guard(_api.getOfflineStats),
      AsyncValue.guard(() async => (await _api.getUsers()).users),
      AsyncValue.guard(_api.getVenues),
      AsyncValue.guard(_api.getOffers),
      AsyncValue.guard(_api.getRedemptions),
      AsyncValue.guard(_api.getActivityLogs),
      AsyncValue.guard(_api.getNotificationLogs),
      AsyncValue.guard(_api.getLocationStats),
    ]);

    // Update state once with all results
    state = AdminState(
      stats:             results[0] as AsyncValue<AdminStats>,
      realtimeStats:     results[1] as AsyncValue<RealtimeStats>,
      offlineStats:      results[2] as AsyncValue<OfflineStats>,
      users:             results[3] as AsyncValue<List<AdminUser>>,
      venues:            results[4] as AsyncValue<AdminVenuesPage>,
      offers:            results[5] as AsyncValue<AdminOffersPage>,
      redemptions:       results[6] as AsyncValue<AdminRedemptionsPage>,
      activityLogs:      results[7] as AsyncValue<ActivityLogsPage>,
      notificationLogs:  results[8] as AsyncValue<AdminNotificationsPage>,
      locationStats:     results[9] as AsyncValue<LocationStats>,
    );
  }

  Future<TestPushResult> sendTestPush({
    required String userId,
    required String title,
    required String body,
  }) =>
      _api.sendTestPush(userId: userId, title: title, body: body);

  Future<UserActivityData> getUserActivity(String userId) =>
      _api.getUserActivity(userId);

  Future<VenueLogsData> getVenueLogs(String venueId) =>
      _api.getVenueLogs(venueId);

  Future<Map<String, dynamic>> getAdminProfile() =>
      _api.getAdminProfile();

  Future<Map<String, dynamic>> updateAdminProfile({
    String? name,
    String? phone,
    double? currentLat,
    double? currentLng,
    String? avatarPath,
  }) =>
      _api.updateAdminProfile(
        name: name,
        phone: phone,
        currentLat: currentLat,
        currentLng: currentLng,
        avatarPath: avatarPath,
      );
}

final adminProvider =
    StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref.read(adminApiServiceProvider));
});
