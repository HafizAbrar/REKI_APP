import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/venue_service.dart';
import '../../../core/models/venue.dart';

class VenueState {
  final List<Venue> venues;
  final List<Venue> filteredVenues;
  final String selectedFilter;
  final bool isLoading;

  VenueState({
    required this.venues,
    required this.filteredVenues,
    required this.selectedFilter,
    required this.isLoading,
  });

  VenueState copyWith({
    List<Venue>? venues,
    List<Venue>? filteredVenues,
    String? selectedFilter,
    bool? isLoading,
  }) {
    return VenueState(
      venues: venues ?? this.venues,
      filteredVenues: filteredVenues ?? this.filteredVenues,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class VenueNotifier extends StateNotifier<VenueState> {
  final VenueService _venueService;

  VenueNotifier(this._venueService) : super(VenueState(
    venues: [],
    filteredVenues: [],
    selectedFilter: 'All',
    isLoading: false,
  ));

  void initialize() {
    state = state.copyWith(isLoading: true);
    _venueService.initialize();
    final venues = _venueService.venues;
    state = state.copyWith(
      venues: venues,
      filteredVenues: venues,
      isLoading: false,
    );
  }

  void setFilter(String filter) {
    List<Venue> filtered;
    switch (filter) {
      case 'Bar':
        filtered = state.venues.where((v) => v.type == 'Bar').toList();
        break;
      case 'Restaurant':
        filtered = state.venues.where((v) => v.type == 'Restaurant').toList();
        break;
      case 'Club':
        filtered = state.venues.where((v) => v.type == 'Club').toList();
        break;
      case 'With Offers':
        filtered = state.venues.where((v) => v.offers.isNotEmpty).toList();
        break;
      default:
        filtered = state.venues;
    }
    state = state.copyWith(
      selectedFilter: filter,
      filteredVenues: filtered,
    );
  }

  void refreshVenues() {
    final venues = _venueService.venues;
    state = state.copyWith(
      venues: venues,
      filteredVenues: _applyCurrentFilter(venues),
    );
  }

  List<Venue> _applyCurrentFilter(List<Venue> venues) {
    switch (state.selectedFilter) {
      case 'Bar':
        return venues.where((v) => v.type == 'Bar').toList();
      case 'Restaurant':
        return venues.where((v) => v.type == 'Restaurant').toList();
      case 'Club':
        return venues.where((v) => v.type == 'Club').toList();
      case 'With Offers':
        return venues.where((v) => v.offers.isNotEmpty).toList();
      default:
        return venues;
    }
  }
}

final venueServiceProvider = Provider<VenueService>((ref) {
  return VenueService();
});

final venueProvider = StateNotifierProvider<VenueNotifier, VenueState>((ref) {
  final venueService = ref.watch(venueServiceProvider);
  return VenueNotifier(venueService);
});

final venueByIdProvider = Provider.family<Venue?, String>((ref, id) {
  final venueService = ref.watch(venueServiceProvider);
  return venueService.getVenueById(id);
});

final venuesByTypeProvider = Provider.family<List<Venue>, String>((ref, type) {
  final venueService = ref.watch(venueServiceProvider);
  return venueService.getVenuesByType(type);
});

final venuesWithOffersProvider = Provider<List<Venue>>((ref) {
  final venueService = ref.watch(venueServiceProvider);
  return venueService.getVenuesWithOffers();
});