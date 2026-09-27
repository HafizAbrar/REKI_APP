import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/network/payment_api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../data/subscription_models.dart';
import 'subscription_providers.dart';

/// Phase 7 — Business billing: current plan, renewal date, and usage-based
/// billing breakdown for the current month.
class BillingScreen extends ConsumerWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(currentSubscriptionProvider);
    final usage = ref.watch(currentUsageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Plan & Billing')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentSubscriptionProvider);
            ref.invalidate(currentUsageProvider);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              subscription.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const _ErrorCard(
                    message: 'Could not load subscription. Pull to retry.'),
                data: (sub) => _PlanSummaryCard(subscription: sub),
              ),
              const SizedBox(height: 16),
              Text('Usage this month',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              usage.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const _ErrorCard(
                    message: 'Usage unavailable. Pull to retry.'),
                data: (records) => records.isEmpty
                    ? const _ErrorCard(message: 'No usage recorded yet.')
                    : Column(
                        children:
                            records.map((r) => _UsageTile(record: r)).toList()),
              ),
              const SizedBox(height: 24),
              Semantics(
                button: true,
                label: 'Manage subscription in Stripe customer portal',
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Manage in Stripe portal'),
                  onPressed: () async {
                    try {
                      final url = await ref
                          .read(paymentApiServiceProvider)
                          .createPortalSession();
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Customer portal is unavailable.')),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.push('/paywall'),
                child: const Text('Change plan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanSummaryCard extends StatelessWidget {
  final Subscription subscription;
  const _PlanSummaryCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final renewal = subscription.currentPeriodEnd != null
        ? DateFormat.yMMMd().format(subscription.currentPeriodEnd!)
        : null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subscription.tier.label,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: AppTheme.primaryColor)),
          Text('Status: ${subscription.status}'),
          if (renewal != null)
            Text(subscription.cancelAtPeriodEnd
                ? 'Cancels on $renewal'
                : 'Renews on $renewal'),
        ],
      ),
    );
  }
}

class _UsageTile extends StatelessWidget {
  final UsageRecord record;
  const _UsageTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final gbp = NumberFormat.currency(symbol: '£')
        .format(record.totalPence / 100);
    return Card(
      child: ListTile(
        title: Text(record.metric.replaceAll('_', ' ')),
        subtitle: Text(record.includedAllowance != null &&
                record.quantity > record.includedAllowance!
            ? '${record.billableQuantity} billable of ${record.quantity} used'
            : '${record.quantity} used'),
        trailing: Text(gbp,
            style: const TextStyle(color: AppTheme.primaryColor)),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message),
      ),
    );
  }
}
