import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final engagementAnalyticsProvider = Provider<EngagementAnalytics>((ref) {
  return EngagementAnalytics(FirebaseAnalytics.instance);
});

/// Phase 5 engagement events used to measure saves, participation and sessions.
/// Firebase automatically records session_start and engagement_time_msec.
class EngagementAnalytics {
  final FirebaseAnalytics _analytics;

  EngagementAnalytics(this._analytics);

  Future<void> venueSaved(String venueId, bool saved) => _log(
        saved ? 'venue_saved' : 'venue_unsaved',
        {'venue_id': venueId},
      );

  Future<void> venueViewed(String venueId, String source) => _log(
        'venue_viewed',
        {'venue_id': venueId, 'source': source},
      );

  Future<void> reviewSubmitted(String venueId, int rating) => _log(
        'review_submitted',
        {'venue_id': venueId, 'rating': rating},
      );

  Future<void> checkIn(String venueId) =>
      _log('venue_check_in', {'venue_id': venueId});

  Future<void> vibeAccuracyVote(String venueId, bool accurate) => _log(
        'vibe_accuracy_vote',
        {'venue_id': venueId, 'accurate': accurate ? 1 : 0},
      );

  Future<void> venueShared(String venueId, String channel) => _log(
        'venue_shared',
        {'venue_id': venueId, 'channel': channel},
      );

  Future<void> _log(String name, Map<String, Object> parameters) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (_) {
      // Analytics must never block a user action.
    }
  }
}
