import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/location_api_service.dart';
import '../utils/error_handler.dart';
import '../utils/result.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository(ref.read(locationApiServiceProvider));
});

class LocationRepository {
  final LocationApiService _api;
  LocationRepository(this._api);

  Future<Result<Map<String, dynamic>>> updateLocation(double lat, double lng) async {
    try {
      return Result.success(await _api.updateLocation(latitude: lat, longitude: lng));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<Map<String, dynamic>>> updateLocationConsent(bool granted) async {
    try {
      return Result.success(await _api.updateLocationConsent(granted));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<Map<String, dynamic>>> checkGeofence(double lat, double lng) async {
    try {
      return Result.success(await _api.checkGeofence(latitude: lat, longitude: lng));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<List<Map<String, dynamic>>>> getPopularAreas() async {
    try {
      return Result.success(await _api.getPopularAreas());
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }
}
