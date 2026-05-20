import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_database.dart';
import '../network/venue_api_service.dart';
import '../network/offer_api_service.dart';
import '../network/user_api_service.dart';
import '../utils/app_logger.dart';

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  return OfflineSyncService(
    ref.read(venueApiServiceProvider),
    ref.read(offerApiServiceProvider),
    ref.read(userApiServiceProvider),
  );
});

/// Processes the offline action queue when connectivity is restored.
/// Each action is retried up to [_maxRetries] times before being discarded.
class OfflineSyncService {
  static const _maxRetries = 3;

  final VenueApiService _venueApi;
  final OfferApiService _offerApi;
  final UserApiService _userApi;
  final _db = LocalDatabase();
  bool _running = false;

  OfflineSyncService(this._venueApi, this._offerApi, this._userApi);

  Future<void> sync() async {
    if (_running) return;
    _running = true;
    appLogger.i('OfflineSync: starting');

    try {
      final actions = await _db.pendingActions();
      appLogger.i('OfflineSync: ${actions.length} pending action(s)');
      if (actions.isEmpty) return;

      // Build payload for POST /sync/queue
      final payload = actions
          .where((r) => (r['retries'] as int) < _maxRetries)
          .map((r) => {
                'action': r['action'] as String,
                'payload': r['payload'] as String,
              })
          .toList();

      // Drop exhausted retries
      for (final row in actions) {
        if ((row['retries'] as int) >= _maxRetries) {
          appLogger.w('OfflineSync: dropping ${row['action']} after $_maxRetries retries');
          await _db.removeAction(row['id'] as int);
        }
      }

      if (payload.isEmpty) return;

      try {
        final result = await _venueApi.submitSyncQueue(payload);
        final processed = result['processed'] as List? ?? payload;
        // Remove successfully processed actions
        for (final row in actions) {
          final matched = processed.any((p) =>
              p is Map && p['action'] == row['action']);
          if (matched) await _db.removeAction(row['id'] as int);
        }
        appLogger.i('OfflineSync: synced ${processed.length} action(s)');
      } catch (e) {
        // Increment retries for all pending on failure
        for (final row in actions) {
          await _db.incrementRetry(row['id'] as int);
        }
        appLogger.w('OfflineSync: batch sync failed: $e');
        // Fallback: dispatch individually
        await _dispatchIndividually(actions);
      }
    } finally {
      _running = false;
      appLogger.i('OfflineSync: complete');
    }
  }

  Future<void> _dispatchIndividually(List<Map<String, dynamic>> actions) async {
    for (final row in actions) {
      final id = row['id'] as int;
      final retries = row['retries'] as int;
      if (retries >= _maxRetries) continue;
      try {
        await _dispatch(row['action'] as String, row['payload'] as String);
        await _db.removeAction(id);
        appLogger.i('OfflineSync: synced ${row['action']}');
      } catch (e) {
        await _db.incrementRetry(id);
        appLogger.w('OfflineSync: failed ${row['action']} (retry ${retries + 1}): $e');
      }
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
      default:
        appLogger.w('OfflineSync: unknown action "$action"');
    }
  }

  // ── Enqueue helpers ───────────────────────────────────────────────────────

  Future<void> queueLiveStateUpdate(
      String venueId, String busyness, {String? vibe}) async {
    await _db.enqueue(
      'update_live_state',
      jsonEncode({'venueId': venueId, 'busyness': busyness, 'vibe': vibe}),
    );
    appLogger.d('OfflineSync: queued live state update for $venueId');
  }

  Future<void> queueOfferRedemption(String offerId) async {
    await _db.enqueue(
      'redeem_offer',
      jsonEncode({'offerId': offerId}),
    );
    appLogger.d('OfflineSync: queued offer redemption $offerId');
  }

  Future<void> queueSaveVenue(String venueId) async {
    await _db.enqueue('save_venue', jsonEncode({'venueId': venueId}));
    appLogger.d('OfflineSync: queued save venue $venueId');
  }

  Future<void> queueUnsaveVenue(String venueId) async {
    await _db.enqueue('unsave_venue', jsonEncode({'venueId': venueId}));
    appLogger.d('OfflineSync: queued unsave venue $venueId');
  }
}
