import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/notification_preferences.dart';
import '../../../core/services/user_repository.dart';
import '../../../core/services/venue_repository.dart';
import '../../../core/services/offline_sync_service.dart';
import '../../../core/models/venue.dart';

// PUT /users/profile
final updateProfileProvider =
    StateNotifierProvider<UpdateProfileNotifier, AsyncValue<void>>(
  (ref) => UpdateProfileNotifier(ref.read(userRepositoryProvider), ref),
);

class UpdateProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final UserRepository _repository;
  final Ref _ref;

  UpdateProfileNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> update({
    String? name,
    String? phone,
    bool? locationEnabled,
    bool? backgroundLocationEnabled,
    String? avatarPath,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.updateProfile(
      name: name,
      phone: phone,
      locationEnabled: locationEnabled,
      backgroundLocationEnabled: backgroundLocationEnabled,
      avatarPath: avatarPath,
    );
    return result.when(
      success: (data) {
        state = const AsyncValue.data(null);
        // Refresh profile after update
        _ref.read(userProfileProvider.notifier).load();
        return true;
      },
      failure: (error) {
        state = AsyncValue.error(error, StackTrace.current);
        return false;
      },
    );
  }
}

// GET /users/preferences
final userPreferencesProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final result = await ref.read(userRepositoryProvider).getPreferences();
  return result.when(success: (data) => data, failure: (_) => null);
});

// Notifier for POST/PUT /users/preferences
final userPreferencesNotifierProvider =
    StateNotifierProvider<UserPreferencesNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return UserPreferencesNotifier(ref.read(userRepositoryProvider));
});

class UserPreferencesNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final UserRepository _repository;

  UserPreferencesNotifier(this._repository) : super(const AsyncValue.data(null));

  // POST /users/preferences - onboarding
  Future<bool> savePreferences(Map<String, dynamic> preferences) async {
    state = const AsyncValue.loading();
    final result = await _repository.savePreferences(preferences);
    return result.when(
      success: (data) {
        state = AsyncValue.data(data);
        return true;
      },
      failure: (error) {
        state = AsyncValue.error(error, StackTrace.current);
        return false;
      },
    );
  }

  // PUT /users/preferences - update
  Future<bool> updatePreferences(Map<String, dynamic> preferences) async {
    state = const AsyncValue.loading();
    final result = await _repository.updatePreferences(preferences);
    return result.when(
      success: (data) {
        state = AsyncValue.data(data);
        return true;
      },
      failure: (error) {
        state = AsyncValue.error(error, StackTrace.current);
        return false;
      },
    );
  }
}

// GET /users/saved-venues → resolves IDs to full Venue objects
final savedVenuesProvider = StateNotifierProvider<SavedVenuesNotifier, AsyncValue<List<Venue>>>((ref) {
  return SavedVenuesNotifier(
    ref.read(userRepositoryProvider),
    ref.read(venueRepositoryProvider),
    ref.read(offlineSyncServiceProvider),
  );
});

class SavedVenuesNotifier extends StateNotifier<AsyncValue<List<Venue>>> {
  final UserRepository _userRepo;
  final VenueRepository _venueRepo;
  final OfflineSyncService _syncService;

  SavedVenuesNotifier(this._userRepo, this._venueRepo, this._syncService)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _userRepo.getSavedVenues();
    final ids = result.when(
      success: (list) => list.map((e) => e['id']?.toString() ?? '').where((id) => id.isNotEmpty).toList(),
      failure: (_) => <String>[],
    );
    final venues = <Venue>[];
    for (final id in ids) {
      final r = await _venueRepo.getVenueById(id);
      r.when(success: venues.add, failure: (_) {});
    }
    state = AsyncValue.data(venues);
  }

  Future<bool> unsaveVenue(String venueId) async {
    final result = await _userRepo.unsaveVenue(venueId);
    if (result.when(success: (_) => true, failure: (_) => false)) {
      load();
      return true;
    }
    // Offline: queue and optimistically update local state
    await _syncService.queueUnsaveVenue(venueId);
    state = state.whenData((venues) => venues.where((v) => v.id != venueId).toList());
    return true;
  }

  Future<bool> saveVenue(String venueId) async {
    final result = await _userRepo.saveVenue(venueId);
    if (result.when(success: (_) => true, failure: (_) => false)) {
      load();
      return true;
    }
    // Offline: queue and optimistically update local state
    await _syncService.queueSaveVenue(venueId);
    return true;
  }
}

// GET /users/profile
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<Map<String, dynamic>>>(
  (ref) => UserProfileNotifier(ref.read(userRepositoryProvider)),
);

class UserProfileNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final UserRepository _repository;
  UserProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _repository.getProfile();
    state = result.when(
      success: AsyncValue.data,
      failure: (e) => AsyncValue.error(e, StackTrace.current),
    );
  }
}

// GET /users/redemptions
final redemptionsProvider = StateNotifierProvider<RedemptionsNotifier, AsyncValue<List<Map<String, dynamic>>>>(
  (ref) => RedemptionsNotifier(ref.read(userRepositoryProvider)),
);

class RedemptionsNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final UserRepository _repository;
  RedemptionsNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _repository.getRedemptions();
    state = result.when(
      success: (data) => AsyncValue.data(data),
      failure: (e) => AsyncValue.error(e, StackTrace.current),
    );
  }
}

// GET /users/notification-preferences
final notificationPreferencesProvider =
    StateNotifierProvider<NotificationPreferencesNotifier,
        AsyncValue<NotificationPreferences>>(
  (ref) => NotificationPreferencesNotifier(ref.read(userRepositoryProvider)),
);

class NotificationPreferencesNotifier
    extends StateNotifier<AsyncValue<NotificationPreferences>> {
  final UserRepository _repository;

  NotificationPreferencesNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _repository.getNotificationPreferences();
    state = result.when(
      success: AsyncValue.data,
      failure: (e) => AsyncValue.error(e, StackTrace.current),
    );
  }

  /// PUT /users/notification-preferences
  /// Accepts a [NotificationPreferences] with updated values via copyWith.
  Future<bool> update(NotificationPreferences preferences) async {
    final result = await _repository
        .updateNotificationPreferences(preferences.toUpdateJson());
    return result.when(
      success: (data) {
        state = AsyncValue.data(data);
        return true;
      },
      failure: (e) {
        state = AsyncValue.error(e, StackTrace.current);
        return false;
      },
    );
  }
}
