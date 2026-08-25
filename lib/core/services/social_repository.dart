import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_models.dart';
import '../models/user.dart';
import '../network/api_client.dart';
import 'auth_service.dart';
import 'engagement_analytics.dart';
import 'local_database.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepository(
    ref.read(apiClientProvider),
    LocalDatabase(),
    ref.read(engagementAnalyticsProvider),
  );
});

/// Local-first Phase 5 repository.
///
/// The API calls define the cloud contract. A missing/unavailable Phase 5
/// backend never blocks the user: local data remains usable and is merged with
/// cloud data when those endpoints are available.
class SocialRepository {
  final Dio _dio;
  final LocalDatabase _db;
  final EngagementAnalytics _analytics;

  SocialRepository(this._dio, this._db, this._analytics);

  Future<void> recordVisit(String venueId, String venueName,
      {String source = 'home'}) async {
    final viewedAt = DateTime.now();
    await _db.addVenueVisit(venueId, venueName, visitedAt: viewedAt);
    await _analytics.venueViewed(venueId, source);
    if (!_isSignedIn) return;
    try {
      await _dio.post('/users/history/venues/$venueId', data: {
        'viewedAt': viewedAt.toUtc().toIso8601String(),
        'source': source,
      });
    } catch (error) {
      if (!_isRetryable(error)) rethrow;
      await _queue('venue_history_view', {
        'venueId': venueId,
        'viewedAt': viewedAt.toUtc().toIso8601String(),
        'source': source,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final response = await _dio.get('/users/history/venues');
      final body = response.data;
      final raw = body is Map
          ? (body['venues'] ?? body['history'] ?? body['items'] ?? body['data'])
          : body;
      if (raw is List) {
        for (final item in raw.whereType<Map>()) {
          final data = Map<String, dynamic>.from(item);
          final venue = data['venue'] is Map
              ? Map<String, dynamic>.from(data['venue'] as Map)
              : const <String, dynamic>{};
          final id = (data['venueId'] ?? data['venue_id'] ?? venue['id'] ?? '')
              .toString();
          if (id.isEmpty) continue;
          final name = (data['venueName'] ??
                  data['venue_name'] ??
                  venue['name'] ??
                  'Venue')
              .toString();
          final viewedAt = DateTime.tryParse((data['viewedAt'] ??
                  data['visitedAt'] ??
                  data['lastViewedAt'] ??
                  data['createdAt'] ??
                  '')
              .toString());
          await _db.addVenueVisit(id, name, visitedAt: viewedAt);
        }
      }
    } catch (_) {
      // Fall back to the device history.
    }
    return _db.getVenueHistory();
  }

  Future<void> clearHistory() async {
    if (!_isSignedIn) {
      await _db.clearVenueHistory();
      return;
    }
    try {
      await _dio.delete('/users/history/venues');
    } catch (error) {
      if (!_isRetryable(error)) rethrow;
      await _queue('history_clear', const {});
    }
    await _db.clearVenueHistory();
  }

  Future<VenueReviewFeed> getReviews(String venueId) async {
    final byId = <String, VenueReview>{};
    VenueReviewSummary? serverSummary;
    try {
      final response = await _dio.get('/venues/$venueId/reviews',
          queryParameters: {'page': 1, 'limit': 50});
      final raw = response.data is Map
          ? (response.data['reviews'] ?? response.data['data'] ?? [])
          : response.data;
      if (response.data is Map && response.data['summary'] is Map) {
        serverSummary = VenueReviewSummary.fromJson(
            Map<String, dynamic>.from(response.data['summary'] as Map));
      }
      if (raw is List) {
        for (final item in raw.whereType<Map>()) {
          final review = VenueReview.fromJson(Map<String, dynamic>.from(item));
          if (review.id.isNotEmpty) byId[review.id] = review;
        }
      }
    } catch (_) {
      // Use cached reviews while offline.
    }
    for (final row in await _db.getReviews(venueId)) {
      final review = _reviewFromRow(row);
      byId.putIfAbsent(review.id, () => review);
    }
    final reviews = byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return VenueReviewFeed(
      reviews: reviews,
      summary: serverSummary ?? VenueReviewFeed.fromReviews(reviews).summary,
    );
  }

  Future<VenueReview> submitReview({
    required String venueId,
    required int rating,
    required String text,
    required bool vibeAccurate,
  }) async {
    final user = AuthService().currentUser;
    final now = DateTime.now();
    var review = VenueReview(
      id: 'local-${now.microsecondsSinceEpoch}',
      venueId: venueId,
      userName: user?.name ?? 'REKI user',
      userAvatarUrl: user?.profilePicture,
      rating: rating,
      text: text.trim(),
      vibeAccurate: vibeAccurate,
      createdAt: now,
      isMine: true,
    );
    try {
      final response = await _dio.post('/venues/$venueId/reviews', data: {
        'rating': rating,
        'text': text.trim(),
        'vibeAccurate': vibeAccurate,
      });
      if (response.data is Map) {
        final raw = response.data['review'] ?? response.data;
        if (raw is Map) {
          review = VenueReview.fromJson({
            ...Map<String, dynamic>.from(raw),
            'venueId': venueId,
            'isMine': true,
          });
        }
      }
    } catch (error) {
      if (!_isRetryable(error)) rethrow;
      await _queue('review_create', {
        'localId': review.id,
        'venueId': venueId,
        'rating': rating,
        'text': text.trim(),
        'vibeAccurate': vibeAccurate,
      });
    }
    await _db.upsertReview(_reviewRow(review));
    await _analytics.reviewSubmitted(venueId, rating);
    return review;
  }

  Future<VenueReview> updateReview({
    required VenueReview review,
    required int rating,
    required String text,
    required bool vibeAccurate,
  }) async {
    var updated = VenueReview(
      id: review.id,
      venueId: review.venueId,
      userName: review.userName,
      userAvatarUrl: review.userAvatarUrl,
      rating: rating,
      text: text.trim(),
      vibeAccurate: vibeAccurate,
      createdAt: review.createdAt,
      isMine: true,
    );
    try {
      final response = await _dio.patch('/reviews/${review.id}', data: {
        'rating': rating,
        'text': text.trim(),
        'vibeAccurate': vibeAccurate,
      });
      final body = response.data;
      final raw = body is Map ? (body['review'] ?? body) : null;
      if (raw is Map) {
        updated = VenueReview.fromJson({
          ...Map<String, dynamic>.from(raw),
          'venueId': review.venueId,
          'isMine': true,
        });
      }
    } catch (error) {
      if (!_isRetryable(error)) rethrow;
      await _queue('review_update', {
        'reviewId': review.id,
        'venueId': review.venueId,
        'rating': rating,
        'text': text.trim(),
        'vibeAccurate': vibeAccurate,
      });
    }
    await _db.upsertReview(_reviewRow(updated));
    return updated;
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _dio.delete('/reviews/$reviewId');
    } catch (error) {
      if (!_isRetryable(error)) rethrow;
      await _queue('review_delete', {'reviewId': reviewId});
    }
    await _db.deleteReview(reviewId);
  }

  Future<Map<String, dynamic>> voteVibeAccuracy(String venueId, bool accurate,
      {String? observedVibe}) async {
    final votedAt = DateTime.now().toUtc().toIso8601String();
    final data = {
      'accurate': accurate,
      if (observedVibe != null && observedVibe.isNotEmpty)
        'observedVibe': observedVibe,
      'votedAt': votedAt,
    };
    try {
      final response = await _dio.post(
        '/venues/$venueId/vibe-accuracy-votes',
        data: data,
      );
      await _analytics.vibeAccuracyVote(venueId, accurate);
      return response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : const <String, dynamic>{};
    } catch (error) {
      if (!_isRetryable(error)) rethrow;
      await _queue('vibe_accuracy_vote', {'venueId': venueId, ...data});
      await _analytics.vibeAccuracyVote(venueId, accurate);
      return {'queued': true, 'userVote': accurate};
    }
  }

  Future<VenueCheckIn> checkIn(
    String venueId,
    String venueName, {
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    final now = DateTime.now();
    var checkIn = VenueCheckIn(
      id: 'local-${now.microsecondsSinceEpoch}',
      venueId: venueId,
      venueName: venueName,
      checkedInAt: now,
    );
    try {
      final response = await _dio.post('/venues/$venueId/check-ins', data: {
        'lat': latitude,
        'lng': longitude,
        'accuracy': accuracy,
        'timestamp': now.toUtc().toIso8601String(),
      });
      final body = response.data;
      final raw = body is Map ? (body['checkIn'] ?? body) : null;
      if (raw is Map) {
        checkIn = VenueCheckIn.fromJson({
          ...Map<String, dynamic>.from(raw),
          'venueId': venueId,
          'venueName': venueName,
          'pointsAwarded': body is Map ? body['pointsAwarded'] : 0,
        });
      }
    } catch (error) {
      if (!_isRetryable(error)) rethrow;
      await _queue('check_in', {
        'localId': checkIn.id,
        'venueId': venueId,
        'venueName': venueName,
        'lat': latitude,
        'lng': longitude,
        'accuracy': accuracy,
        'timestamp': now.toUtc().toIso8601String(),
      });
    }
    await _db.addCheckIn(checkIn.id, venueId, venueName,
        checkedInAt: checkIn.checkedInAt);
    await _analytics.checkIn(venueId);
    return checkIn;
  }

  Future<List<VenueCheckIn>> getCheckIns() async {
    final byId = <String, VenueCheckIn>{};
    try {
      final response = await _dio.get('/users/check-ins');
      final body = response.data;
      final raw = body is Map
          ? (body['checkIns'] ?? body['items'] ?? body['data'])
          : body;
      if (raw is List) {
        for (final item in raw.whereType<Map>()) {
          final checkIn =
              VenueCheckIn.fromJson(Map<String, dynamic>.from(item));
          if (checkIn.id.isEmpty) continue;
          byId[checkIn.id] = checkIn;
          await _db.addCheckIn(checkIn.id, checkIn.venueId, checkIn.venueName,
              checkedInAt: checkIn.checkedInAt);
        }
      }
    } catch (_) {
      // Use the local check-in cache.
    }
    final rows = await _db.getCheckIns();
    for (final row in rows) {
      final checkIn = VenueCheckIn(
        id: row['id'] as String,
        venueId: row['venue_id'] as String,
        venueName: row['venue_name'] as String,
        checkedInAt:
            DateTime.fromMillisecondsSinceEpoch(row['checked_in_at'] as int),
      );
      byId.putIfAbsent(checkIn.id, () => checkIn);
    }
    return byId.values.toList()
      ..sort((a, b) => b.checkedInAt.compareTo(a.checkedInAt));
  }

  Future<List<Achievement>> getAchievements() async {
    try {
      final response = await _dio.get('/users/achievements');
      final body = response.data;
      final raw = body is Map ? (body['achievements'] ?? body['data']) : body;
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map(
                (item) => Achievement.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (_) {
      // Derive progress from local activity while offline.
    }
    final checkIns = await _db.getCheckIns();
    final reviews = await _db.getReviewCount();
    final saved = await _db.getSavedVenueIds();
    final uniqueVenues =
        checkIns.map((e) => e['venue_id'].toString()).toSet().length;
    return [
      Achievement(
          id: 'first-night',
          title: 'First Night Out',
          description: 'Check in at your first venue',
          icon: '🎉',
          progress: checkIns.length,
          target: 1),
      Achievement(
          id: 'explorer',
          title: 'City Explorer',
          description: 'Check in at 5 different venues',
          icon: '🧭',
          progress: uniqueVenues,
          target: 5),
      Achievement(
          id: 'critic',
          title: 'Vibe Critic',
          description: 'Write 3 venue reviews',
          icon: '⭐',
          progress: reviews,
          target: 3),
      Achievement(
          id: 'collector',
          title: 'The Collector',
          description: 'Save 10 venues',
          icon: '🔖',
          progress: saved.length,
          target: 10),
      Achievement(
          id: 'regular',
          title: 'REKI Regular',
          description: 'Complete 10 check-ins',
          icon: '🔥',
          progress: checkIns.length,
          target: 10),
    ];
  }

  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      final response = await _dio
          .get('/leaderboards', queryParameters: {'period': 'weekly'});
      final raw = response.data is Map
          ? (response.data['entries'] ?? response.data['data'] ?? [])
          : response.data;
      if (raw is List) {
        return raw.asMap().entries.map((entry) {
          final data = Map<String, dynamic>.from(entry.value as Map);
          final parsed = LeaderboardEntry.fromJson(data);
          return LeaderboardEntry(
            rank: parsed.rank == 0 ? entry.key + 1 : parsed.rank,
            name: parsed.name,
            points: parsed.points,
            isCurrentUser: parsed.isCurrentUser,
          );
        }).toList();
      }
    } catch (_) {
      // Show an honest personal score until a cloud leaderboard is available.
    }
    final checkIns = await _db.getCheckIns();
    final reviews = await _db.getReviewCount();
    final saved = await _db.getSavedVenueIds();
    final points = checkIns.length * 20 + reviews * 10 + saved.length * 5;
    return [
      LeaderboardEntry(
        rank: 1,
        name: AuthService().currentUser?.name ?? 'You',
        points: points,
        isCurrentUser: true,
      ),
    ];
  }

  Future<int> trackShare(String venueId, {String channel = 'other'}) async {
    if (!_isSignedIn) return 0;
    final sharedAt = DateTime.now().toUtc().toIso8601String();
    try {
      final response = await _dio.post('/venues/$venueId/shares', data: {
        'channel': channel,
        'sharedAt': sharedAt,
      });
      await _analytics.venueShared(venueId, channel);
      return response.data is Map
          ? (response.data['pointsAwarded'] as num?)?.toInt() ?? 0
          : 0;
    } catch (error) {
      if (!_isRetryable(error)) return 0;
      await _queue('venue_share', {
        'venueId': venueId,
        'channel': channel,
        'sharedAt': sharedAt,
      });
      await _analytics.venueShared(venueId, channel);
      return 0;
    }
  }

  bool get _isSignedIn {
    final user = AuthService().currentUser;
    return user != null && !user.isGuest;
  }

  bool _isRetryable(Object error) {
    if (error is! DioException) return false;
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return true;
    }
    final status = error.response?.statusCode;
    return status == 429 || (status != null && status >= 500);
  }

  Future<void> _queue(String action, Map<String, dynamic> payload) {
    return _db.enqueue(action, jsonEncode(payload));
  }

  Map<String, dynamic> _reviewRow(VenueReview review) => {
        'id': review.id,
        'venue_id': review.venueId,
        'user_name': review.userName,
        'user_avatar_url': review.userAvatarUrl,
        'rating': review.rating,
        'review_text': review.text,
        'vibe_accurate': review.vibeAccurate ? 1 : 0,
        'created_at': review.createdAt.millisecondsSinceEpoch,
        'is_mine': review.isMine ? 1 : 0,
      };

  VenueReview _reviewFromRow(Map<String, dynamic> row) => VenueReview(
        id: row['id'] as String,
        venueId: row['venue_id'] as String,
        userName: row['user_name'] as String,
        userAvatarUrl: row['user_avatar_url'] as String?,
        rating: row['rating'] as int,
        text: row['review_text'] as String,
        vibeAccurate: row['vibe_accurate'] == 1,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
        isMine: row['is_mine'] == 1,
      );
}
