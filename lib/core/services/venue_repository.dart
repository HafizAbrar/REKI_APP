import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/venue.dart';
import '../network/venue_api_service.dart';
import '../utils/result.dart';

final venueRepositoryProvider = Provider<VenueRepository>((ref) {
  return VenueRepository(ref.read(venueApiServiceProvider));
});

class VenueRepository {
  final VenueApiService _apiService;

  VenueRepository(this._apiService);

  Future<Result<List<Venue>>> getAllVenues() async {
    try {
      final venues = await _apiService.getAllVenues();
      return Result.success(venues);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Venue>> createVenue(Map<String, dynamic> venueData) async {
    try {
      final venue = await _apiService.createVenue(venueData);
      return Result.success(venue);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Venue>> getVenueById(String id) async {
    try {
      final venue = await _apiService.getVenueById(id);
      return Result.success(venue);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Venue>> updateLiveState(String id, {String? busyness, String? currentVibe}) async {
    try {
      final venue = await _apiService.updateLiveState(id, busyness: busyness, currentVibe: currentVibe);
      return Result.success(venue);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> createVibeSchedule(String id, Map<String, dynamic> schedule) async {
    try {
      final result = await _apiService.createVibeSchedule(id, schedule);
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<List<Map<String, dynamic>>>> getVibeSchedules(String id) async {
    try {
      final schedules = await _apiService.getVibeSchedules(id);
      return Result.success(schedules);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> getCurrentVibe(String id) async {
    try {
      final vibe = await _apiService.getCurrentVibe(id);
      return Result.success(vibe);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
