import 'package:flutter_test/flutter_test.dart';
import 'package:reki_mvp/core/models/offer.dart';
import 'package:reki_mvp/core/models/user.dart';
import 'package:reki_mvp/core/models/venue.dart';
import 'package:reki_mvp/core/models/notification.dart';
import 'package:reki_mvp/core/network/offer_api_service.dart';
import 'package:reki_mvp/core/network/user_api_service.dart';
import 'package:reki_mvp/core/network/venue_api_service.dart';
import 'package:reki_mvp/core/network/notification_api_service.dart';
import 'package:reki_mvp/core/services/offer_repository.dart';
import 'package:reki_mvp/core/services/user_repository.dart';
import 'package:reki_mvp/core/services/venue_repository.dart';
import 'package:reki_mvp/core/services/notification_repository.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

Offer _offer(String id) => Offer(
      id: id,
      title: 'Test Offer',
      description: 'Desc',
      type: 'BOGO',
      isActive: true,
      validUntil: DateTime(2027),
    );

Venue _venue(String id) => Venue(
      id: id,
      name: 'Test Venue',
      type: 'BAR',
      latitude: 53.48,
      longitude: -2.24,
      address: '1 Test St',
      busyness: 'QUIET',
      currentVibe: 'CHILL',
      availableVibes: ['CHILL'],
      offers: [],
      lastUpdated: DateTime.now(),
    );

User _user(String id) => User(
      id: id,
      email: 'test@reki.app',
      name: 'Test',
      type: UserType.customer,
      role: UserRole.USER,
      preferences: [],
    );

// ── Mock: OfferApiService ─────────────────────────────────────────────────────

class MockOfferApi implements OfferApiService {
  bool throws = false;

  @override Future<List<Offer>> getAllOffers() async {
    if (throws) throw Exception('err');
    return [_offer('o1')];
  }
  @override Future<Offer> getOfferById(String id) async {
    if (throws) throw Exception('err');
    return _offer(id);
  }
  @override Future<List<Offer>> getOffersByVenue(String v) async {
    if (throws) throw Exception('err');
    return [_offer('o1')];
  }
  @override Future<Offer> createOffer(Map<String, dynamic> d) async {
    if (throws) throw Exception('err');
    return _offer('new');
  }
  @override Future<Map<String, dynamic>> claimOffer(String id) async {
    if (throws) throw Exception('err');
    return {'voucherCode': 'ABC123'};
  }
  @override Future<Map<String, dynamic>> redeemOffer(String id, {required String voucherCode}) async {
    if (throws) throw Exception('err');
    return {'status': 'redeemed'};
  }
  @override Future<Map<String, dynamic>> generateWalletPass(String id) async => {};
  @override Future<Offer> markOfferViewed(String id) async => _offer(id);
  @override Future<Offer> markOfferClicked(String id) async => _offer(id);
  @override Future<Map<String, dynamic>> getOfferStats(String id) async => {};
  @override Future<Offer> updateOfferStatus(String id, bool a) async => _offer(id);
  @override Future<Map<String, dynamic>> redeemByCode(String code) async => {};
}

// ── Mock: VenueApiService ─────────────────────────────────────────────────────

class MockVenueApi implements VenueApiService {
  bool throws = false;

  @override Future<List<Venue>> getAllVenuesList() async {
    if (throws) throw Exception('err');
    return [_venue('v1')];
  }
  @override Future<Map<String, dynamic>> getAllVenues({
    String? category, String? busyness, String? vibe,
    String? cityId, int page = 1, int limit = 20,
  }) async {
    if (throws) throw Exception('err');
    return {'data': []};
  }
  @override Future<Venue> getVenueById(String id) async {
    if (throws) throw Exception('err');
    return _venue(id);
  }
  @override Future<List<Venue>> searchVenues(String q, {String? city}) async {
    if (throws) throw Exception('err');
    return [_venue('v1')];
  }
  @override Future<List<Venue>> getTrendingVenues({String? cityId}) async {
    if (throws) throw Exception('err');
    return [_venue('v1')];
  }
  @override Future<void> trackVenueView(String id) async {
    if (throws) throw Exception('err');
  }
  @override Future<Venue> createVenue(Map<String, dynamic> d) async {
    if (throws) throw Exception('err');
    return _venue('new');
  }
  @override Future<Venue> updateLiveState(String id,
      {String? busyness, String? currentVibe}) async {
    if (throws) throw Exception('err');
    return _venue(id);
  }
  @override Future<Map<String, dynamic>> getFilterOptions({String? cityId}) async => {};
  @override Future<List<Map<String, dynamic>>> getMapMarkers({
    String? cityId, double? swLat, double? swLng,
    double? neLat, double? neLng,
  }) async => [];
  @override Future<Map<String, dynamic>> createVibeSchedule(
      String id, Map<String, dynamic> s) async => {};
  @override Future<List<Map<String, dynamic>>> getVibeSchedules(String id) async => [];
  @override Future<Map<String, dynamic>> getCurrentVibe(String id) async => {};
  @override Future<Map<String, dynamic>> submitVibeCheck(String venueId, int score) async => {};
  @override Future<List<Map<String, dynamic>>> getVenueOffers(String venueId) async => [];
}

