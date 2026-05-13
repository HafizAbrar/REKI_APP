import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_repository.dart';
import '../../../core/utils/app_logger.dart';

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>(
        (ref) => LocationNotifier(ref.read(locationRepositoryProvider)));

// Sorted-by-distance venue IDs (populated after GPS fix)
final nearbyVenueIdsProvider = StateProvider<List<String>>((ref) => []);

class LocationState {
  final double? latitude;
  final double? longitude;
  final LocationPermissionStatus permissionStatus;
  final bool isTracking;
  final List<Map<String, dynamic>> nearbyVenues;
  final String? error;

  const LocationState({
    this.latitude,
    this.longitude,
    this.permissionStatus = LocationPermissionStatus.unknown,
    this.isTracking = false,
    this.nearbyVenues = const [],
    this.error,
  });

  bool get hasLocation => latitude != null && longitude != null;

  LocationState copyWith({
    double? latitude,
    double? longitude,
    LocationPermissionStatus? permissionStatus,
    bool? isTracking,
    List<Map<String, dynamic>>? nearbyVenues,
    String? error,
  }) =>
      LocationState(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        permissionStatus: permissionStatus ?? this.permissionStatus,
        isTracking: isTracking ?? this.isTracking,
        nearbyVenues: nearbyVenues ?? this.nearbyVenues,
        error: error,
      );
}

enum LocationPermissionStatus {
  unknown,
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationRepository _repository;

  LocationNotifier(this._repository) : super(const LocationState());

  /// Request permission and start tracking — handles all OS states gracefully
  Future<void> startTracking() async {
    // Check if location services are enabled at OS level
    if (!await Geolocator.isLocationServiceEnabled()) {
      state = state.copyWith(
        permissionStatus: LocationPermissionStatus.serviceDisabled,
        error: 'Location services are disabled. Please enable in Settings.',
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        permissionStatus: LocationPermissionStatus.deniedForever,
        error: 'Location permission permanently denied. Enable in app Settings.',
      );
      await _repository.updateLocationConsent(false);
      return;
    }

    if (permission == LocationPermission.denied) {
      state = state.copyWith(
        permissionStatus: LocationPermissionStatus.denied,
        error: 'Location permission denied.',
      );
      await _repository.updateLocationConsent(false);
      return;
    }

    // Permission granted
    state = state.copyWith(
      permissionStatus: LocationPermissionStatus.granted,
      isTracking: true,
    );
    await _repository.updateLocationConsent(true);

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _onPositionUpdate(position);

      // Stream updates every 50m
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50,
        ),
      ).listen(
        _onPositionUpdate,
        onError: (e) {
          appLogger.w('Location stream error: $e');
          state = state.copyWith(isTracking: false, error: e.toString());
        },
      );
    } catch (e) {
      appLogger.e('Location error', error: e);
      state = state.copyWith(isTracking: false, error: e.toString());
    }
  }

  Future<void> _onPositionUpdate(Position position) async {
    state = state.copyWith(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    // POST /users/location + POST /geofence/check in parallel
    await Future.wait([
      _repository.updateLocation(position.latitude, position.longitude),
      _checkGeofence(position.latitude, position.longitude),
    ]);
  }

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

  void stopTracking() => state = state.copyWith(isTracking: false);

  /// Distance in metres between current position and a lat/lng point
  double? distanceTo(double lat, double lng) {
    if (!state.hasLocation) return null;
    return Geolocator.distanceBetween(
        state.latitude!, state.longitude!, lat, lng);
  }
}
