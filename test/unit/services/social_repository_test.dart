import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:reki_mvp/core/services/engagement_analytics.dart';
import 'package:reki_mvp/core/services/local_database.dart';
import 'package:reki_mvp/core/services/social_repository.dart';

void main() {
  late Dio dio;
  late _StubAdapter adapter;
  late LocalDatabase database;
  late SocialRepository repository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databaseFactory.setDatabasesPath(
      Directory.systemTemp.createTempSync('reki-social-db-test-').path,
    );
  });

  setUp(() async {
    dio = Dio(BaseOptions(baseUrl: 'https://test.reki.uk'));
    adapter = _StubAdapter();
    dio.httpClientAdapter = adapter;
    database = LocalDatabase();
    final db = await database.db;
    await db.delete('venue_reviews');
    await db.delete('sync_queue');
    repository = SocialRepository(dio, database, _NoopAnalytics());
  });

  test('uses backend aggregate summary instead of the fetched page', () async {
    adapter.handler = (_) => _jsonResponse(200, {
          'reviews': [
            {
              'id': 'review-1',
              'venueId': 'venue-1',
              'rating': 5,
              'text': 'Excellent',
              'vibeAccurate': true,
              'createdAt': '2026-08-25T10:00:00.000Z',
              'user': {'name': 'Alex'}
            }
          ],
          'summary': {
            'averageRating': 4.7,
            'totalReviews': 120,
            'vibeAccuracyPercentage': 88,
          }
        });

    final feed = await repository.getReviews('venue-1');

    expect(feed.reviews, hasLength(1));
    expect(feed.summary.averageRating, 4.7);
    expect(feed.summary.totalReviews, 120);
    expect(feed.summary.vibeAccuracyPercentage, 88);
  });

  test('queues a review when the backend is temporarily unavailable', () async {
    adapter.handler = (_) => _jsonResponse(503, {'message': 'unavailable'});

    final review = await repository.submitReview(
      venueId: 'venue-offline',
      rating: 4,
      text: 'Queued review',
      vibeAccurate: true,
    );

    expect(review.id, startsWith('local-'));
    final pending = await database.pendingActions();
    expect(pending, hasLength(1));
    expect(pending.single['action'], 'review_create');
    final payload = jsonDecode(pending.single['payload'] as String);
    expect(payload['venueId'], 'venue-offline');
    expect(payload['rating'], 4);
  });

  test('does not hide validation errors as offline success', () async {
    adapter.handler = (_) => _jsonResponse(400, {'message': 'invalid rating'});

    expect(
      () => repository.submitReview(
        venueId: 'venue-invalid',
        rating: 4,
        text: 'Invalid backend request',
        vibeAccurate: false,
      ),
      throwsA(isA<DioException>()),
    );
    expect(await database.pendingActions(), isEmpty);
  });
}

class _StubAdapter implements HttpClientAdapter {
  ResponseBody Function(RequestOptions options)? handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      handler!(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(int status, Object body) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      },
    );

class _NoopAnalytics implements EngagementAnalytics {
  @override
  Future<void> checkIn(String venueId) async {}
  @override
  Future<void> reviewSubmitted(String venueId, int rating) async {}
  @override
  Future<void> venueSaved(String venueId, bool saved) async {}
  @override
  Future<void> venueShared(String venueId, String channel) async {}
  @override
  Future<void> venueViewed(String venueId, String source) async {}
  @override
  Future<void> vibeAccuracyVote(String venueId, bool accurate) async {}
}
