import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as perm;

/// Service for handling GPS location permissions and coordinates.
class LocationService {
  /// Checks if location permissions are granted.
  Future<bool> hasLocationPermission() async {
    final status = await perm.Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  /// Requests location permission from the user.
  Future<bool> requestLocationPermission() async {
    final status = await perm.Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  /// Checks if location services are enabled on the device.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Gets the current position with high accuracy.
  /// Throws [LocationPermissionException] if permissions are denied.
  /// Throws [LocationServicesDisabledException] if location services are off.
  Future<Position> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    // Check permissions
    if (!await hasLocationPermission()) {
      final granted = await requestLocationPermission();
      if (!granted) {
        throw LocationPermissionException('Location permission denied');
      }
    }

    // Check if location services are enabled
    if (!await isLocationServiceEnabled()) {
      throw LocationServicesDisabledException('Location services are disabled');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: accuracy,
      timeLimit: timeLimit ?? const Duration(seconds: 10),
    );
  }

  /// Gets the last known position (faster, may be stale).
  Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }

  /// Opens app settings so user can manually enable permissions.
  Future<void> openAppSettings() async {
    await perm.openAppSettings();
  }

  /// Opens location settings on the device.
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}

/// Exception thrown when location permission is denied.
class LocationPermissionException implements Exception {
  final String message;
  LocationPermissionException(this.message);
  @override
  String toString() => 'LocationPermissionException: $message';
}

/// Exception thrown when location services are disabled.
class LocationServicesDisabledException implements Exception {
  final String message;
  LocationServicesDisabledException(this.message);
  @override
  String toString() => 'LocationServicesDisabledException: $message';
}
