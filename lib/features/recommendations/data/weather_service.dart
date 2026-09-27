import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_logger.dart';
import 'recommendation_engine.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService(Dio(BaseOptions(
    baseUrl: 'https://api.open-meteo.com/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  )));
});

/// Phase 7 — weather-aware recommendations. Uses the free Open-Meteo API
/// (no key required). Failure degrades gracefully to `overcast` (neutral).
class WeatherService {
  final Dio _dio;
  WeatherService(this._dio);

  Future<WeatherCondition> currentCondition(double lat, double lon) async {
    try {
      final response = await _dio.get('/forecast', queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'current': 'weather_code',
      });
      final code =
          (response.data['current']['weather_code'] as num?)?.toInt() ?? 3;
      return _mapCode(code);
    } catch (e) {
      appLogger.w('Weather lookup failed, using neutral condition: $e');
      return WeatherCondition.overcast;
    }
  }

  /// WMO weather interpretation codes.
  static WeatherCondition _mapCode(int code) {
    if (code == 0 || code == 1) return WeatherCondition.clear;
    if (code <= 48) return WeatherCondition.overcast;
    if (code <= 67 || (code >= 80 && code <= 82)) return WeatherCondition.rain;
    if ((code >= 71 && code <= 77) || code == 85 || code == 86) {
      return WeatherCondition.snow;
    }
    if (code >= 95) return WeatherCondition.extreme;
    return WeatherCondition.overcast;
  }
}
