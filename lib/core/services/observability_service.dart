import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../utils/app_logger.dart';

final observabilityProvider = Provider<ObservabilityService>((ref) {
  return ObservabilityService(ref.read(apiClientProvider));
});

/// Phase 8 — Observability layer.
///
/// - Wraps Crashlytics custom keys + non-fatal reporting.
/// - Custom product events (Firebase Analytics).
/// - Backend failure alerting: aggregates client-observed 5xx and network
///   failures and reports them to POST /observability/alerts (see
///   PHASE8_IMPLEMENTATION.md) so the ops team gets signals even while the
///   backend APM is being set up.
class ObservabilityService {
  final Dio _dio;

  int _failuresInWindow = 0;
  DateTime? _windowStart;
  bool _alertSent = false;

  static const _window = Duration(minutes: 5);
  static const _burstThreshold = 10; // 10 backend failures / 5 min

  ObservabilityService(this._dio) {
    backendFailureListeners.add(recordBackendFailure);
  }

  /// Registered sinks that receive every backend 5xx/network failure observed
  /// by the global [BackendFailureInterceptor]. Kept static so the interceptor
  /// (inside [apiClientProvider]) does not create a provider circular
  /// dependency on [observabilityProvider].
  static final backendFailureListeners = <void Function(String, int?)>{};

  /// Tag Crashlytics so crash reports can be sliced by user context.
  void setUserContext({String? userId, String? role, String? city}) {
    try {
      if (userId != null) {
        FirebaseCrashlytics.instance.setUserIdentifier(userId);
      }
      if (role != null) FirebaseCrashlytics.instance.setCustomKey('role', role);
      if (city != null) FirebaseCrashlytics.instance.setCustomKey('city', city);
    } catch (_) {}
  }

  void reportNonFatal(Object error,
      {StackTrace? stack, String? context}) {
    try {
      FirebaseCrashlytics.instance.recordError(error, stack,
          reason: context, fatal: false);
    } catch (_) {}
  }

  /// Records a backend failure and, on sustained bursts, alerts the backend.
  /// Call from the global Dio error path.
  void recordBackendFailure(String endpoint, int? statusCode) {
    final now = DateTime.now();
    if (_windowStart == null || now.difference(_windowStart!) > _window) {
      _windowStart = now;
      _failuresInWindow = 0;
      _alertSent = false;
    }
    _failuresInWindow++;

    if (_failuresInWindow >= _burstThreshold && !_alertSent) {
      _alertSent = true;
      _sendAlert(endpoint, statusCode);
    }
  }

  Future<void> _sendAlert(String endpoint, int? statusCode) async {
    try {
      await _dio.post('/observability/alerts', data: {
        'type': 'client_backend_failure_burst',
        'endpoint': endpoint,
        'statusCode': statusCode,
        'count': _failuresInWindow,
        'windowMinutes': _window.inMinutes,
        'appVersion': '1.0.0',
        'platform': 'flutter',
      });
      appLogger.w('Backend failure alert posted for $endpoint');
    } catch (e) {
      // The backend may be down — never crash the app from alerting.
      appLogger.e('Failed to post observability alert: $e');
    }
  }

  /// Custom product event. Delegates to the analytics sink; events are
  /// surfaced in Firebase Analytics / BigQuery dashboards.
  /// Custom product event. Delegates to the analytics sink; events are
  /// surfaced in Firebase Analytics / BigQuery dashboards.
  Future<void> trackEvent(String name, Map<String, Object> params) async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
    } catch (_) {
      // Observability must never block user actions.
    }
  }
}

/// Dio interceptor that reports backend 5xx responses and transport failures
/// to every registered [ObservabilityService.backendFailureListeners] sink so
/// sustained bursts trigger the client-side alerting path added in Phase 8.
class BackendFailureInterceptor extends Interceptor {
  const BackendFailureInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    final isTransport = err.response == null &&
        (err.type == DioExceptionType.connectionError ||
            err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.sendTimeout);
    final isServerError = status != null && status >= 500;
    if (isTransport || isServerError) {
      for (final listener in ObservabilityService.backendFailureListeners) {
        try {
          listener(err.requestOptions.path, status);
        } catch (_) {}
      }
    }
    handler.next(err);
  }
}
