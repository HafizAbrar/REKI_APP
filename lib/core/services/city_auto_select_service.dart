import '../models/city.dart';
import 'city_selection_service.dart';
import 'location_service.dart';

/// Service for automatically detecting and selecting the user's city based on GPS location.
class CityAutoSelectService {
  final CitySelectionService _citySelectionService;
  final LocationService _locationService;

  CityAutoSelectService(this._citySelectionService, this._locationService);

  /// Attempts to auto-detect and select the user's city using GPS.
  /// Returns the detected city or null if detection fails.
  Future<City?> autoDetectAndSelectCity() async {
    try {
      final position = await _locationService.getCurrentPosition();
      return await _citySelectionService.autoDetectAndSelectCity(
        position.latitude,
        position.longitude,
      );
    } on LocationPermissionException {
      // Permission denied - return null, caller can prompt user
      return null;
    } on LocationServicesDisabledException {
      // Location services disabled - return null
      return null;
    } catch (e) {
      // Any other error (network, timeout, etc.) - fall back to last detected
      return await _getLastDetectedCity();
    }
  }

  /// Attempts to auto-detect city without selecting it (for preview/suggestions).
  Future<City?> detectCityOnly() async {
    try {
      final position = await _locationService.getCurrentPosition();
      // Try backend detection first
      City? detected = await _citySelectionService.detectCity(
        position.latitude,
        position.longitude,
      );
      // If backend failed, use local fallback

      return detected;
    } catch (e) {
      return null;
    }
  }

  /// Gets the last detected city from storage.
  Future<City?> _getLastDetectedCity() async {
    return await _citySelectionService.getLastDetectedCity();
  }

  /// Checks if auto-detection is possible (permissions granted, services enabled).
  Future<bool> canAutoDetect() async {
    final hasPermission = await _locationService.hasLocationPermission();
    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    return hasPermission && serviceEnabled;
  }

  /// Requests permission and attempts auto-detection in one call.
  /// Returns the detected city or null if user denies permission.
  Future<City?> requestPermissionAndDetect() async {
    final granted = await _locationService.requestLocationPermission();
    if (!granted) return null;

    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    return await autoDetectAndSelectCity();
  }
}
