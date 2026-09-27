import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart' show LocationAccuracy;
import '../../../core/services/location_service.dart';
import '../../venues/data/venue_management_provider.dart';
import '../data/intelligence_api_service.dart';
import '../data/recommendation_engine.dart';
import '../data/weather_service.dart';

final recommendationEngineProvider =
    Provider<RecommendationEngine>((ref) => RecommendationEngine());

/// Persisted user affinities (type/vibe weights from user interactions).
/// Record interactions via [UserAffinitiesNotifier.record].
final userAffinitiesProvider =
    StateNotifierProvider<UserAffinitiesNotifier, UserAffinities>((ref) {
  return UserAffinitiesNotifier();
});

class UserAffinitiesNotifier extends StateNotifier<UserAffinities> {
  static const _storageKey = 'user_affinities_v1';
  UserAffinitiesNotifier() : super(const UserAffinities()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      state = UserAffinities.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
  }

  /// Bumps affinity for a venue the user interacted with (save, check-in,
  /// redemption, extended view). [weight] 1.0 = strong (check-in/redemption),
  /// 0.25 = weak (view).
  Future<void> record({
    required String venueType,
    String? vibe,
    double weight = 1.0,
  }) async {
    state = UserAffinities(
      typeWeights: {
        ...state.typeWeights,
        venueType: (state.typeAffinity(venueType) + weight * 0.2)
      },
      vibeWeights: vibe == null
          ? state.vibeWeights
          : {
              ...state.vibeWeights,
              vibe: (state.vibeAffinity(vibe) + weight * 0.2)
            },
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }
}

/// Top-N personalised recommendations for the currently selected city.
final recommendationsProvider =
    FutureProvider<List<RecommendationResult>>((ref) async {
  final venues = ref.watch(venueManagementProvider).valueOrNull ?? [];
  final affinities = ref.watch(userAffinitiesProvider);

  var weather = WeatherCondition.overcast;
  double? latitude;
  double? longitude;
  try {
    final position = await LocationService().getCurrentPosition(
      accuracy: LocationAccuracy.low,
      timeLimit: const Duration(seconds: 5),
    );
    latitude = position.latitude;
    longitude = position.longitude;
    weather = await ref
        .watch(weatherServiceProvider)
        .currentCondition(position.latitude, position.longitude);
  } catch (_) {
    // Location/weather unavailable — neutral weighting.
  }

  if ((latitude == null || longitude == null) && venues.isNotEmpty) {
    latitude = venues.first.latitude;
    longitude = venues.first.longitude;
  }

  final backendScores = <String, double>{};
  if (latitude != null && longitude != null) {
    try {
      final ranked =
          await ref.read(intelligenceApiServiceProvider).recommendations(
                latitude: latitude,
                longitude: longitude,
                limit: 20,
              );
      for (final item in ranked) {
        backendScores[item.venueId] = item.score;
      }
    } catch (_) {
      // The local model remains the offline and degraded-service fallback.
    }
  }

  return ref.watch(recommendationEngineProvider).recommend(
        venues,
        affinities: affinities,
        weather: weather,
        backendScores: backendScores,
      );
});
