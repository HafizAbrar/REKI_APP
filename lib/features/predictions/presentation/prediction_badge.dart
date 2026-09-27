import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/observability_service.dart';
import '../../../core/theme/app_theme.dart';
import 'prediction_providers.dart';

/// Phase 7 — "Predicted busy at 8pm" style badge for venue cards/details.
/// Renders nothing while loading or when confidence is too low (< 0.3).
///
/// Predictions come from a statistical model over check-in history (backend
/// aggregates, local rolling-history fallback) — NOT server-side ML / a neural
/// network. UI copy says "prediction", never "AI".
class PredictionBadge extends ConsumerWidget {
  final String venueId;
  final DateTime forTime;

  PredictionBadge({
    super.key,
    required this.venueId,
    DateTime? forTime,
  }) : forTime = forTime ?? _defaultPredictionTime();

  /// Session-scoped dedupe so `prediction_viewed` fires once per badge.
  static final _tracked = <String>{};

  static DateTime _defaultPredictionTime() {
    final now = DateTime.now();
    return now.add(Duration(hours: (19 - now.hour) % 24)); // tonight ~7pm
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async =
        ref.watch(crowdPredictionProvider(CrowdPredictionRequest(venueId, forTime)));
    return async.maybeWhen(
      data: (p) {
        if (p.confidence < 0.3) return const SizedBox.shrink();
        final key = '$venueId@${forTime.hour}';
        if (_tracked.add(key)) {
          // Phase 8 — product telemetry for prediction visibility.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(observabilityProvider).trackEvent('prediction_viewed', {
              'venue_id': venueId,
              'for_hour': forTime.hour,
              'confidence_bucket': p.confidence >= 0.7
                  ? 'high'
                  : p.confidence >= 0.3
                      ? 'medium'
                      : 'low',
            });
          });
        }
        final busy = p.level >= 1.5;
        return Tooltip(
          message:
              'Statistical prediction — ${p.label} expected, confidence ${(p.confidence * 100).round()}%',
          child: Semantics(
            label:
                'Crowd prediction: expected ${p.label} at ${forTime.hour}:00',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceHighlight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up,
                      size: 14,
                      color: busy
                          ? const Color(0xFFFCA5A5)
                          : AppTheme.primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    'Expect ${p.label.toLowerCase()} ~${forTime.hour}:00',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
