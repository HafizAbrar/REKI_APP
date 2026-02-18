import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/venue.dart';
import '../../../core/services/venue_repository.dart';

final venueManagementProvider = StateNotifierProvider<VenueManagementNotifier, AsyncValue<List<Venue>>>((ref) {
  return VenueManagementNotifier(ref.read(venueRepositoryProvider));
});

class VenueManagementNotifier extends StateNotifier<AsyncValue<List<Venue>>> {
  final VenueRepository _repository;

  VenueManagementNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadVenues() async {
    state = const AsyncValue.loading();
    final result = await _repository.getAllVenues();
    state = result.when(
      success: (venues) => AsyncValue.data(venues),
      failure: (error) => AsyncValue.error(error, StackTrace.current),
    );
  }

  Future<bool> createVenue(Map<String, dynamic> venueData) async {
    final result = await _repository.createVenue(venueData);
    return result.when(
      success: (_) {
        loadVenues();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> updateLiveState(String id, {String? busyness, String? currentVibe}) async {
    final result = await _repository.updateLiveState(id, busyness: busyness, currentVibe: currentVibe);
    return result.when(
      success: (_) {
        loadVenues();
        return true;
      },
      failure: (_) => false,
    );
  }
}

final venueDetailProvider = FutureProvider.family<Venue, String>((ref, id) async {
  final repository = ref.read(venueRepositoryProvider);
  final result = await repository.getVenueById(id);
  return result.when(
    success: (venue) => venue,
    failure: (error) => throw Exception(error),
  );
});

final vibeSchedulesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, id) async {
  final repository = ref.read(venueRepositoryProvider);
  final result = await repository.getVibeSchedules(id);
  return result.when(
    success: (schedules) => schedules,
    failure: (error) => throw Exception(error),
  );
});

final currentVibeProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final repository = ref.read(venueRepositoryProvider);
  final result = await repository.getCurrentVibe(id);
  return result.when(
    success: (vibe) => vibe,
    failure: (error) => throw Exception(error),
  );
});
