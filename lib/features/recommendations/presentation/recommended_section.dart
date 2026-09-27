import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/observability_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../data/intelligence_api_service.dart';
import 'recommendation_providers.dart';

/// Phase 7 — "Recommended for you" horizontal section for the home screen.
///
/// Production-ready MVP recommendation UI backed by the LOCAL heuristic engine
/// (RecommendationEngine): venue affinities learned on-device from taps,
/// check-ins and redemptions plus live busyness/weather signals. This is NOT
/// collaborative filtering and no server-side ML is implied.
class RecommendedSection extends ConsumerStatefulWidget {
  final void Function(String venueId) onVenueTap;
  const RecommendedSection({super.key, required this.onVenueTap});

  @override
  ConsumerState<RecommendedSection> createState() => _RecommendedSectionState();
}

class _RecommendedSectionState extends ConsumerState<RecommendedSection> {
  bool _impressionTracked = false;

  void _onTap(dynamic venueId, dynamic venueType) {
    ref
        .read(observabilityProvider)
        .trackEvent('recommendation_opened', {'venue_id': venueId.toString()});
    // Weak interaction signal feeding the local affinity model.
    ref
        .read(userAffinitiesProvider.notifier)
        .record(venueType: venueType.toString(), weight: 0.25);
    unawaited(
      ref.read(intelligenceApiServiceProvider).recordInteraction(
            type: 'recommendation_click',
            venueId: venueId.toString(),
          ),
    );
    widget.onVenueTap(venueId.toString());
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(recommendationsProvider);
    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (results) {
        if (results.isEmpty) return const SizedBox.shrink();
        if (!_impressionTracked) {
          _impressionTracked = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ref.read(observabilityProvider).trackEvent(
                'recommendation_impression', {'count': results.length});
          });
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Recommended for you',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            SizedBox(
              height: 144,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final r = results[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Semantics(
                      button: true,
                      label:
                          '${r.venue.name}, ${r.reason}. Double tap to view details.',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _onTap(r.venue.id, r.venue.type),
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(r.venue.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text(r.reason,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white70)),
                              const SizedBox(height: 6),
                              const Icon(Icons.auto_awesome,
                                  size: 16, color: AppTheme.primaryColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
