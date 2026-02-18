import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/venue.dart';
import 'api_client.dart';

final venueApiServiceProvider = Provider<VenueApiService>((ref) {
  return VenueApiService(ref.read(apiClientProvider));
});

class VenueApiService {
  final Dio _dio;

  VenueApiService(this._dio);

  // GET /venues - Get all venues
  Future<List<Venue>> getAllVenues() async {
    final response = await _dio.get('/venues');
    return (response.data as List).map((json) => Venue.fromJson(json)).toList();
  }

  // POST /venues - Create new venue
  Future<Venue> createVenue(Map<String, dynamic> venueData) async {
    final response = await _dio.post('/venues', data: venueData);
    return Venue.fromJson(response.data);
  }

  // GET /venues/{id} - Get venue by ID
  Future<Venue> getVenueById(String id) async {
    final response = await _dio.get('/venues/$id');
    return Venue.fromJson(response.data);
  }

  // PATCH /venues/{id}/live-state - Update venue live state
  Future<Venue> updateLiveState(String id, {String? busyness, String? currentVibe}) async {
    final response = await _dio.patch('/venues/$id/live-state', data: {
      if (busyness != null) 'busyness': busyness,
      if (currentVibe != null) 'currentVibe': currentVibe,
    });
    return Venue.fromJson(response.data);
  }

  // POST /venues/{id}/vibe-schedules - Create vibe schedule
  Future<Map<String, dynamic>> createVibeSchedule(String id, Map<String, dynamic> schedule) async {
    final response = await _dio.post('/venues/$id/vibe-schedules', data: schedule);
    return response.data;
  }

  // GET /venues/{id}/vibe-schedules - Get vibe schedules
  Future<List<Map<String, dynamic>>> getVibeSchedules(String id) async {
    final response = await _dio.get('/venues/$id/vibe-schedules');
    return List<Map<String, dynamic>>.from(response.data);
  }

  // GET /venues/{id}/current-vibe - Get current vibe
  Future<Map<String, dynamic>> getCurrentVibe(String id) async {
    final response = await _dio.get('/venues/$id/current-vibe');
    return response.data;
  }
}
