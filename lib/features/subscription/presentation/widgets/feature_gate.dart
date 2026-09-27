import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/subscription_models.dart';
import '../subscription_providers.dart';

/// Phase 7 — Gates premium functionality behind a subscription tier.
///
/// Wrap a premium widget or route entry point; Free-tier users see an
/// upgrade prompt that routes to the paywall. Backend enforces limits
/// authoritatively — this is UX only.
class FeatureGate extends ConsumerWidget {
  final SubscriptionTier minimumTier;
  final String featureName;
  final Widget child;

  const FeatureGate({
    super.key,
    this.minimumTier = SubscriptionTier.pro,
    required this.featureName,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(currentTierProvider);
    if (tier.index >= minimumTier.index) return child;
    return _LockedPrompt(featureName: featureName, tier: minimumTier);
  }
}

class _LockedPrompt extends StatelessWidget {
  final String featureName;
  final SubscriptionTier tier;
  const _LockedPrompt({required this.featureName, required this.tier});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: AppTheme.primaryColor),
            const SizedBox(height: 12),
            Text('$featureName is a ${tier.label} feature',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text(
              'Upgrade your plan to unlock analytics, priority placement and more.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Semantics(
              button: true,
              label: 'View upgrade plans',
              child: FilledButton(
                onPressed: () => context.push('/paywall'),
                child: const Text('View plans'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
