import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/payment_api_service.dart';
import '../data/subscription_models.dart';

/// Current business subscription. Falls back to Free when unauthenticated or
/// when the endpoint is unavailable — the backend still enforces limits.
final currentSubscriptionProvider = FutureProvider<Subscription>((ref) async {
  final api = ref.read(paymentApiServiceProvider);
  final subscription = await api.getCurrentSubscription();
  return subscription ??
      const Subscription(id: 'free', tier: SubscriptionTier.free, status: 'active');
});

final currentTierProvider = Provider<SubscriptionTier>((ref) {
  return ref.watch(currentSubscriptionProvider).valueOrNull?.tier ??
      SubscriptionTier.free;
});

/// Whether the current tier unlocks a premium feature.
final hasPremiumAccessProvider = Provider<bool>((ref) {
  final tier = ref.watch(currentTierProvider);
  return tier != SubscriptionTier.free;
});

/// Usage-based billing for the current calendar month (Pro/Enterprise billing view).
final currentUsageProvider = FutureProvider<List<UsageRecord>>((ref) async {
  final now = DateTime.now();
  final period = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  return ref.read(paymentApiServiceProvider).getUsage(period);
});
