import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_database.dart';
import '../network/venue_api_service.dart';
import '../network/offer_api_service.dart';
import '../utils/app_logger.dart';

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  return OfflineSyncService(
    ref.read(venueApiServiceProvider),
    ref.read(offerApiServiceProvider),
  );
});

/// Processes the offline action queue when connectivity is restored.
/// Each action is retried up to [_maxRetries] times before being discarded.
class OfflineSyncService {
  static const _maxRetries = 3;

  final VenueApiService _venueApi;
  final OfferApiService _offerApi;
  final _db = LocalDatabase();
  bool _running = false;

  OfflineSyncService(this._venueApi, this._offerApi);

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
          appLogger.w('OfflineSync: dropping ${row['action']} after $_maxRetries retries');
          await _db.removeAction(id);
          continue;
        }

        try {
          await _dispatch(row['action'] as String, row['payload'] as String);
          await _db.removeAction(id);
          appLogger.i('OfflineSync: synced ${row['action']}');
        } catch (e) {
          await _db.incrementRetry(id);
          appLogger.w('OfflineSync: failed ${row['action']} (retry ${retries + 1}): $e');
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
}
