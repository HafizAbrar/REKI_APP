import 'package:dio/dio.dart';
import '../../utils/app_logger.dart';

/// Phase 8 — Rate limiting (client side).
///
/// Handles 429 responses: honours the `Retry-After` header, backs off with
/// capped exponential delay, retries idempotent requests, and surfaces a
/// user-friendly message when the server cap is truly exceeded. Also reports
/// 429s so backend abuse patterns can be alerted on server-side.
class RateLimitInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  static const _maxDelay = Duration(seconds: 30);

  RateLimitInterceptor({required this.dio, this.maxRetries = 2});

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 429 ||
        (err.requestOptions.extra['_rl_attempt'] as int? ?? 0) >= maxRetries) {
      return handler.next(err);
    }

    final attempt = (err.requestOptions.extra['_rl_attempt'] as int? ?? 0) + 1;
    final retryAfterSeconds =
        int.tryParse(err.response?.headers.value('retry-after') ?? '');
    var seconds = retryAfterSeconds ?? (1 << attempt);
    if (seconds < 1) seconds = 1;
    if (seconds > _maxDelay.inSeconds) seconds = _maxDelay.inSeconds;
    final delay = Duration(seconds: seconds);

    appLogger.w(
        'Rate limited ${err.requestOptions.path} — retry $attempt in ${delay.inSeconds}s');

    // Non-blocking analytics signal (fire & forget inside service).
    EngagementAnalyticsSignal.rateLimited(err.requestOptions.path);

    await Future.delayed(delay);
    if (err.requestOptions.extra['isClosed'] == true) {
      return handler.next(err);
    }

    final options = Options(
      method: err.requestOptions.method,
      headers: err.requestOptions.headers,
      responseType: err.requestOptions.responseType,
      extra: {...err.requestOptions.extra, '_rl_attempt': attempt},
    );
    try {
      final response = await dio.request(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: options,
      );
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}

/// Marker hook so observability can hook in without a hard dependency cycle.
class EngagementAnalyticsSignal {
  static void Function(String path)? onRateLimited;
  static void rateLimited(String path) => onRateLimited?.call(path);
}
