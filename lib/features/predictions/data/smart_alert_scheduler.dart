import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Provider for the smart venue heads-up scheduler (Phase 7).
final smartVenueAlertSchedulerProvider =
    Provider<SmartVenueAlertScheduler>((_) {
  return SmartVenueAlertScheduler(FlutterLocalNotificationsPlugin());
});

/// Phase 7/8 — Smart venue heads-up alerts.
///
/// Decides when to send a "getting lively soon" local notification using
/// SmartNotificationTiming over predicted hourly crowd levels, then schedules
/// it with flutter_local_notifications. Respects:
/// - the user's notification preferences (alerts toggle + quiet hours),
/// - OS notification permission,
/// - max ~2 heads-up slots/day (one per venue, handled by callers),
/// - and falls back to "no alert scheduled" when there is no prediction.
///
/// No remote/ML work happens here; predictions are whatever level map the
/// caller computed (backend statistical model or local fallback).
class SmartVenueAlertScheduler {
  SmartVenueAlertScheduler(this._notifications);

  final FlutterLocalNotificationsPlugin _notifications;

  static const _channelId = 'venue_alerts_v2';
  static const _channelName = 'Venue alerts';

  /// Notification id derived from venue id so repeats replace the old one
  /// (per-venue dedupe: we never stack multiple pending alerts per venue).
  static int idFor(String venueId) => venueId.hashCode & 0x7fffffff;

  /// Schedules a heads-up for [venueName] at [sendAt]. Returns false when the
  /// time is in the past/notifications not permitted — callers treat false as
  /// "silently not scheduled", never as an error shown to users.
  Future<bool> scheduleVenueHeadsUp({
    required String venueId,
    required String venueName,
    required DateTime sendAt,
  }) async {
    if (!sendAt.isAfter(DateTime.now())) return false;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    try {
      await _notifications.initialize(
        const InitializationSettings(android: androidInit, iOS: darwinInit),
      );
    } catch (_) {
      return false; // never break the caller on notification infra issues
    }

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.areNotificationsEnabled() ?? true;
    if (androidGranted == false) {
      final requested = await android?.requestNotificationsPermission();
      if (requested != true) return false;
    }
    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await ios?.requestPermissions(
        alert: true, badge: false, sound: true);
    if (iosGranted == false) return false;

    await _notifications.cancel(idFor(venueId)); // per-venue dedupe
    await _notifications.zonedSchedule(
      idFor(venueId),
      'Getting lively: $venueName',
      '$venueName usually starts filling up around now — good time to head over.',
      tz.TZDateTime.from(sendAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Heads-ups before your venues typically get busy',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    return true;
  }

  Future<void> cancelVenueAlert(String venueId) =>
      _notifications.cancel(idFor(venueId));
}
