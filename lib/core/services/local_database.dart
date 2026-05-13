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
      version: 1,
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
      },
    );
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
    final rows = await d.query('venue_cache',
        where: 'id = ?', whereArgs: ['__list__']);
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
    final rows =
        await d.query('venue_cache', where: 'id = ?', whereArgs: [id]);
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
    await d.delete('saved_venues',
        where: 'venue_id = ?', whereArgs: [venueId]);
  }

  Future<List<String>> getSavedVenueIds() async {
    final d = await db;
    final rows = await d.query('saved_venues', orderBy: 'saved_at DESC');
    return rows.map((r) => r['venue_id'] as String).toList();
  }

  Future<bool> isVenueSaved(String venueId) async {
    final d = await db;
    final rows = await d.query('saved_venues',
        where: 'venue_id = ?', whereArgs: [venueId]);
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
    final rows = await d.query('redeemed_offers',
        where: 'offer_id = ?', whereArgs: [offerId]);
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
}