// ── Mock: UserApiService ──────────────────────────────────────────────────────

class MockUserApi implements UserApiService {
  bool throws = false;

  @override Future<List<User>> getAllUsers() async {
    if (throws) throw Exception('err');
    return [_user('u1')];
  }
  @override Future<User> getUserById(String id) async {
    if (throws) throw Exception('err');
    return _user(id);
  }
  @override Future<User> updateUser(String id, Map<String, dynamic> u) async {
    if (throws) throw Exception('err');
    return _user(id);
  }
  @override Future<void> deleteUser(String id) async {
    if (throws) throw Exception('err');
  }
  @override Future<Map<String, dynamic>> getProfile() async {
    if (throws) throw Exception('err');
    return {
      'id': 'u1',
      'name': 'Test User',
      'email': 'test@reki.app',
      'phone': '1234567890',
      'authProvider': 'email',
      'isVerified': true,
      'preferences': {'vibes': [], 'music': []},
      'savedVenuesCount': 0,
      'location': {
        'currentLat': null,
        'currentLng': null,
        'locationUpdatedAt': null,
        'locationEnabled': false,
        'backgroundLocationEnabled': false,
      },
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-01T00:00:00.000Z',
    };
  }
  @override Future<Map<String, dynamic>> getPreferences() async {
    if (throws) throw Exception('err');
    return {'preferredCategories': ['BAR']};
  }
  @override Future<Map<String, dynamic>> savePreferences(Map<String, dynamic> p) async {
    if (throws) throw Exception('err');
    return p;
  }
  @override Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> p) async {
    if (throws) throw Exception('err');
    return p;
  }
  @override Future<List<Map<String, dynamic>>> getSavedVenues() async {
    if (throws) throw Exception('err');
    return [{'id': 'v1'}];
  }
  @override Future<Map<String, dynamic>> saveVenue(String id) async {
    if (throws) throw Exception('err');
    return {'id': id};
  }
  @override Future<void> unsaveVenue(String id) async {
    if (throws) throw Exception('err');
  }
  @override Future<List<Map<String, dynamic>>> getRedemptions() async {
    if (throws) throw Exception('err');
    return [];
  }
}

// ── Mock: NotificationApiService ─────────────────────────────────────────────

class MockNotificationApi implements NotificationApiService {
  bool throws = false;

  AppNotification _n(String id) => AppNotification(
        id: id,
        title: 'Test',
        message: 'Msg',
        type: NotificationType.offer,
        timestamp: DateTime(2024),
      );

