import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/venue.dart';
import '../../../core/services/venue_service.dart';

final venueProvider = StateNotifierProvider<VenueNotifier, VenueState>((ref) {
  return VenueNotifier();
});

class VenueNotifier extends StateNotifier<VenueState> {
  final VenueService _venueService = VenueService();
  
  VenueNotifier() : super(VenueState(
    venues: [],
    filteredVenues: [],
    selectedFilter: 'All',
    isLoading: false,
  ));

  void initialize() {
    _venueService.initialize();
    loadVenues();
  }

  void loadVenues() {
    state = state.copyWith(isLoading: true);
    
    final venues = _venueService.venues;
    state = state.copyWith(
      venues: venues,
      isLoading: false,
    );
    _applyFilter();
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
    _applyFilter();
  }

  void _applyFilter() {
    List<Venue> filtered;
    if (state.selectedFilter == 'All') {
      filtered = state.venues;
    } else if (state.selectedFilter == 'With Offers') {
      filtered = state.venues.where((v) => v.offers.isNotEmpty).toList();
    } else {
      filtered = state.venues.where((v) => v.type == state.selectedFilter).toList();
    }
    state = state.copyWith(filteredVenues: filtered);
  }

  void refreshVenues() {
    loadVenues();
  }

  @override
  void dispose() {
    _venueService.dispose();
    super.dispose();
  }
}

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