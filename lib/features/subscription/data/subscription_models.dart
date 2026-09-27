// Phase 7 — Payments & Monetization.
//
// Business subscription tiers (Free / Pro / Enterprise) with usage-based
// billing. The backend is the source of truth (Stripe customer portal +
// webhooks); these models describe the contract consumed by the client.

enum SubscriptionTier { free, pro, enterprise }

enum BillingPeriod { monthly, yearly }

extension BillingPeriodX on BillingPeriod {
  String get apiValue => name.toUpperCase();
}

extension SubscriptionTierX on SubscriptionTier {
  String get name => switch (this) {
        SubscriptionTier.free => 'free',
        SubscriptionTier.pro => 'pro',
        SubscriptionTier.enterprise => 'enterprise',
      };

  String get label => switch (this) {
        SubscriptionTier.free => 'Free',
        SubscriptionTier.pro => 'Pro',
        SubscriptionTier.enterprise => 'Enterprise',
      };

  String get tagline => switch (this) {
        SubscriptionTier.free => 'Get discovered. Pay nothing.',
        SubscriptionTier.pro =>
          'Grow with analytics, offers and priority placement.',
        SubscriptionTier.enterprise =>
          'Full control, multi-venue and dedicated support.',
      };

  static SubscriptionTier parse(String? value) =>
      switch (value?.toLowerCase()) {
        'pro' => SubscriptionTier.pro,
        'enterprise' => SubscriptionTier.enterprise,
        _ => SubscriptionTier.free,
      };
}

/// Static plan catalogue shown on the paywall. Prices are display-only;
/// actual billing happens via Stripe prices managed on the backend.
class SubscriptionPlan {
  final SubscriptionTier tier;
  final String monthlyPrice; // e.g. "£0", "£49", "Custom"
  final String stripePriceId; // backend-defined Stripe price id, '' for free
  final List<String> features;
  final bool highlighted;

  const SubscriptionPlan({
    required this.tier,
    required this.monthlyPrice,
    required this.stripePriceId,
    required this.features,
    this.highlighted = false,
  });

  bool get isFree => tier == SubscriptionTier.free;
  String get backendCode => tier.name.toUpperCase();

  static const plans = <SubscriptionPlan>[
    SubscriptionPlan(
      tier: SubscriptionTier.free,
      monthlyPrice: '£0',
      stripePriceId: '',
      features: [
        '1 venue listing',
        '5 active offers',
        'Basic crowd-level updates',
      ],
    ),
    SubscriptionPlan(
      tier: SubscriptionTier.pro,
      monthlyPrice: '£49/mo',
      stripePriceId:
          String.fromEnvironment('STRIPE_PRICE_PRO', defaultValue: ''),
      highlighted: true,
      features: [
        '3 venue listings',
        '50 active offers',
        'Advanced analytics & heatmaps',
        'Priority search placement',
        'Smart recommendation boost',
      ],
    ),
    SubscriptionPlan(
      tier: SubscriptionTier.enterprise,
      monthlyPrice: 'Custom',
      stripePriceId:
          String.fromEnvironment('STRIPE_PRICE_ENTERPRISE', defaultValue: ''),
      features: [
        'Unlimited venues',
        'Unlimited offers',
        'API access & custom integrations',
        'Predictive crowd insights',
        'Dedicated account manager',
      ],
    ),
  ];

  /// High-water limits enforced client-side for instant feedback. The backend
  /// must enforce the same limits authoritatively.
  static int offerLimitFor(SubscriptionTier tier) => switch (tier) {
        SubscriptionTier.free => 5,
        SubscriptionTier.pro => 50,
        SubscriptionTier.enterprise => 1 << 30,
      };

  static int venueLimitFor(SubscriptionTier tier) => switch (tier) {
        SubscriptionTier.free => 1,
        SubscriptionTier.pro => 3,
        SubscriptionTier.enterprise => 1 << 30,
      };
}

class Subscription {
  final String id;
  final SubscriptionTier tier;
  final String status; // active/trialing/past_due/canceled
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final String? stripeCustomerId;

  const Subscription({
    required this.id,
    required this.tier,
    required this.status,
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
    this.stripeCustomerId,
  });

  bool get isActive => status == 'active' || status == 'trialing';

  factory Subscription.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final plan = data['plan'] is Map
        ? Map<String, dynamic>.from(data['plan'] as Map)
        : const <String, dynamic>{};
    return Subscription(
      id: data['id']?.toString() ?? 'free',
      tier: SubscriptionTierX.parse(data['tier']?.toString() ??
          data['planCode']?.toString() ??
          plan['code']?.toString()),
      status: data['status']?.toString().toLowerCase() ?? 'active',
      currentPeriodEnd: data['currentPeriodEnd'] != null
          ? DateTime.tryParse(data['currentPeriodEnd'].toString())
          : null,
      cancelAtPeriodEnd: data['cancelAtPeriodEnd'] as bool? ?? false,
      stripeCustomerId: data['stripeCustomerId']?.toString(),
    );
  }
}

/// Usage-based billing record (per calendar month).
class UsageRecord {
  final String metric; // e.g. 'redemptions', 'notifications_sent'
  final int quantity;
  final double unitPricePence;
  final double totalPence;
  final int? includedAllowance;

  const UsageRecord({
    required this.metric,
    required this.quantity,
    required this.unitPricePence,
    required this.totalPence,
    this.includedAllowance,
  });

  int get billableQuantity {
    final allowance = includedAllowance ?? 0;
    return (quantity - allowance).clamp(0, quantity);
  }

  factory UsageRecord.fromJson(Map<String, dynamic> json) => UsageRecord(
        metric: json['metric'] as String,
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        unitPricePence: (json['unitPricePence'] as num?)?.toDouble() ?? 0,
        totalPence: (json['totalPence'] as num?)?.toDouble() ?? 0,
        includedAllowance: (json['includedAllowance'] as num?)?.toInt(),
      );
}
