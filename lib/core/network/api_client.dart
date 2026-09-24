import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/env.dart';
import '../services/city_providers.dart';
import 'interceptors/city_interceptor.dart';
import '../utils/app_logger.dart';
import 'interceptors/auth_interceptor.dart';
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

  // Auth token injection + 401 refresh
  final auth = AuthInterceptor();
  dio.interceptors.add(auth);
  ref.onDispose(auth.dispose);

  // Exponential backoff retry (Week 7)
  dio.interceptors.add(RetryInterceptor(dio: dio, maxRetries: 3));

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
