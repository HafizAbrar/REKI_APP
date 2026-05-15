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

// Filter state shared between VenueFilterScreen and HomeScreen
class FilterState {
  final String busyness;
  final Set<String> vibes;
  final bool offersOnly;

  const FilterState({
    this.busyness = '',
    this.vibes = const {},
    this.offersOnly = false,
  });

  bool get isActive => busyness.isNotEmpty || vibes.isNotEmpty || offersOnly;

  FilterState copyWith({String? busyness, Set<String>? vibes, bool? offersOnly}) => FilterState(
    busyness: busyness ?? this.busyness,
    vibes: vibes ?? this.vibes,
    offersOnly: offersOnly ?? this.offersOnly,
  );
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());
  void update({String? busyness, Set<String>? vibes, bool? offersOnly}) =>
      state = state.copyWith(busyness: busyness, vibes: vibes, offersOnly: offersOnly);
  void reset() => state = const FilterState();
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>(
  (_) => FilterNotifier(),
);

// Search provider — calls GET /venues/search?q=&city=
final venueSearchProvider = StateNotifierProvider<VenueSearchNotifier, AsyncValue<List<Venue>>>((ref) {
  return VenueSearchNotifier(ref.read(venueRepositoryProvider));
});

class VenueSearchNotifier extends StateNotifier<AsyncValue<List<Venue>>> {
  final VenueRepository _repository;
  VenueSearchNotifier(this._repository) : super(const AsyncValue.data([]));

  Future<void> search(String query, {String city = 'Manchester'}) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    final result = await _repository.searchVenues(query.trim(), city: city);
    state = result.when(
      success: (venues) => AsyncValue.data(venues),
      failure: (e) => AsyncValue.error(e, StackTrace.current),
    );
  }

  void clear() => state = const AsyncValue.data([]);
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