  @override Future<Map<String, dynamic>> getAllNotifications() async {
    if (throws) throw Exception('err');
    return {
      'today': [_n('n1').toJson()],
      'yesterday': [],
      'earlier': [],
    };
  }
  @override Future<AppNotification> markAsRead(String id) async {
    if (throws) throw Exception('err');
    return _n(id);
  }
  @override Future<void> markAllAsRead() async {
    if (throws) throw Exception('err');
  }
  @override Future<void> deleteNotification(String id) async {
    if (throws) throw Exception('err');
  }
  @override Future<AppNotification> testNotification(Map<String, dynamic> d) async {
    if (throws) throw Exception('err');
    return _n('test');
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── OfferRepository ──────────────────────────────────────────────────────
  group('OfferRepository', () {
    late MockOfferApi api;
    late OfferRepository repo;
    setUp(() { api = MockOfferApi(); repo = OfferRepository(api); });

    test('getAllOffers success', () async {
      final r = await repo.getAllOffers();
      expect(r.isSuccess, true);
      expect(r.data!.first.id, 'o1');
    });
    test('getAllOffers failure', () async {
      api.throws = true;
      final r = await repo.getAllOffers();
      expect(r.isFailure, true);
    });
    test('getOfferById success', () async {
      final r = await repo.getOfferById('o1');
      expect(r.isSuccess, true);
      expect(r.data!.id, 'o1');
    });
    test('claimOffer returns voucherCode', () async {
      final r = await repo.claimOffer('o1');
      expect(r.isSuccess, true);
      expect(r.data!['voucherCode'], 'ABC123');
    });
    test('claimOffer failure', () async {
      api.throws = true;
      final r = await repo.claimOffer('o1');
      expect(r.isFailure, true);
    });
    test('redeemOffer success', () async {
      final r = await repo.redeemOffer('o1', voucherCode: 'ABC123');
      expect(r.isSuccess, true);
      expect(r.data!['status'], 'redeemed');
    });
    test('updateOfferStatus success', () async {
      final r = await repo.updateOfferStatus('o1', false);
      expect(r.isSuccess, true);
    });
  });

  // ── VenueRepository ──────────────────────────────────────────────────────
  group('VenueRepository', () {
    late MockVenueApi api;
    late VenueRepository repo;
    setUp(() { api = MockVenueApi(); repo = VenueRepository(api); });

    test('getAllVenues success', () async {
      final r = await repo.getAllVenues();
      expect(r.isSuccess, true);
      expect(r.data!.first.id, 'v1');
    });
    test('getAllVenues failure', () async {
      api.throws = true;
      final r = await repo.getAllVenues();
      expect(r.isFailure, true);
    });
    test('getVenueById success', () async {
      final r = await repo.getVenueById('v1');
      expect(r.isSuccess, true);
      expect(r.data!.id, 'v1');
    });
    test('getVenueById failure', () async {
      api.throws = true;
      final r = await repo.getVenueById('v1');
      expect(r.isFailure, true);
    });
    test('searchVenues success', () async {
      final r = await repo.searchVenues('bar');
      expect(r.isSuccess, true);
    });
    test('trackVenueView success', () async {
      final r = await repo.trackVenueView('v1');
      expect(r.isSuccess, true);
    });
    test('trackVenueView failure', () async {
      api.throws = true;
      final r = await repo.trackVenueView('v1');
      expect(r.isFailure, true);
    });
  });

  // ── UserRepository ───────────────────────────────────────────────────────
  group('UserRepository', () {
    late MockUserApi api;
    late UserRepository repo;
    setUp(() { api = MockUserApi(); repo = UserRepository(api); });

    test('getAllUsers success', () async {
      final r = await repo.getAllUsers();
      expect(r.isSuccess, true);
      expect(r.data!.first.id, 'u1');
    });
    test('getAllUsers failure', () async {
      api.throws = true;
      final r = await repo.getAllUsers();
      expect(r.isFailure, true);
    });
    test('getProfile success', () async {
      final r = await repo.getProfile();
      expect(r.isSuccess, true);
      expect(r.data!['id'], 'u1');
      expect(r.data!['name'], 'Test User');
      expect(r.data!['email'], 'test@reki.app');
    });
    test('getProfile failure', () async {
      api.throws = true;
      final r = await repo.getProfile();
      expect(r.isFailure, true);
    });
    test('getPreferences success', () async {
      final r = await repo.getPreferences();
      expect(r.isSuccess, true);
      expect(r.data!['preferredCategories'], ['BAR']);
    });
    test('getSavedVenues success', () async {
      final r = await repo.getSavedVenues();
      expect(r.isSuccess, true);
      expect(r.data!.first['id'], 'v1');
    });
    test('saveVenue success', () async {
      final r = await repo.saveVenue('v1');
      expect(r.isSuccess, true);
    });
    test('unsaveVenue success', () async {
      final r = await repo.unsaveVenue('v1');
      expect(r.isSuccess, true);
    });
    test('getRedemptions returns empty list', () async {
      final r = await repo.getRedemptions();
      expect(r.isSuccess, true);
      expect(r.data, isEmpty);
    });
  });

  // ── NotificationRepository ───────────────────────────────────────────────
  group('NotificationRepository', () {
    late MockNotificationApi api;
    late NotificationRepository repo;
    setUp(() { api = MockNotificationApi(); repo = NotificationRepository(api); });

    test('getAllNotifications success', () async {
      final r = await repo.getAllNotifications();
      expect(r.isSuccess, true);
      expect(r.data!['today']!.first.id, 'n1');
    });
    test('getAllNotifications failure', () async {
      api.throws = true;
      final r = await repo.getAllNotifications();
      expect(r.isFailure, true);
    });
    test('markAsRead success', () async {
      final r = await repo.markAsRead('n1');
      expect(r.isSuccess, true);
    });
    test('markAllAsRead success', () async {
      final r = await repo.markAllAsRead();
      expect(r.isSuccess, true);
    });
    test('deleteNotification success', () async {
      final r = await repo.deleteNotification('n1');
      expect(r.isSuccess, true);
    });
  });
}
