import 'dart:math';
import 'crowd_prediction_service.dart';

/// Phase 7 — AI-driven smart notification timing.
///
/// Pure decision logic (unit-testable): given predicted crowd levels per hour
/// and the user's quiet-hours preference, choose the best local time to send
/// a "heads-up" notification — shortly before the venue typically peaks.
class SmartNotificationTiming {
  /// Returns the recommended send time on [day], or null if no acceptable
  /// hour exists. [peakLevels] maps hour (0-23) to predicted level (0-2).
  /// Quiet hours are in the "HH:mm" format used by NotificationPreferences.
  static DateTime? bestSendTime({
    required DateTime day,
    required Map<int, double> peakLevels,
    String? quietHoursStart, // e.g. "22:00"
    String? quietHoursEnd, // e.g. "08:00"
    double minLevel = 1.5, // target moderate→busy build-up
  }) {
    if (peakLevels.isEmpty) return null;

    // 1. Find the peak hour on [day].
    final peak = peakLevels.entries
        .reduce((a, b) => a.value >= b.value ? a : b);
    if (peak.value < minLevel) return null; // venue stays quiet — don't spam

    // 2. Notify 60–90 minutes before the peak build-up.
    final sendHour = max((peak.key - 1) - 1, 0);

    // 3. Respect quiet hours; if inside them, shift to the nearest edge.
    final candidate = DateTime(day.year, day.month, day.day, sendHour, 30);
    final adjusted = _avoidQuietHours(candidate, quietHoursStart, quietHoursEnd);
    return adjusted;
  }

  static DateTime _avoidQuietHours(
      DateTime t, String? start, String? end) {
    if (start == null || end == null) return t;
    final s = _parse(start);
    final e = _parse(end);
    if (s == null || e == null) return t;

    int minuteOfDay(DateTime d) => d.hour * 60 + d.minute;
    bool insideQuietHours(int m) =>
        s <= e ? (m >= s && m < e) : (m >= s || m < e); // overnight window

    final m = minuteOfDay(t);
    if (!insideQuietHours(m)) return t;

    // Shift to the end of the quiet window (same or next day).
    var candidate = DateTime(t.year, t.month, t.day, e ~/ 60, e % 60);
    if (candidate.isBefore(t)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  static int? _parse(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final mi = int.tryParse(parts[1]);
    if (h == null || mi == null || h > 23 || mi > 59) return null;
    return h * 60 + mi;
  }
}

/// Helper to build an hourly level map from a trained model, used by
/// background notification scheduling.
Map<int, double> hourlyLevels(CrowdPredictionModel model, DateTime day) {
  return {
    for (var h = 0; h < 24; h++)
      h: model.predict(DateTime(day.year, day.month, day.day, h)).level,
  };
}
