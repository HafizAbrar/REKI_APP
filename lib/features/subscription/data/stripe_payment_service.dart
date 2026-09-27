import 'dart:math';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/network/payment_api_service.dart';
import 'subscription_models.dart';

final stripePaymentServiceProvider = Provider<StripePaymentService>((ref) {
  return StripePaymentService(ref.read(paymentApiServiceProvider));
});

class StripePaymentException implements Exception {
  final String message;
  const StripePaymentException(this.message);
  @override
  String toString() => message;
}

/// Phase 7 — Stripe Payment Sheet flow for business subscriptions.
///
/// The backend creates the Stripe subscription and returns PaymentSheet
/// parameters; this service never touches Stripe secret keys.
class StripePaymentService {
  final PaymentApiService _api;
  bool _initialised = false;

  StripePaymentService(this._api);

  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  /// Initialises the Stripe SDK. Idempotent and safe to call on app start.
  Future<void> ensureInitialised() async {
    if (_initialised) return;
    if (publishableKey.isEmpty) {
      appLogger.w('Stripe publishable key not configured '
          '(--dart-define STRIPE_PUBLISHABLE_KEY) — payments disabled');
      return;
    }
    try {
      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();
      _initialised = true;
    } catch (e) {
      appLogger.w('Stripe init skipped: $e');
    }
  }

  bool get isConfigured => publishableKey.isNotEmpty;

  /// Runs the full payment-sheet flow for [plan]. Throws
  /// [StripePaymentException] with a user-safe message on failure;
  /// returns false when the user cancelled.
  Future<bool> subscribe(
    SubscriptionPlan plan, {
    BillingPeriod billingPeriod = BillingPeriod.monthly,
  }) async {
    await ensureInitialised();
    if (!_initialised) {
      throw const StripePaymentException('Payments are not configured yet.');
    }

    final params = await _api.initPaymentSheet(
      plan: plan.backendCode,
      billingPeriod: billingPeriod,
      idempotencyKey: _idempotencyKey(),
    );

    final paymentSecret =
        params['paymentIntentClientSecret'] ?? params['paymentIntent'];
    final setupSecret =
        params['setupIntentClientSecret'] ?? params['setupIntent'];
    if (paymentSecret == null && setupSecret == null) {
      throw const StripePaymentException(
          'The payment service returned an invalid session.');
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        merchantDisplayName: 'REKI',
        paymentIntentClientSecret: paymentSecret?.toString(),
        setupIntentClientSecret: setupSecret?.toString(),
        customerEphemeralKeySecret:
            (params['ephemeralKey'] ?? params['ephemeralKeySecret'])
                ?.toString(),
        customerId: params['customerId']?.toString(),
        style: ThemeMode.dark,
      ),
    );

    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return false;
      throw StripePaymentException(
        e.error.localizedMessage ?? 'Payment failed. Please try again.',
      );
    }
  }

  static String _idempotencyKey() {
    final random = Random.secure();
    final suffix = List.generate(
            16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'))
        .join();
    return 'flutter-${DateTime.now().microsecondsSinceEpoch}-$suffix';
  }
}
