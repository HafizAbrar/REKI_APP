import 'package:dio/dio.dart';
import '../../utils/app_logger.dart';

/// Retries failed requests with exponential backoff.
/// Applies to network errors and 5xx server errors only.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({required this.dio, this.maxRetries = 3});

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final attempt = err.requestOptions.extra['_retryCount'] as int? ?? 0;

    // Never retry multipart/form-data — stream cannot be replayed
    final isMultipart = err.requestOptions.data is FormData;

    final shouldRetry = !isMultipart &&
        attempt < maxRetries &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            (err.response?.statusCode != null &&
                err.response!.statusCode! >= 500));

    if (!shouldRetry) {
      handler.next(err);
      return;
    }

    final delayMs = 500 * (1 << attempt); // 500ms, 1s, 2s
    appLogger.w(
        'Request failed (attempt ${attempt + 1}/$maxRetries). '
        'Retrying in ${delayMs}ms — ${err.requestOptions.path}');

    await Future.delayed(Duration(milliseconds: delayMs));

    final options = err.requestOptions;
    options.extra['_retryCount'] = attempt + 1;

    try {
      final response = await dio.fetch(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
