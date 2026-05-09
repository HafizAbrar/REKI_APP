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

  // GET /venues - List venues with filters + pagination + personalization
  Future<Map<String, dynamic>> getAllVenues({
    String? category,
    String? busyness,
    String? vibe,
    String? cityId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get('/venues', queryParameters: {
      if (category != null) 'category': category,
      if (busyness != null) 'busyness': busyness,
      if (vibe != null) 'vibe': vibe,
      if (cityId != null) 'cityId': cityId,
      'page': page,
      'limit': limit,
    });
    return response.data as Map<String, dynamic>;
  }

  // GET /venues/search - Search venues by name, area, or tags
  Future<List<Venue>> searchVenues(String query, {String? cityId}) async {
    final response = await _dio.get('/venues/search', queryParameters: {
      'q': query,
      if (cityId != null) 'cityId': cityId,
    });
    final data = response.data is Map ? response.data['data'] ?? response.data['venues'] ?? response.data : response.data;
    return (data as List).map((json) => Venue.fromJson(json)).toList();
  }

  // GET /venues/filter-options - Get available filter options for a city
  Future<Map<String, dynamic>> getFilterOptions({String? cityId}) async {
    final response = await _dio.get('/venues/filter-options', queryParameters: {
      if (cityId != null) 'cityId': cityId,
    });
    return response.data as Map<String, dynamic>;
  }

  // GET /venues/trending - Top 5 trending venues by busyness
  Future<List<Venue>> getTrendingVenues({String? cityId}) async {
    final response = await _dio.get('/venues/trending', queryParameters: {
      if (cityId != null) 'cityId': cityId,
    });
    final data = response.data is Map ? response.data['data'] ?? response.data['venues'] ?? response.data : response.data;
    return (data as List).map((json) => Venue.fromJson(json)).toList();
  }

  // GET /venues/map-markers - Get map marker data with RAG colors
  Future<List<Map<String, dynamic>>> getMapMarkers({
    String? cityId,
    double? swLat, double? swLng,
    double? neLat, double? neLng,
  }) async {
    final response = await _dio.get('/venues/map-markers', queryParameters: {
      if (cityId != null) 'cityId': cityId,
      if (swLat != null) 'swLat': swLat,
      if (swLng != null) 'swLng': swLng,
      if (neLat != null) 'neLat': neLat,
      if (neLng != null) 'neLng': neLng,
    });
    final data = response.data is Map ? response.data['data'] ?? response.data : response.data;
    return List<Map<String, dynamic>>.from(data);
  }

  // GET /venues/{id} - Get venue detail by ID (kept for compatibility)
  Future<List<Venue>> getAllVenuesList() async {
    final response = await getAllVenues();
    final data = response['data'] ?? response['venues'] ?? [];
    return (data as List).map((json) => Venue.fromJson(json)).toList();
  }

  // POST /venues - Create new venue
  Future<Venue> createVenue(Map<String, dynamic> venueData) async {
    final response = await _dio.post('/venues', data: venueData);
    return Venue.fromJson(response.data);
  }

  // GET /venues/{id} - Get venue detail by ID
  Future<Venue> getVenueById(String id) async {
    final response = await _dio.get('/venues/$id');
    final data = response.data is Map && response.data['data'] != null
        ? response.data['data']
        : response.data;
    return Venue.fromJson(data);
  }

  // POST /venues/{id}/view - Track venue view
  Future<void> trackVenueView(String id) async {
    await _dio.post('/venues/$id/view');
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
