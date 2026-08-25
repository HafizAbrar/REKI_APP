import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_models.dart';
import '../network/api_client.dart';
import '../network/venue_api_service.dart';
import '../network/offer_api_service.dart';
import '../network/user_api_service.dart';
import '../utils/app_logger.dart';
import 'local_database.dart';

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  return OfflineSyncService(
    ref.read(venueApiServiceProvider),
    ref.read(offerApiServiceProvider),
    ref.read(userApiServiceProvider),
    ref.read(apiClientProvider),
  );
});

/// Replays offline actions in FIFO order when connectivity is restored.
///
/// Individual endpoint replay is intentional: it lets the app replace local
/// review/check-in IDs with their server IDs and safely process dependent edits.
class OfflineSyncService {
  static const _maxRetries = 3;

  final VenueApiService _venueApi;
  final OfferApiService _offerApi;
  final UserApiService _userApi;
  final Dio _dio;
  final _db = LocalDatabase();
  bool _running = false;

  OfflineSyncService(this._venueApi, this._offerApi, this._userApi, this._dio);

  Future<void> sync() async {
    if (_running) return;
    _running = true;
    appLogger.i('OfflineSync: starting');
    try {
      final actions = await _db.pendingActions();
      appLogger.i('OfflineSync: ${actions.length} pending action(s)');
      for (final row in actions) {
        final id = row['id'] as int;
        final retries = row['retries'] as int;
        if (retries >= _maxRetries) {
          appLogger.w(
              'OfflineSync: dropping ${row['action']} after $_maxRetries retries');
          await _db.removeAction(id);
          continue;
        }
        try {
          await _dispatch(row['action'] as String, row['payload'] as String);
          await _db.removeAction(id);
          appLogger.i('OfflineSync: synced ${row['action']}');
        } catch (error) {
          await _db.incrementRetry(id);
          appLogger.w(
              'OfflineSync: failed ${row['action']} (retry ${retries + 1}): $error');
        }
      }
    } finally {
      _running = false;
      appLogger.i('OfflineSync: complete');
    }
  }

  Future<void> _dispatch(String action, String payload) async {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    switch (action) {
      case 'update_live_state':
        await _venueApi.updateLiveState(
          data['venueId'] as String,
          busyness: data['busyness'] as String?,
          currentVibe: data['vibe'] as String?,
        );
      case 'redeem_offer':
        await _offerApi.claimOffer(data['offerId'] as String);
      case 'save_venue':
        await _userApi.saveVenue(data['venueId'] as String);
      case 'unsave_venue':
        await _userApi.unsaveVenue(data['venueId'] as String);
      case 'venue_history_view':
        final venueId = data['venueId'] as String;
        await _dio.post('/users/history/venues/$venueId', data: {
          'viewedAt': data['viewedAt'],
          'source': data['source'] ?? 'home',
        });
      case 'history_clear':
        await _dio.delete('/users/history/venues');
      case 'review_create':
        await _syncReviewCreate(data);
      case 'review_update':
        await _syncReviewUpdate(data);
      case 'review_delete':
        final localId = data['reviewId'].toString();
        final reviewId = await _resolveReviewId(localId);
        await _dio.delete('/reviews/$reviewId');
        await _db.deleteReview(localId);
      case 'check_in':
        await _syncCheckIn(data);
      case 'vibe_accuracy_vote':
        final venueId = data['venueId'] as String;
        await _dio.post('/venues/$venueId/vibe-accuracy-votes', data: {
          'accurate': data['accurate'],
          if (data['observedVibe'] != null)
            'observedVibe': data['observedVibe'],
          'votedAt': data['votedAt'],
        });
      case 'venue_share':
        final venueId = data['venueId'] as String;
        await _dio.post('/venues/$venueId/shares', data: {
          'channel': data['channel'] ?? 'other',
          'sharedAt': data['sharedAt'],
        });
      default:
        throw UnsupportedError('Unknown offline action $action');
    }
  }

  Future<void> _syncReviewCreate(Map<String, dynamic> data) async {
    final venueId = data['venueId'] as String;
    final localId = data['localId'] as String;
    final response = await _dio.post('/venues/$venueId/reviews', data: {
      'rating': data['rating'],
      'text': data['text'],
      'vibeAccurate': data['vibeAccurate'],
    });
    final body = response.data;
    final raw = body is Map ? (body['review'] ?? body) : null;
    if (raw is! Map) return;
    final review = VenueReview.fromJson({
      ...Map<String, dynamic>.from(raw),
      'venueId': venueId,
      'isMine': true,
    });
    await _db.deleteReview(localId);
    await _db.upsertReview(_reviewRow(review));
    await _db.setPref('review_server_id_$localId', review.id);
  }

  Future<void> _syncReviewUpdate(Map<String, dynamic> data) async {
    final originalId = data['reviewId'].toString();
    final reviewId = await _resolveReviewId(originalId);
    final response = await _dio.patch('/reviews/$reviewId', data: {
      'rating': data['rating'],
      'text': data['text'],
      'vibeAccurate': data['vibeAccurate'],
    });
    final body = response.data;
    final raw = body is Map ? (body['review'] ?? body) : null;
    if (raw is! Map) return;
    final review = VenueReview.fromJson({
      ...Map<String, dynamic>.from(raw),
      'venueId': data['venueId'],
      'isMine': true,
    });
    await _db.deleteReview(originalId);
    await _db.upsertReview(_reviewRow(review));
  }

  Future<void> _syncCheckIn(Map<String, dynamic> data) async {
    final venueId = data['venueId'] as String;
    final localId = data['localId'] as String;
    final response = await _dio.post('/venues/$venueId/check-ins', data: {
      'lat': data['lat'],
      'lng': data['lng'],
      'accuracy': data['accuracy'],
      'timestamp': data['timestamp'],
    });
    final body = response.data;
    final raw = body is Map ? (body['checkIn'] ?? body) : null;
    if (raw is! Map) return;
    final checkIn = VenueCheckIn.fromJson({
      ...Map<String, dynamic>.from(raw),
      'venueId': venueId,
      'venueName': data['venueName'],
    });
    await _db.deleteCheckIn(localId);
    await _db.addCheckIn(checkIn.id, checkIn.venueId, checkIn.venueName,
        checkedInAt: checkIn.checkedInAt);
  }

  Future<String> _resolveReviewId(String reviewId) async {
    return await _db.getPref('review_server_id_$reviewId') ?? reviewId;
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

  Future<void> queueLiveStateUpdate(String venueId, String busyness,
      {String? vibe}) async {
    await _db.enqueue(
      'update_live_state',
      jsonEncode({'venueId': venueId, 'busyness': busyness, 'vibe': vibe}),
    );
  }

  Future<void> queueOfferRedemption(String offerId) async {
    await _db.enqueue('redeem_offer', jsonEncode({'offerId': offerId}));
  }

  Future<void> queueSaveVenue(String venueId) async {
    await _db.enqueue('save_venue', jsonEncode({'venueId': venueId}));
  }

  Future<void> queueUnsaveVenue(String venueId) async {
    await _db.enqueue('unsave_venue', jsonEncode({'venueId': venueId}));
  }
}
