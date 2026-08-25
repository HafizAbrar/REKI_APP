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
  Future<List<Venue>> searchVenues(String query, {String? city}) async {
    final response = await _dio.get('/venues/search', queryParameters: {
      'q': query,
      if (city != null) 'city': city,
    });
    final data = response.data;
    dynamic raw;
    if (data is Map) {
      raw = data['venues'] ?? data['data'] ?? data['results'] ?? [];
    } else if (data is List) {
      raw = data;
    } else {
      raw = [];
    }
    final result = <Venue>[];
    for (final json in raw as List) {
      try {
        result.add(Venue.fromJson(json as Map<String, dynamic>));
      } catch (_) {}
    }
    return result;
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
    final data = response.data is Map
        ? response.data['data'] ?? response.data['venues'] ?? response.data
        : response.data;
    return (data as List).map((json) => Venue.fromJson(json)).toList();
  }

  // GET /venues/map-markers - Get map marker data with RAG colors
  Future<List<Map<String, dynamic>>> getMapMarkers({
    String? cityId,
    double? swLat,
    double? swLng,
    double? neLat,
    double? neLng,
  }) async {
    final response = await _dio.get('/venues/map-markers', queryParameters: {
      if (cityId != null) 'cityId': cityId,
      if (swLat != null) 'swLat': swLat,
      if (swLng != null) 'swLng': swLng,
      if (neLat != null) 'neLat': neLat,
      if (neLng != null) 'neLng': neLng,
    });
    final data = response.data is Map
        ? response.data['data'] ?? response.data
        : response.data;
    return List<Map<String, dynamic>>.from(data);
  }

  // GET /venues - returns { venues: [], count, pagination, city }
  Future<List<Venue>> getAllVenuesList() async {
    final response = await getAllVenues();
    dynamic raw = response['venues'] ?? response['data'] ?? response;
    if (raw is Map) {
      raw = raw['venues'] ?? raw['items'] ?? raw['data'] ?? [];
    }
    if (raw is! List) return [];
    final result = <Venue>[];
    for (final json in raw) {
      try {
        result.add(Venue.fromJson(json as Map<String, dynamic>));
      } catch (e) {
        // ignore malformed venue
      }
    }
    return result;
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

  // POST /venues/{id}/vibe-check - Submit a vibe check score (1-5)
  Future<Map<String, dynamic>> submitVibeCheck(
      String venueId, int score) async {
    final response =
        await _dio.post('/venues/$venueId/vibe-check', data: {'score': score});
    return response.data as Map<String, dynamic>;
  }

  // POST /venues/{id}/view - Track venue view
  Future<void> trackVenueView(String id) async {
    await _dio.post('/venues/$id/view');
  }

  // PATCH /venues/{id}/live-state - Update venue live state
  Future<Venue> updateLiveState(String id,
      {String? busyness, String? currentVibe}) async {
    final response = await _dio.patch('/venues/$id/live-state', data: {
      if (busyness != null) 'busyness': busyness,
      if (currentVibe != null) 'currentVibe': currentVibe,
    });
    return Venue.fromJson(response.data);
  }

  // GET /venues/{id}/vibe-schedules - Get weekly vibe schedule
  Future<List<Map<String, dynamic>>> getVibeSchedules(String venueId) async {
    final response = await _dio.get('/venues/$venueId/vibe-schedules');
    final data = response.data;
    if (data is List) return List<Map<String, dynamic>>.from(data);
    if (data is Map) {
      final list = data['schedules'] ?? data['data'] ?? data['results'] ?? [];
      return List<Map<String, dynamic>>.from(list as List);
    }
    return [];
  }

  // POST /sync/queue - Submit offline action queue for processing
  Future<Map<String, dynamic>> submitSyncQueue(
      String deviceId, List<Map<String, dynamic>> actions) async {
    final response = await _dio.post('/sync/queue', data: {
      'deviceId': deviceId,
      'actions': actions,
    });
    return response.data as Map<String, dynamic>;
  }

  // GET /venues/{id}/offers - Get offers for a specific venue
  Future<List<Map<String, dynamic>>> getVenueOffers(String venueId) async {
    final response = await _dio.get('/venues/$venueId/offers');
    final data = response.data;
    if (data is List) return List<Map<String, dynamic>>.from(data);
    if (data is Map) {
      final list = data['offers'] ?? data['data'] ?? data['results'] ?? [];
      return List<Map<String, dynamic>>.from(list as List);
    }
    return [];
  }
}
