import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:reki_mvp/core/services/local_database.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databaseFactory.setDatabasesPath(
      Directory.systemTemp.createTempSync('reki-local-db-test-').path,
    );
  });

  group('LocalDatabase', () {
    final db = LocalDatabase();

    test('caches and retrieves venue list within TTL', () async {
      const json = '[{"id":"v1"}]';
      await db.cacheVenueList(json);
      final cached = await db.getCachedVenueList(ttlMinutes: 5);
      expect(cached, json);
    });

    test('returns null for expired venue list cache', () async {
      const json = '[{"id":"v2"}]';
      await db.cacheVenueList(json);
      final cached = await db.getCachedVenueList(ttlMinutes: 0);
      expect(cached, isNull);
    });

    test('saves and retrieves saved venue IDs', () async {
      await db.saveVenue('v10');
      await db.saveVenue('v11');
      final ids = await db.getSavedVenueIds();
      expect(ids, containsAll(['v10', 'v11']));
    });

    test('unsaves a venue', () async {
      await db.saveVenue('v20');
      await db.unsaveVenue('v20');
      expect(await db.isVenueSaved('v20'), false);
    });

    test('isVenueSaved returns true for saved venue', () async {
      await db.saveVenue('v30');
      expect(await db.isVenueSaved('v30'), true);
    });

    test('replaces cloud saved venues without resurrecting stale entries',
        () async {
      await db.saveVenue('stale-cloud-save');
      await db.replaceSavedVenueIds(['current-cloud-save']);

      expect(await db.getSavedVenueIds(), ['current-cloud-save']);
    });

    test('keeps the latest queued save override per venue', () async {
      final database = await db.db;
      await database.delete('sync_queue');
      await db.enqueue('save_venue', jsonEncode({'venueId': 'v-queued'}));
      await db.enqueue('unsave_venue', jsonEncode({'venueId': 'v-queued'}));
      await db.enqueue('save_venue', jsonEncode({'venueId': 'v-other'}));

      expect(await db.pendingSavedVenueOverrides(), {
        'v-queued': false,
        'v-other': true,
      });
    });

    test('marks offer as redeemed', () async {
      await db.markOfferRedeemed('o1');
      expect(await db.isOfferRedeemed('o1'), true);
    });

    test('isOfferRedeemed returns false for unknown offer', () async {
      expect(await db.isOfferRedeemed('unknown_offer_xyz'), false);
    });

    test('enqueues and retrieves pending actions', () async {
      await db.enqueue('update_live_state', '{"venueId":"v1"}');
      final actions = await db.pendingActions();
      expect(actions.any((a) => a['action'] == 'update_live_state'), true);
    });

    test('removes action from queue', () async {
      await db.enqueue('redeem_offer', '{"offerId":"o99"}');
      final before = await db.pendingActions();
      final id = before.last['id'] as int;
      await db.removeAction(id);
      final after = await db.pendingActions();
      expect(after.any((a) => a['id'] == id), false);
    });

    test('increments retry counter', () async {
      await db.enqueue('test_action', '{}');
      final actions = await db.pendingActions();
      final id = actions.last['id'] as int;
      await db.incrementRetry(id);
      final updated = await db.pendingActions();
      final row = updated.firstWhere((a) => a['id'] == id);
      expect(row['retries'], 1);
    });

    test('sets and gets user preference', () async {
      await db.setPref('theme', 'dark');
      expect(await db.getPref('theme'), 'dark');
    });

    test('overwrites existing preference', () async {
      await db.setPref('city', 'manchester');
      await db.setPref('city', 'london');
      expect(await db.getPref('city'), 'london');
    });

    test('returns null for missing preference', () async {
      expect(await db.getPref('nonexistent_key_xyz'), isNull);
    });

    test('deletes preference', () async {
      await db.setPref('to_delete', 'value');
      await db.deletePref('to_delete');
      expect(await db.getPref('to_delete'), isNull);
    });

    test('records venue history once and updates recency', () async {
      await db.clearVenueHistory();
      await db.addVenueVisit('history-v1', 'First Venue');
      await db.addVenueVisit('history-v1', 'Renamed Venue');
      final history = await db.getVenueHistory();
      expect(history, hasLength(1));
      expect(history.first['venue_name'], 'Renamed Venue');
    });

    test('stores reviews and counts current user reviews', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await db.upsertReview({
        'id': 'review-$timestamp',
        'venue_id': 'review-venue',
        'user_name': 'Tester',
        'user_avatar_url': null,
        'rating': 5,
        'review_text': 'Great atmosphere',
        'vibe_accurate': 1,
        'created_at': timestamp,
        'is_mine': 1,
      });
      final reviews = await db.getReviews('review-venue');
      expect(reviews.first['rating'], 5);
      expect(await db.getReviewCount(), greaterThanOrEqualTo(1));
    });

    test('stores check-ins for gamification', () async {
      final id = 'checkin-${DateTime.now().microsecondsSinceEpoch}';
      await db.addCheckIn(id, 'venue-checkin', 'Check-in Venue');
      final checkIns = await db.getCheckIns();
      expect(checkIns.any((row) => row['id'] == id), true);
    });
  });
}
