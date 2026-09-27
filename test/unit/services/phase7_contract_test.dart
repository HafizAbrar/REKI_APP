import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reki_mvp/core/network/payment_api_service.dart';
import 'package:reki_mvp/features/predictions/data/crowd_prediction_service.dart';
import 'package:reki_mvp/features/recommendations/data/intelligence_api_service.dart';
import 'package:reki_mvp/features/subscription/data/subscription_models.dart';

class _Adapter implements HttpClientAdapter {
  final FutureOr<ResponseBody> Function(RequestOptions) respond;
  _Adapter(this.respond);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      respond(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _body(Object data) => ResponseBody.fromString(
      jsonEncode(data),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

Dio _client(FutureOr<ResponseBody> Function(RequestOptions) respond) =>
    Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _Adapter(respond);

void main() {
  test('payment sheet request matches the live backend DTO', () async {
    late RequestOptions captured;
    final service = PaymentApiService(_client((request) {
      captured = request;
      return _body({
        'data': {
          'paymentIntentClientSecret': 'pi_secret',
          'customerId': 'cus_1',
        },
      });
    }));

    final result = await service.initPaymentSheet(
      plan: 'PRO',
      billingPeriod: BillingPeriod.yearly,
      idempotencyKey: 'request-1',
    );

    expect(captured.path, '/payments/subscriptions/init-sheet');
    expect(captured.data, {
      'plan': 'PRO',
      'billingPeriod': 'YEARLY',
      'idempotencyKey': 'request-1',
    });
    expect(result['paymentIntentClientSecret'], 'pi_secret');
  });

  test('recommendations parse nested venues and preserve ranking scores',
      () async {
    final service = IntelligenceApiService(_client((request) {
      expect(request.path, '/recommendations');
      expect(request.queryParameters['limit'], 5);
      return _body({
        'recommendations': [
          {
            'venue': {'id': 'venue-7'},
            'score': 0.92,
            'reason': 'Popular nearby',
          }
        ],
      });
    }));

    final results = await service.recommendations(
      latitude: 53.48,
      longitude: -2.24,
      limit: 5,
    );

    expect(results.single.venueId, 'venue-7');
    expect(results.single.score, 0.92);
  });

  test('backend crowd prediction maps API levels and confidence', () {
    final prediction = CrowdPrediction.fromBackend({
      'timestamp': '2026-09-27T20:00:00Z',
      'predictedLevel': 'busy',
      'expectedPercentage': 85,
      'confidence': 0.75,
    });

    expect(prediction.level, 2);
    expect(prediction.label, 'Busy');
    expect(prediction.confidence, 0.75);
  });

  test('subscription parser accepts nested uppercase backend plan', () {
    final subscription = Subscription.fromJson({
      'data': {
        'id': 'sub_1',
        'status': 'ACTIVE',
        'plan': {'code': 'ENTERPRISE'},
      },
    });

    expect(subscription.tier, SubscriptionTier.enterprise);
    expect(subscription.isActive, isTrue);
  });
}
