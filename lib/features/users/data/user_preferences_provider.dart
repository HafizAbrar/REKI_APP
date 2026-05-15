import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/user_repository.dart';
import '../../../core/services/venue_repository.dart';
import '../../../core/models/venue.dart';

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
  return SavedVenuesNotifier(ref.read(userRepositoryProvider), ref.read(venueRepositoryProvider));
});

class SavedVenuesNotifier extends StateNotifier<AsyncValue<List<Venue>>> {
  final UserRepository _userRepo;
  final VenueRepository _venueRepo;

  SavedVenuesNotifier(this._userRepo, this._venueRepo) : super(const AsyncValue.loading()) {
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
    return result.when(success: (_) { load(); return true; }, failure: (_) => false);
  }

  Future<bool> saveVenue(String venueId) async {
    final result = await _userRepo.saveVenue(venueId);
    return result.when(success: (_) { load(); return true; }, failure: (_) => false);
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
