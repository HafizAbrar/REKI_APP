import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/observability_service.dart';
import '../data/stripe_payment_service.dart';
import '../data/subscription_models.dart';
import 'subscription_providers.dart';

/// Phase 7 — Paywall & plan picker. Reached from the business dashboard or
/// whenever a premium feature gate is triggered.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  SubscriptionTier _selected = SubscriptionTier.pro;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(observabilityProvider).trackEvent('paywall_viewed', const {});
    });
  }

  Future<void> _subscribe() async {
    final plan = SubscriptionPlan.plans.firstWhere((p) => p.tier == _selected);
    if (plan.isFree) {
      context.pop();
      return;
    }
    final observability = ref.read(observabilityProvider);
    observability.trackEvent('subscription_started', {'tier': _selected.name});
    setState(() => _processing = true);
    try {
      final paid = await ref.read(stripePaymentServiceProvider).subscribe(plan);
      if (paid && mounted) {
        observability
            .trackEvent('subscription_success', {'tier': _selected.name});
        ref.invalidate(currentSubscriptionProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome to REKI premium!')),
        );
        context.pop();
      } else {
        // Stripe Payment Sheet dismissed without paying.
        observability
            .trackEvent('subscription_cancelled', {'tier': _selected.name});
      }
    } on StripePaymentException catch (e) {
      observability.trackEvent('subscription_failed', {'tier': _selected.name});
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTier = ref.watch(currentTierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade your plan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Semantics(
              header: true,
              child: Text('Grow your venue with REKI',
                  style: Theme.of(context).textTheme.headlineSmall),
            ),
            const SizedBox(height: 16),
            ...SubscriptionPlan.plans.map((plan) => _PlanCard(
                  plan: plan,
                  selected: plan.tier == _selected,
                  isCurrent: plan.tier == currentTier,
                  onTap: () => setState(() => _selected = plan.tier),
                )),
            const SizedBox(height: 16),
            Semantics(
              button: true,
              enabled: !_processing,
              label: _selected == currentTier
                  ? 'Current plan'
                  : 'Subscribe to ${_selected.label}',
              child: FilledButton(
                onPressed:
                    _processing || _selected == currentTier ? null : _subscribe,
                child: _processing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_selected == currentTier
                        ? 'Current plan'
                        : 'Continue to payment'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Secure payments by Stripe. Cancel anytime. Usage beyond plan limits is billed at month-end.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool selected;
  final bool isCurrent;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = selected ? AppTheme.primaryColor : Colors.white24;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: selected ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(plan.tier.label,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  if (plan.highlighted)
                    const Chip(
                      label: Text('Most popular'),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (isCurrent)
                    const Icon(Icons.check_circle,
                        color: AppTheme.primaryColor),
                ],
              ),
              Text(plan.monthlyPrice,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: AppTheme.primaryColor)),
              Text(plan.tier.tagline,
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              ...plan.features.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.check,
                            size: 16, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text(f)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
