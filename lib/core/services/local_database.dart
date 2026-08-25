import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Single SQLite database for all offline persistence needs (Week 10).
class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._();
  factory LocalDatabase() => _instance;
  LocalDatabase._();

  Database? _db;

  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'reki.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, _) async {
        // Venue cache with TTL
        await db.execute('''
          CREATE TABLE venue_cache (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            cached_at INTEGER NOT NULL
          )
        ''');
        // Saved / favourite venues
        await db.execute('''
          CREATE TABLE saved_venues (
            venue_id TEXT PRIMARY KEY,
            saved_at INTEGER NOT NULL
          )
        ''');
        // Redeemed offers (prevent double-redeem offline)
        await db.execute('''
          CREATE TABLE redeemed_offers (
            offer_id TEXT PRIMARY KEY,
            redeemed_at INTEGER NOT NULL,
            data TEXT
          )
        ''');
        // Offline action queue with retry counter
        await db.execute('''
          CREATE TABLE sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action TEXT NOT NULL,
            payload TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            retries INTEGER NOT NULL DEFAULT 0
          )
        ''');
        // Persisted user preferences & filters
        await db.execute('''
          CREATE TABLE user_prefs (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
        await _createSocialTables(db);
      },
      onUpgrade: (db, oldVersion, _) async {
        if (oldVersion < 2) await _createSocialTables(db);
      },
    );
  }

  static Future<void> _createSocialTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS venue_history (
        venue_id TEXT PRIMARY KEY,
        venue_name TEXT NOT NULL,
        visited_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS venue_reviews (
        id TEXT PRIMARY KEY,
        venue_id TEXT NOT NULL,
        user_name TEXT NOT NULL,
        user_avatar_url TEXT,
        rating INTEGER NOT NULL,
        review_text TEXT NOT NULL,
        vibe_accurate INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        is_mine INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS venue_checkins (
        id TEXT PRIMARY KEY,
        venue_id TEXT NOT NULL,
        venue_name TEXT NOT NULL,
        checked_in_at INTEGER NOT NULL
      )
    ''');
  }

  // ── Venue cache ──────────────────────────────────────────────────────────

  Future<void> cacheVenueList(String json) async {
    final d = await db;
    await d.insert(
      'venue_cache',
      {
        'id': '__list__',
        'data': json,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Returns cached venue list JSON if within [ttlMinutes], else null.
  Future<String?> getCachedVenueList({int ttlMinutes = 5}) async {
    final d = await db;
    final rows =
        await d.query('venue_cache', where: 'id = ?', whereArgs: ['__list__']);
    if (rows.isEmpty) return null;
    final age = DateTime.now().millisecondsSinceEpoch -
        (rows.first['cached_at'] as int);
    if (age > ttlMinutes * 60 * 1000) return null;
    return rows.first['data'] as String;
  }

  Future<void> cacheVenue(String id, String json) async {
    final d = await db;
    await d.insert(
      'venue_cache',
      {
        'id': id,
        'data': json,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getCachedVenue(String id, {int ttlMinutes = 10}) async {
    final d = await db;
    final rows = await d.query('venue_cache', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final age = DateTime.now().millisecondsSinceEpoch -
        (rows.first['cached_at'] as int);
    if (age > ttlMinutes * 60 * 1000) return null;
    return rows.first['data'] as String;
  }

  // ── Saved venues ─────────────────────────────────────────────────────────

  Future<void> saveVenue(String venueId) async {
    final d = await db;
    await d.insert(
      'saved_venues',
      {
        'venue_id': venueId,
        'saved_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> unsaveVenue(String venueId) async {
    final d = await db;
    await d.delete('saved_venues', where: 'venue_id = ?', whereArgs: [venueId]);
  }

  Future<List<String>> getSavedVenueIds() async {
    final d = await db;
    final rows = await d.query('saved_venues', orderBy: 'saved_at DESC');
    return rows.map((r) => r['venue_id'] as String).toList();
  }

  Future<void> replaceSavedVenueIds(Iterable<String> venueIds) async {
    final d = await db;
    await d.transaction((txn) async {
      await txn.delete('saved_venues');
      var savedAt = DateTime.now().millisecondsSinceEpoch;
      for (final venueId in venueIds) {
        await txn.insert('saved_venues', {
          'venue_id': venueId,
          'saved_at': savedAt--,
        });
      }
    });
  }

  Future<bool> isVenueSaved(String venueId) async {
    final d = await db;
    final rows = await d
        .query('saved_venues', where: 'venue_id = ?', whereArgs: [venueId]);
    return rows.isNotEmpty;
  }

  // ── Redeemed offers ───────────────────────────────────────────────────────

  Future<void> markOfferRedeemed(String offerId, {String? data}) async {
    final d = await db;
    await d.insert(
      'redeemed_offers',
      {
        'offer_id': offerId,
        'redeemed_at': DateTime.now().millisecondsSinceEpoch,
        'data': data,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isOfferRedeemed(String offerId) async {
    final d = await db;
    final rows = await d
        .query('redeemed_offers', where: 'offer_id = ?', whereArgs: [offerId]);
    return rows.isNotEmpty;
  }

  // ── Offline sync queue ────────────────────────────────────────────────────

  Future<void> enqueue(String action, String payload) async {
    final d = await db;
    await d.insert('sync_queue', {
      'action': action,
      'payload': payload,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'retries': 0,
    });
  }

  Future<List<Map<String, dynamic>>> pendingActions() async {
    final d = await db;
    return d.query('sync_queue', orderBy: 'created_at ASC');
  }

  Future<Map<String, bool>> pendingSavedVenueOverrides() async {
    final overrides = <String, bool>{};
    for (final row in await pendingActions()) {
      final action = row['action']?.toString();
      if (action != 'save_venue' && action != 'unsave_venue') continue;
      try {
        final payload = jsonDecode(row['payload'] as String);
        if (payload is Map && payload['venueId'] != null) {
          overrides[payload['venueId'].toString()] = action == 'save_venue';
        }
      } catch (_) {}
    }
    return overrides;
  }

  Future<void> removeAction(int id) async {
    final d = await db;
    await d.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> incrementRetry(int id) async {
    final d = await db;
    await d.rawUpdate(
        'UPDATE sync_queue SET retries = retries + 1 WHERE id = ?', [id]);
  }

  // ── User preferences ──────────────────────────────────────────────────────

  Future<void> setPref(String key, String value) async {
    final d = await db;
    await d.insert('user_prefs', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getPref(String key) async {
    final d = await db;
    final rows =
        await d.query('user_prefs', where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> deletePref(String key) async {
    final d = await db;
    await d.delete('user_prefs', where: 'key = ?', whereArgs: [key]);
  }

  // Phase 5: recently visited venues
  Future<void> addVenueVisit(String venueId, String venueName,
      {DateTime? visitedAt}) async {
    final d = await db;
    await d.insert(
        'venue_history',
        {
          'venue_id': venueId,
          'venue_name': venueName,
          'visited_at': (visitedAt ?? DateTime.now()).millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
    await d.rawDelete('''
      DELETE FROM venue_history WHERE venue_id NOT IN (
        SELECT venue_id FROM venue_history ORDER BY visited_at DESC LIMIT 30
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getVenueHistory() async {
    final d = await db;
    return d.query('venue_history', orderBy: 'visited_at DESC', limit: 30);
  }

  Future<void> clearVenueHistory() async {
    final d = await db;
    await d.delete('venue_history');
  }

  // Phase 5: local-first reviews
  Future<void> upsertReview(Map<String, dynamic> review) async {
    final d = await db;
    await d.insert('venue_reviews', review,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getReviews(String venueId) async {
    final d = await db;
    return d.query('venue_reviews',
        where: 'venue_id = ?',
        whereArgs: [venueId],
        orderBy: 'created_at DESC');
  }

  Future<void> deleteReview(String reviewId) async {
    final d = await db;
    await d.delete('venue_reviews', where: 'id = ?', whereArgs: [reviewId]);
  }

  // Phase 5: check-ins and gamification counters
  Future<void> addCheckIn(String id, String venueId, String venueName,
      {DateTime? checkedInAt}) async {
    final d = await db;
    await d.insert(
        'venue_checkins',
        {
          'id': id,
          'venue_id': venueId,
          'venue_name': venueName,
          'checked_in_at':
              (checkedInAt ?? DateTime.now()).millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Map<String, dynamic>>> getCheckIns() async {
    final d = await db;
    return d.query('venue_checkins', orderBy: 'checked_in_at DESC');
  }

  Future<void> deleteCheckIn(String checkInId) async {
    final d = await db;
    await d.delete('venue_checkins', where: 'id = ?', whereArgs: [checkInId]);
  }

  Future<int> getReviewCount() async {
    final d = await db;
    return Sqflite.firstIntValue(
          await d
              .rawQuery('SELECT COUNT(*) FROM venue_reviews WHERE is_mine = 1'),
        ) ??
        0;
  }
}
