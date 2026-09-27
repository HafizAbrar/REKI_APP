import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/subscription/data/subscription_models.dart';
import 'api_client.dart';

final paymentApiServiceProvider = Provider<PaymentApiService>((ref) {
  return PaymentApiService(ref.read(apiClientProvider));
});

/// Phase 7 — Stripe billing REST contract.
///
/// Backend requirements are specified in PHASE7_BACKEND_REQUIREMENTS.md.
/// The backend owns Stripe secrets; the client only receives ephemeral keys,
/// PaymentSheet params, and subscription state.
class PaymentApiService {
  final Dio _dio;

  PaymentApiService(this._dio);

  /// GET /subscriptions/current — current business subscription, or null (free).
  Future<Subscription?> getCurrentSubscription() async {
    final response = await _dio.get('/subscriptions/current');
    final data = response.data;
    if (data == null) return null;
    return Subscription.fromJson(data as Map<String, dynamic>);
  }

  /// POST /payments/subscriptions/init-sheet — backend creates/retrieves the
  /// Stripe subscription and returns everything needed to open PaymentSheet.
  /// Response: { paymentIntentClientSecret, ephemeralKey, customerId }.
  Future<Map<String, dynamic>> initPaymentSheet({
    required String plan,
    required BillingPeriod billingPeriod,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post(
      '/payments/subscriptions/init-sheet',
      data: {
        'plan': plan,
        'billingPeriod': billingPeriod.apiValue,
        'idempotencyKey': idempotencyKey,
      },
    );
    final body = Map<String, dynamic>.from(response.data as Map);
    return body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
  }

  /// GET /billing/usage?period=YYYY-MM — usage-based billing breakdown.
  Future<List<UsageRecord>> getUsage(String period) async {
    final response =
        await _dio.get('/billing/usage', queryParameters: {'period': period});
    final body = response.data;
    final raw = body is List
        ? body
        : body is Map
            ? body['usage'] ?? body['items'] ?? body['data'] ?? const []
            : const [];
    return (raw as List)
        .map((json) => UsageRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /payments/portal-session — returns { url } for the Stripe Customer
  /// Portal (manage/cancel subscription). Open via url_launcher.
  Future<String> createPortalSession() async {
    final response = await _dio.post('/payments/portal-session');
    final body = Map<String, dynamic>.from(response.data as Map);
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;
    return data['url'] as String;
  }
}
