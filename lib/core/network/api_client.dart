import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/env.dart';
import '../services/city_providers.dart';
import 'interceptors/city_interceptor.dart';
import '../security/certificate_pinning.dart';
import '../services/observability_service.dart';
import '../utils/app_logger.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/rate_limit_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
    },
  ));

  dio.interceptors
      .add(CityInterceptor(() => ref.read(selectedCityProvider.future)));

  // Phase 8 — TLS certificate pinning (configure via --dart-define CERT_PINS)
  applyCertificatePinning(dio);

  // Auth token injection + 401 refresh
  final auth = AuthInterceptor();
  dio.interceptors.add(auth);
  ref.onDispose(auth.dispose);

  // Exponential backoff retry (Week 7)
  dio.interceptors.add(RetryInterceptor(dio: dio, maxRetries: 3));

  // Phase 8 — 429 handling with Retry-After honour (rate limiting)
  dio.interceptors.add(RateLimitInterceptor(dio: dio));

  // Phase 8 — feed backend failures into client-side observability alerting
  dio.interceptors.add(const BackendFailureInterceptor());

  // Structured request logging — debug only (Week 7)
  if (kDebugMode) {
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: false,
      requestBody: false,
      responseBody: false,
      responseHeader: false,
      error: true,
      compact: true,
      logPrint: (obj) => appLogger.d(obj.toString()),
    ));
  }

  ref.onDispose(() => dio.close(force: true));
  return dio;
});
