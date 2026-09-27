import 'dart:math';
import '../../../core/models/venue.dart';

/// Phase 7 — Smart Recommendations.
///
/// User interaction signals used as the collaborative-filtering input on the
/// client (saves, check-ins, redemptions, views by venue type & vibe). A full
/// item-item matrix lives on the backend; optional server-side scores can be
/// merged via [RecommendationEngine.recommend]'s `backendScores` parameter.
class UserAffinities {
  final Map<String, double> typeWeights;
  final Map<String, double> vibeWeights;

  const UserAffinities({
    this.typeWeights = const {},
    this.vibeWeights = const {},
  });

  double typeAffinity(String type) => typeWeights[type] ?? 0.0;
  double vibeAffinity(String vibe) => vibeWeights[vibe] ?? 0.0;

  factory UserAffinities.fromJson(Map<String, dynamic> json) => UserAffinities(
        typeWeights: (json['typeWeights'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
            const {},
        vibeWeights: (json['vibeWeights'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
            const {},
      );

  Map<String, dynamic> toJson() =>
      {'typeWeights': typeWeights, 'vibeWeights': vibeWeights};
}

/// Simplified weather context for weather-aware ranking.
enum WeatherCondition { clear, rain, snow, overcast, extreme }

enum TimeOfDay { morning, afternoon, evening, lateNight }

TimeOfDay timeOfDayFor(DateTime t) {
  final h = t.hour;
  if (h >= 6 && h < 12) return TimeOfDay.morning;
  if (h >= 12 && h < 17) return TimeOfDay.afternoon;
  if (h >= 17 && h < 23) return TimeOfDay.evening;
  return TimeOfDay.lateNight;
}

class RecommendationResult {
  final Venue venue;
  final double score;
  final String reason;

  const RecommendationResult(this.venue, this.score, this.reason);
}

/// Collaborative-filtering × time-of-day × weather-aware scoring.
///
/// Pure Dart, deterministic given inputs — fully unit-testable.
class RecommendationEngine {
  final DateTime Function() now;
  RecommendationEngine({DateTime Function()? clock})
      : now = clock ?? DateTime.now;

  /// Weights for venue types by time of day (e.g. brunch spots in the
  /// morning, bars/clubs late at night).
  static const Map<TimeOfDay, Map<String, double>> _timeTypeWeights = {
    TimeOfDay.morning: {'cafe': 1.2, 'restaurant': 0.9, 'bar': 0.3, 'club': 0.1},
    TimeOfDay.afternoon: {'cafe': 0.9, 'restaurant': 1.1, 'bar': 0.7, 'club': 0.2},
    TimeOfDay.evening: {'cafe': 0.5, 'restaurant': 1.2, 'bar': 1.2, 'club': 1.0},
    TimeOfDay.lateNight: {'cafe': 0.1, 'restaurant': 0.4, 'bar': 1.0, 'club': 1.3},
  };

  /// Weather boosts outdoor/party venues when clear, and cosy indoor venues
  /// (cafes, pubs, restaurants) when it rains or snows.
  static double _weatherBoost(Venue v, WeatherCondition w) {
    switch (w) {
      case WeatherCondition.clear:
        return v.currentVibe == 'party' || v.currentVibe == 'energetic'
            ? 1.35
            : 1.05;
      case WeatherCondition.rain:
      case WeatherCondition.snow:
        return (v.type == 'cafe' || v.type == 'restaurant' ||
                v.currentVibe == 'chill' || v.currentVibe == 'romantic')
            ? 1.6
            : 0.6;
      case WeatherCondition.overcast:
        return 1.0;
      case WeatherCondition.extreme:
        return v.currentVibe == 'chill' ? 1.1 : 0.7;
    }
  }

  /// Scores a single venue. Higher is better.
  double score(
    Venue venue, {
    UserAffinities affinities = const UserAffinities(),
    WeatherCondition weather = WeatherCondition.overcast,
    double backendScore = 0,
  }) {
    final tod = timeOfDayFor(now());
    var s = 1.0;

    s *= 1.0 + min(affinities.typeAffinity(venue.type), 2.0) * 0.2;
    s *= 1.0 + min(affinities.vibeAffinity(venue.currentVibe), 2.0) * 0.2;
    s *= _timeTypeWeights[tod]?[_normaliseType(venue.type)] ?? 1.0;
    s *= _weatherBoost(venue, weather);
    if (venue.activeOffersCount > 0) s *= 1.1; // live offers are attractive
    if (backendScore != 0) s *= 1.0 + backendScore.clamp(-0.5, 2.0);
    return s;
  }

  List<RecommendationResult> recommend(
    List<Venue> venues, {
    UserAffinities affinities = const UserAffinities(),
    WeatherCondition weather = WeatherCondition.overcast,
    Map<String, double> backendScores = const {},
    int limit = 10,
  }) {
    final results = [
      for (final v in venues)
        RecommendationResult(
            v,
            score(v,
                affinities: affinities,
                weather: weather,
                backendScore: backendScores[v.id] ?? 0),
            _reason(v))
    ];
    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(limit).toList();
  }

  String _reason(Venue v) {
    const busyness = {
      'quiet': "It's quiet right now",
      'moderate': 'Lively but not packed',
    };
    if (v.activeOffersCount > 0) {
      return '${v.activeOffersCount} live offer${v.activeOffersCount > 1 ? 's' : ''}';
    }
    return busyness[v.busyness] ?? 'Matches your vibe';
  }

  String _normaliseType(String type) =>
      _timeTypeWeights[TimeOfDay.evening]!.containsKey(type) ? type : 'restaurant';
}
