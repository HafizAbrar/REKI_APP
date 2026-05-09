import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/user_repository.dart';

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

// GET /users/saved-venues
final savedVenuesProvider = StateNotifierProvider<SavedVenuesNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return SavedVenuesNotifier(ref.read(userRepositoryProvider));
});

class SavedVenuesNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final UserRepository _repository;

  SavedVenuesNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _repository.getSavedVenues();
    state = result.when(
      success: (data) => AsyncValue.data(data),
      failure: (error) => AsyncValue.error(error, StackTrace.current),
    );
  }

  // POST /users/saved-venues/{venueId}
  Future<bool> saveVenue(String venueId) async {
    final result = await _repository.saveVenue(venueId);
    return result.when(
      success: (_) { load(); return true; },
      failure: (_) => false,
    );
  }

  // DELETE /users/saved-venues/{venueId}
  Future<bool> unsaveVenue(String venueId) async {
    final result = await _repository.unsaveVenue(venueId);
    return result.when(
      success: (_) { load(); return true; },
      failure: (_) => false,
    );
  }
}

// GET /users/redemptions
final redemptionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final result = await ref.read(userRepositoryProvider).getRedemptions();
  return result.when(success: (data) => data, failure: (_) => []);
});
