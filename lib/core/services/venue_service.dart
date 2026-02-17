import 'dart:async';
import 'dart:math';
import '../models/venue.dart';
import '../constants/app_constants.dart';
import 'mock_data_service.dart';

class VenueService {
  static final VenueService _instance = VenueService._internal();
  factory VenueService() => _instance;
  VenueService._internal();

  List<Venue> _venues = [];
  Timer? _updateTimer;

  List<Venue> get venues => _venues;

  void initialize() {
    _venues = MockDataService.getManchesterVenues();
    _startPeriodicUpdates();
  }

  void _startPeriodicUpdates() {
    _updateTimer = Timer.periodic(
      const Duration(minutes: AppConstants.busynessUpdateInterval),
      (_) => _simulateBusynessChanges(),
    );
  }

  void _simulateBusynessChanges() {
    final random = Random();
    final busynessLevels = [AppConstants.quiet, AppConstants.moderate, AppConstants.busy];
    
    for (var venue in _venues) {
      if (random.nextBool()) {
        venue.busyness = busynessLevels[random.nextInt(busynessLevels.length)];
      }
    }
  }

  List<Venue> getVenuesByType(String type) {
    return _venues.where((v) => v.type == type).toList();
  }

  List<Venue> getVenuesWithOffers() {
    return _venues.where((v) => v.offers.isNotEmpty).toList();
  }

  Venue? getVenueById(String id) {
    try {
      return _venues.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateVenueBusyness(String venueId, String busyness) {
    final venue = getVenueById(venueId);
    if (venue != null) {
      venue.busyness = busyness;
    }
  }

  void updateVenueVibe(String venueId, String vibe) {
    final venue = getVenueById(venueId);
    if (venue != null && venue.availableVibes.contains(vibe)) {
      venue.currentVibe = vibe;
    }
  }

  void dispose() {
    _updateTimer?.cancel();
  }
}