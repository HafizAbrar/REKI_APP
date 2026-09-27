import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reki_mvp/core/security/app_security_service.dart';
import 'package:reki_mvp/features/predictions/data/smart_alert_scheduler.dart';
import 'package:reki_mvp/features/predictions/data/smart_notification_timing.dart';
import 'package:reki_mvp/features/subscription/data/subscription_models.dart';
import 'package:reki_mvp/features/subscription/presentation/widgets/feature_gate.dart';

/// Phase 7/8 completion — unit coverage for the newly wired subsystems.
void main() {
  group('SmartNotificationTiming (quiet-hours respected)', () {
    final day = DateTime(2026, 9, 25); // a Friday

    test('picks ~2h before the peak hour', () {
      final levels = {for (var h = 0; h < 24; h++) h: h == 21 ? 2.0 : 0.0};
      final t = SmartNotificationTiming.bestSendTime(
          day: day, peakLevels: levels);
      expect(t, isNotNull);
      expect(t!.day, day.day);
      expect(t.hour, 19); // 21 - 2
    });

    test('no alert when venue never gets busy (anti-spam)', () {
      final levels = {for (var h = 0; h < 24; h++) h: 0.5};
      expect(SmartNotificationTiming.bestSendTime(day: day, peakLevels: levels),
          isNull);
    });

    test('no alert with empty history (safe fallback)', () {
      expect(SmartNotificationTiming.bestSendTime(day: day, peakLevels: const {}),
          isNull);
    });

    test('quiet hours shift the send time to the end of the window', () {
      final levels = {for (var h = 0; h < 24; h++) h: h == 3 ? 2.0 : 0.0};
      // Peak 3am → candidate 1:30am, inside quiet hours 22:00–08:00.
      final t = SmartNotificationTiming.bestSendTime(
          day: day, peakLevels: levels, quietHoursStart: '22:00', quietHoursEnd: '08:00');
      expect(t, isNotNull);
      final minuteOfDay = t!.hour * 60 + t.minute;
      final insideQuiet = minuteOfDay >= 22 * 60 || minuteOfDay < 8 * 60;
      expect(insideQuiet, isFalse);
    });
  });

  group('SmartVenueAlertScheduler idFor (per-venue dedupe key)', () {
    test('is stable and unique per venue id', () {
      expect(SmartVenueAlertScheduler.idFor('v1'),
          SmartVenueAlertScheduler.idFor('v1'));
      expect(SmartVenueAlertScheduler.idFor('v1'),
          isNot(SmartVenueAlertScheduler.idFor('v2')));
      expect(SmartVenueAlertScheduler.idFor('v1') >= 0, isTrue);
    });
  });

  group('AppSecurityService RASP callback', () {
    test('onHardThreat defaults to null (no blocking outside wiring)', () {
      expect(AppSecurityService().onHardThreat, isNull);
    });
  });

  group('Phase 7 subscription definitions', () {
    test('feature labels used by FeatureGate match plan features', () {
      // FeatureGate(featureName: 'Advanced analytics') guards venue-analytics.
      expect(
        SubscriptionPlan.plans
            .firstWhere((p) => p.tier == SubscriptionTier.pro)
            .features
            .any((f) => f.toLowerCase().contains('analytics')),
        isTrue,
      );
    });

    test('FeatureGate defaults to Pro minimum tier', () {
      const gate = FeatureGate(featureName: 'Advanced analytics', child: SizedBox());
      expect(gate.minimumTier, SubscriptionTier.pro);
    });
  });
}
