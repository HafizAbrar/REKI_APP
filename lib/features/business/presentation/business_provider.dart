import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/venue.dart';
import '../../../core/models/offer.dart';
import '../../../core/services/venue_service.dart';
import '../../../core/services/auth_service.dart';

final businessProvider = StateNotifierProvider<BusinessNotifier, BusinessState>((ref) {
  return BusinessNotifier();
});

class BusinessNotifier extends StateNotifier<BusinessState> {
  final VenueService _venueService = VenueService();
  final _authService = AuthService();
  
  BusinessNotifier() : super(BusinessState(
    managedVenue: null,
    isLoading: false,
  ));

  void initialize() {
    // For demo, business user manages The Alchemist
    final venue = _venueService.getVenueById('1');
    state = state.copyWith(managedVenue: venue);
  }

  void updateBusyness(String busyness) {
    if (state.managedVenue != null) {
      _venueService.updateVenueBusyness(state.managedVenue!.id, busyness);
      final updatedVenue = state.managedVenue!;
      updatedVenue.busyness = busyness;
      state = state.copyWith(managedVenue: updatedVenue);
    }
  }

  void updateVibe(String vibe) {
    if (state.managedVenue != null) {
      _venueService.updateVenueVibe(state.managedVenue!.id, vibe);
      final updatedVenue = state.managedVenue!;
      updatedVenue.currentVibe = vibe;
      state = state.copyWith(managedVenue: updatedVenue);
    }
  }

  void addOffer(Offer offer) {
    if (state.managedVenue != null) {
      final updatedVenue = state.managedVenue!;
      updatedVenue.offers.add(offer);
      state = state.copyWith(managedVenue: updatedVenue);
    }
  }

  void removeOffer(String offerId) {
    if (state.managedVenue != null) {
      final updatedVenue = state.managedVenue!;
      updatedVenue.offers.removeWhere((o) => o.id == offerId);
      state = state.copyWith(managedVenue: updatedVenue);
    }
  }
}

class BusinessState {
  final Venue? managedVenue;
  final bool isLoading;

  BusinessState({
    required this.managedVenue,
    required this.isLoading,
  });

  BusinessState copyWith({
    Venue? managedVenue,
    bool? isLoading,
  }) {
    return BusinessState(
      managedVenue: managedVenue ?? this.managedVenue,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}