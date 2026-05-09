import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_repository.dart';

// GET /analytics/popular-areas
final popularAreasProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final result = await ref.read(locationRepositoryProvider).getPopularAreas();
  return result.when(success: (d) => d, failure: (_) => []);
});

// Location + Geofence state notifier
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(ref.read(locationRepositoryProvider));
});

class LocationState {
  final double? latitude;
  final double? longitude;
  final bool consentGranted;
  final bool isTracking;
  final List<Map<String, dynamic>> nearbyVenues; // from geofence/check
  final String? error;

  const LocationState({
    this.latitude,
    this.longitude,
    this.consentGranted = false,
    this.isTracking = false,
    this.nearbyVenues = const [],
    this.error,
  });

  LocationState copyWith({
    double? latitude,
    double? longitude,
    bool? consentGranted,
    bool? isTracking,
    List<Map<String, dynamic>>? nearbyVenues,
    String? error,
  }) =>
      LocationState(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        consentGranted: consentGranted ?? this.consentGranted,
        isTracking: isTracking ?? this.isTracking,
        nearbyVenues: nearbyVenues ?? this.nearbyVenues,
        error: error,
      );
}

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationRepository _repository;

  LocationNotifier(this._repository) : super(const LocationState());

  // PUT /users/location-consent
  Future<bool> setLocationConsent(bool granted) async {
    final result = await _repository.updateLocationConsent(granted);
    return result.when(
      success: (_) {
        state = state.copyWith(consentGranted: granted);
        return true;
      },
      failure: (e) {
        state = state.copyWith(error: e);
        return false;
      },
    );
  }

  // POST /users/location — call after getting GPS position
  Future<void> updateLocation(double lat, double lng) async {
    state = state.copyWith(latitude: lat, longitude: lng);
    // Fire-and-forget: update server + check geofence in parallel
    await Future.wait([
      _repository.updateLocation(lat, lng),
      _checkGeofence(lat, lng),
    ]);
  }

  // POST /geofence/check
  Future<void> _checkGeofence(double lat, double lng) async {
    final result = await _repository.checkGeofence(lat, lng);
    result.when(
      success: (data) {
        final venues = data['nearbyVenues'] ?? data['venues'] ?? [];
        state = state.copyWith(
          nearbyVenues: List<Map<String, dynamic>>.from(venues as List),
        );
      },
      failure: (_) {},
    );
  }

  // Request device GPS permission + start tracking
  Future<void> startTracking() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        await setLocationConsent(false);
        return;
      }

      await setLocationConsent(true);
      state = state.copyWith(isTracking: true);

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await updateLocation(position.latitude, position.longitude);

      // Listen for position changes
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50, // update every 50m
        ),
      ).listen((pos) => updateLocation(pos.latitude, pos.longitude));
    } catch (e) {
      state = state.copyWith(error: e.toString(), isTracking: false);
    }
  }

  void stopTracking() {
    state = state.copyWith(isTracking: false);
  }
}
