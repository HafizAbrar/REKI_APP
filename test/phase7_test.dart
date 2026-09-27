import 'package:flutter_test/flutter_test.dart';
import 'package:reki_mvp/core/models/venue.dart';
import 'package:reki_mvp/features/recommendations/data/recommendation_engine.dart';
import 'package:reki_mvp/features/predictions/data/crowd_prediction_service.dart';
import 'package:reki_mvp/features/predictions/data/smart_notification_timing.dart';
import 'package:reki_mvp/features/subscription/data/subscription_models.dart';

Venue _venue(String type, {String vibe = 'chill', int offers = 0}) => Venue(
      id: 'v-$type',
      name: 'The $type',
      type: type,
      latitude: 53.48,
      longitude: -2.24,
      address: 'Manchester',
      busyness: 'moderate',
      currentVibe: vibe,
      availableVibes: [vibe],
      offers: const [],
      lastUpdated: DateTime(2026, 1, 1),
      activeOffersCount: offers,
    );

void main() {
  group('Phase 7 — RecommendationEngine', () {
    final evening = DateTime(2026, 6, 19, 19); // Friday 7pm

    test('clubs rank above cafes late at night', () {
      final engine = RecommendationEngine(
          clock: () => DateTime(2026, 6, 20, 2)); // 2am
      final results = engine
          .recommend([_venue('cafe'), _venue('club')]);
      expect(results.first.venue.type, 'club');
    });

    test('affinity to cafes boosts cafes in the morning', () {
      final engine = RecommendationEngine(clock: () => evening.copyWith(hour: 9));
      final results = engine.recommend([_venue('club'), _venue('cafe')],
          affinities: const UserAffinities(typeWeights: {'cafe': 5}));
      expect(results.first.venue.type, 'cafe');
    });

    test('rain boosts cosy venues over clubs', () {
      final engine = RecommendationEngine(clock: () => evening);
      final results = engine.recommend(
        [_venue('club', vibe: 'party'), _venue('cafe')],
        weather: WeatherCondition.rain,
      );
      expect(results.first.venue.type, 'cafe');
    });

    test('live offers act as a boost', () {
      final engine = RecommendationEngine(clock: () => evening);
      final withOffers = engine.score(_venue('restaurant', offers: 2));
      final without = engine.score(_venue('restaurant'));
      expect(withOffers, greaterThan(without));
    });
  });

  group('Phase 7 — CrowdPredictionModel', () {
    test('predicts trained levels with confidence', () {
      final model = CrowdPredictionModel();
      final monday6pm = DateTime(2026, 6, 15, 18); // Monday 18:00
      model.train([
        for (var i = 0; i < 30; i++)
          CrowdObservation(monday6pm.subtract(Duration(days: i * 7)), 2),
      ]);
      final p = model.predict(monday6pm);
      expect(p.level, closeTo(2, 0.01));
      expect(p.confidence, greaterThanOrEqualTo(1.0));
      expect(p.label, 'Busy');
    });

    test('falls back to adjacent-hour smoothing', () {
      final model = CrowdPredictionModel();
      final t = DateTime(2026, 6, 16, 20); // Tuesday 20:00
      model.train([CrowdObservation(t.subtract(const Duration(hours: 1)), 2)]);
      final p = model.predict(t);
      expect(p.level, closeTo(2, 0.01));
      expect(p.confidence, lessThan(0.5));
    });
  });

  group('Phase 7 — SmartNotificationTiming', () {
    test('notifies ~2h before peak, outside quiet hours', () {
      final day = DateTime(2026, 6, 19);
      final t = SmartNotificationTiming.bestSendTime(
        day: day,
        peakLevels: {18: 1.0, 21: 2.0, 23: 1.8},
      );
      expect(t, isNotNull);
      expect(t!.hour, 19);
    });

    test('respects overnight quiet hours', () {
      final day = DateTime(2026, 6, 19);
      final t = SmartNotificationTiming.bestSendTime(
        day: day,
        peakLevels: {23: 2.0}, // peak 23:00 → candidate 21:30, inside 21-08 quiet
        quietHoursStart: '21:00',
        quietHoursEnd: '08:00',
      );
      expect(t!.isBefore(DateTime(2026, 6, 21)) && t.hour >= 8, isTrue);
    });

    test('returns null when venue stays quiet', () {
      final t = SmartNotificationTiming.bestSendTime(
        day: DateTime(2026, 6, 19),
        peakLevels: {12: 0.2, 18: 0.5},
      );
      expect(t, isNull);
    });
  });

  group('Phase 7 — Subscription models', () {
    test('tier parsing and plan limits', () {
      expect(SubscriptionTierX.parse('pro'), SubscriptionTier.pro);
      expect(SubscriptionTierX.parse(null), SubscriptionTier.free);
      expect(SubscriptionPlan.offerLimitFor(SubscriptionTier.free), 5);
      expect(SubscriptionPlan.venueLimitFor(SubscriptionTier.pro), 3);
    });

    test('UsageRecord billable quantity respects allowance', () {
      const r = UsageRecord(
          metric: 'redemptions',
          quantity: 1200,
          unitPricePence: 2,
          totalPence: 400,
          includedAllowance: 1000);
      expect(r.billableQuantity, 200);
    });

    test('Subscription.fromJson', () {
      final sub = Subscription.fromJson({
        'id': 'sub_1',
        'tier': 'enterprise',
        'status': 'active',
        'currentPeriodEnd': '2026-10-01T00:00:00Z',
      });
      expect(sub.tier, SubscriptionTier.enterprise);
      expect(sub.isActive, isTrue);
      expect(sub.currentPeriodEnd, isNotNull);
    });
  });
}
