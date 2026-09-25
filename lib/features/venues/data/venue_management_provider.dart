import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/venue.dart';
import '../../../core/network/venue_api_service.dart';
import '../../../core/services/venue_repository.dart';
import '../../../features/city_selection/presentation/city_selection_screen.dart';

final venueManagementProvider =
    StateNotifierProvider<VenueManagementNotifier, AsyncValue<List<Venue>>>(
        (ref) {
  ref.watch(selectedCityProvider);
  final notifier =
      VenueManagementNotifier(ref.read(venueRepositoryProvider), ref);
  Future.microtask(notifier.loadVenues);
  return notifier;
});

class VenueManagementNotifier extends StateNotifier<AsyncValue<List<Venue>>> {
  final VenueRepository _repository;
  final Ref _ref;

  VenueManagementNotifier(this._repository, this._ref)
      : super(const AsyncValue.loading());

  int _loadVersion = 0;
  bool _loading = false;
  Future<void> loadVenues({bool silent = false}) async {
    if (!mounted || (silent && _loading)) return;
    _loading = true;
    final version = ++_loadVersion;
    if (!silent) state = const AsyncValue.loading();
    try {
      final selectedCity = await _ref.read(selectedCityProvider.future);
      if (!mounted || version != _loadVersion) return;
      // Use live snapshot for initial load — cheaper than full venue list
      if (!silent) {
        try {
          final venueApi = _ref.read(venueApiServiceProvider);
          final snapshot =
              await venueApi.getLiveSnapshot(city: selectedCity?.slug);
          if (!mounted || version != _loadVersion) return;
          final raw =
              snapshot['venues'] ?? snapshot['data'] ?? snapshot['items'];
          if (raw is List && raw.isNotEmpty) {
            final venues = raw
                .map((j) {
                  try {
                    return Venue.fromJson(j as Map<String, dynamic>);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<Venue>()
                .toList();
            // The production snapshot is optimized for live status and may
            // omit coordinates. Do not expose those partial records to map
            // consumers; fall through to the full venue endpoint instead.
            final hasMapData =
                venues.every((venue) => venue.hasValidCoordinates);
            if (venues.isNotEmpty &&
                hasMapData &&
                mounted &&
                version == _loadVersion) {
              state = AsyncValue.data(venues);
              _loading = false;
              return;
            }
          }
        } catch (_) {
          // Snapshot unavailable — fall through to full venue list
        }
      }
      final result = await _repository.getAllVenues(cityId: selectedCity?.slug);
      if (!mounted || version != _loadVersion) return;
      state = result.when(
        success: (venues) => AsyncValue.data(venues),
        failure: (error) => silent && state.hasValue
            ? state
            : AsyncValue.error(error, StackTrace.current),
      );
    } catch (e, stack) {
      if (mounted && version == _loadVersion) {
        state = AsyncValue.error(e, stack);
      }
    } finally {
      if (version == _loadVersion) _loading = false;
    }
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

  Future<bool> updateLiveState(String id,
      {String? busyness, String? currentVibe}) async {
    final result = await _repository.updateLiveState(id,
        busyness: busyness, currentVibe: currentVibe);
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
  final Set<int> priceLevels;

  const FilterState({
    this.busyness = '',
    this.vibes = const {},
    this.offersOnly = false,
    this.priceLevels = const {},
  });

  bool get isActive =>
      busyness.isNotEmpty ||
      vibes.isNotEmpty ||
      offersOnly ||
      priceLevels.isNotEmpty;

  FilterState copyWith({
    String? busyness,
    Set<String>? vibes,
    bool? offersOnly,
    Set<int>? priceLevels,
  }) =>
      FilterState(
        busyness: busyness ?? this.busyness,
        vibes: vibes ?? this.vibes,
        offersOnly: offersOnly ?? this.offersOnly,
        priceLevels: priceLevels ?? this.priceLevels,
      );
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());
  void update({
    String? busyness,
    Set<String>? vibes,
    bool? offersOnly,
    Set<int>? priceLevels,
  }) =>
      state = state.copyWith(
        busyness: busyness,
        vibes: vibes,
        offersOnly: offersOnly,
        priceLevels: priceLevels,
      );
  void reset() => state = const FilterState();
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>(
  (_) => FilterNotifier(),
);

// Search provider — calls GET /venues/search?q=&city=
final venueSearchProvider =
    StateNotifierProvider<VenueSearchNotifier, AsyncValue<List<Venue>>>((ref) {
  ref.watch(selectedCityProvider);
  return VenueSearchNotifier(ref.read(venueRepositoryProvider), ref);
});

class VenueSearchNotifier extends StateNotifier<AsyncValue<List<Venue>>> {
  final VenueRepository _repository;
  final Ref _ref;
  int _request = 0;
  VenueSearchNotifier(this._repository, this._ref)
      : super(const AsyncValue.data([]));

  Future<void> search(String query, {String? city}) async {
    final request = ++_request;
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    final selectedCity = await _ref.read(selectedCityProvider.future);
    final cityId = city ?? selectedCity?.slug ?? 'Manchester';
    final result = await _repository.searchVenues(query.trim(), city: cityId);
    if (request != _request) return;
    if (!mounted) return;
    state = result.when(
      success: (venues) => AsyncValue.data(venues),
      failure: (e) => AsyncValue.error(e, StackTrace.current),
    );
  }

  void clear() {
    _request++;
    state = const AsyncValue.data([]);
  }
}

final venueDetailProvider =
    FutureProvider.family<Venue, String>((ref, id) async {
  final repository = ref.read(venueRepositoryProvider);
  final result = await repository.getVenueById(id);
  return result.when(
    success: (venue) => venue,
    failure: (error) => throw Exception(error),
  );
});
