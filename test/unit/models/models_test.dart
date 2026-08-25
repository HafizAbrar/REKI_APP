import 'package:flutter_test/flutter_test.dart';
import 'package:reki_mvp/core/models/venue.dart';
import 'package:reki_mvp/core/models/offer.dart';
import 'package:reki_mvp/core/models/user.dart';
import 'package:reki_mvp/core/models/notification.dart';
import 'package:reki_mvp/core/models/vibe_schedule.dart';
import 'package:reki_mvp/core/models/social_models.dart';

void main() {
  // ── Venue ──────────────────────────────────────────────────────────────────
  group('Venue model', () {
    final json = {
      'id': 'v1',
      'name': 'The Alchemist',
      'category': 'BAR',
      'lat': 53.4808,
      'lng': -2.2426,
      'address': '1 Spinningfields, Manchester',
      'busyness': 'BUSY',
      'vibe': 'PARTY',
      'availableVibes': ['PARTY', 'CHILL'],
      'offers': [],
      'updatedAt': '2024-01-01T20:00:00.000Z',
      'postcode': 'M3 3AP',
      'activeOffersCount': 2,
    };

    test('fromJson parses all fields', () {
      final v = Venue.fromJson(json);
      expect(v.id, 'v1');
      expect(v.name, 'The Alchemist');
      expect(v.type, 'BAR');
      expect(v.latitude, 53.4808);
      expect(v.longitude, -2.2426);
      expect(v.busyness, 'BUSY');
      expect(v.currentVibe, 'PARTY');
      expect(v.availableVibes, ['PARTY', 'CHILL']);
      expect(v.postcode, 'M3 3AP');
      expect(v.activeOffersCount, 2);
    });

    test('fromJson handles legacy type key', () {
      final v = Venue.fromJson({...json, 'type': 'CLUB'});
      expect(v.type, 'CLUB');
    });

    test('fromJson defaults busyness to QUIET when missing', () {
      final v = Venue.fromJson({...json, 'busyness': null});
      expect(v.busyness, 'QUIET');
    });

    test('toJson round-trips id and name', () {
      final v = Venue.fromJson(json);
      final out = v.toJson();
      expect(out['id'], 'v1');
      expect(out['name'], 'The Alchemist');
    });
  });

  group('Phase 5 social models', () {
    test('VenueReview parses nested backend user', () {
      final review = VenueReview.fromJson({
        'id': 'r1',
        'venueId': 'v1',
        'rating': 5,
        'text': 'Great atmosphere',
        'vibeAccurate': true,
        'createdAt': '2026-08-24T12:00:00.000Z',
        'isMine': true,
        'user': {'name': 'Alex', 'avatar': 'https://example.com/avatar.png'},
      });
      expect(review.userName, 'Alex');
      expect(review.rating, 5);
      expect(review.vibeAccurate, isTrue);
      expect(review.isMine, isTrue);
    });

    test('VenueCheckIn parses the server response shape', () {
      final checkIn = VenueCheckIn.fromJson({
        'id': 'c1',
        'venueId': 'v1',
        'venueName': 'Warehouse Project',
        'checkedInAt': '2026-08-24T12:00:00.000Z',
        'pointsAwarded': 20,
      });
      expect(checkIn.venueName, 'Warehouse Project');
      expect(checkIn.pointsAwarded, 20);
    });

    test('Achievement and leaderboard parse live nested fields', () {
      final achievement = Achievement.fromJson({
        'id': 'first-night',
        'title': 'First Night Out',
        'description': 'Check in once',
        'icon': 'first-night',
        'progress': 1,
        'target': 1,
      });
      final entry = LeaderboardEntry.fromJson({
        'rank': 1,
        'points': 30,
        'isCurrentUser': true,
        'user': {'name': 'Alex'},
      });
      expect(achievement.isUnlocked, isTrue);
      expect(entry.name, 'Alex');
      expect(entry.isCurrentUser, isTrue);
    });
  });

  // ── Offer ──────────────────────────────────────────────────────────────────
  group('Offer model', () {
    final json = {
      'id': 'o1',
      'title': '2-for-1 Cocktails',
      'description': 'Buy one get one free on all cocktails',
      'offerType': 'BOGO',
      'isActive': true,
      'endsAt': '2027-12-31T23:59:59.000Z',
      'terms': 'Valid Mon–Thu only',
    };

    test('fromJson parses correctly', () {
      final o = Offer.fromJson(json);
      expect(o.id, 'o1');
      expect(o.title, '2-for-1 Cocktails');
      expect(o.type, 'BOGO');
      expect(o.isActive, true);
      expect(o.terms, 'Valid Mon–Thu only');
    });

    test('fromJson handles type fallback key', () {
      final o =
          Offer.fromJson({...json, 'offerType': null, 'type': 'DISCOUNT'});
      expect(o.type, 'DISCOUNT');
    });

    test('fromJson defaults validUntil to now when missing', () {
      final o = Offer.fromJson({...json, 'endsAt': null, 'validUntil': null});
      expect(o.validUntil, isA<DateTime>());
    });

    test('toJson includes required fields', () {
      final o = Offer.fromJson(json);
      final out = o.toJson();
      expect(out['id'], 'o1');
      expect(out['isActive'], true);
    });
  });

  // ── User ───────────────────────────────────────────────────────────────────
  group('User model', () {
    final json = {
      'id': 'u1',
      'email': 'test@reki.app',
      'fullName': 'Test User',
      'role': 'USER',
      'isActive': true,
      'preferences': {
        'preferredCategories': ['BAR', 'CLUB']
      },
    };

    test('fromJson parses customer role', () {
      final u = User.fromJson(json);
      expect(u.id, 'u1');
      expect(u.role, UserRole.USER);
      expect(u.type, UserType.customer);
      expect(u.preferences, ['BAR', 'CLUB']);
    });

    test('fromJson parses business role', () {
      final u = User.fromJson({...json, 'role': 'BUSINESS'});
      expect(u.role, UserRole.BUSINESS);
      expect(u.type, UserType.business);
    });

    test('fromJson parses admin role', () {
      final u = User.fromJson({...json, 'role': 'ADMIN'});
      expect(u.role, UserRole.ADMIN);
    });

    test('isGuest returns true for guest user', () {
      final u = User(
        id: 'guest_123',
        email: 'guest@reki.app',
        name: 'Guest',
        type: UserType.customer,
        role: UserRole.USER,
        preferences: [],
      );
      expect(u.isGuest, true);
    });

    test('isGuest returns false for real user', () {
      final u = User.fromJson(json);
      expect(u.isGuest, false);
    });
  });

  // ── AppNotification ────────────────────────────────────────────────────────
  group('AppNotification model', () {
    test('fromJson parses offer notification', () {
      final n = AppNotification(
        id: 'n1',
        title: 'New Offer',
        message: '2-for-1 at The Alchemist',
        type: NotificationType.offer,
        timestamp: DateTime(2024),
        isRead: false,
      );
      expect(n.id, 'n1');
      expect(n.type, NotificationType.offer);
      expect(n.isRead, false);
    });

    test('markAsRead sets isRead to true', () {
      final n = AppNotification(
        id: 'n2',
        title: 'Test',
        message: 'Msg',
        type: NotificationType.system,
        timestamp: DateTime(2024),
        isRead: false,
      );
      n.isRead = true;
      expect(n.isRead, true);
    });
  });

  // ── VibeSchedule ───────────────────────────────────────────────────────────
  group('VibeSchedule model', () {
    test('fromJson parses correctly', () {
      final s = VibeSchedule.fromJson({
        'id': 's1',
        'venueId': 'v1',
        'dayOfWeek': 5,
        'startTime': '21:00:00',
        'endTime': '03:00:00',
        'vibe': 'PARTY',
        'priority': 1,
        'isActive': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      });
      expect(s.dayOfWeek, 5);
      expect(s.vibe, 'PARTY');
      expect(s.dayName, 'Friday');
    });
  });
}
