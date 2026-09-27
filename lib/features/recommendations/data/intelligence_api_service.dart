import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';

final intelligenceApiServiceProvider = Provider<IntelligenceApiService>((ref) {
  return IntelligenceApiService(ref.read(apiClientProvider));
});

class BackendRecommendation {
  final String venueId;
  final double score;
  final String? reason;

  const BackendRecommendation({
    required this.venueId,
    required this.score,
    this.reason,
  });

  factory BackendRecommendation.fromJson(Map<String, dynamic> json) {
    final venue = json['venue'] is Map ? json['venue'] as Map : null;
    return BackendRecommendation(
      venueId: (json['venueId'] ?? json['id'] ?? venue?['id']).toString(),
      score: (json['score'] as num?)?.toDouble() ?? 0,
      reason: json['reason']?.toString(),
    );
  }
}

class IntelligenceApiService {
  final Dio _dio;

  IntelligenceApiService(this._dio);

  Future<List<BackendRecommendation>> recommendations({
    required double latitude,
    required double longitude,
    int limit = 10,
  }) async {
    final response = await _dio.get('/recommendations', queryParameters: {
      'latitude': latitude,
      'longitude': longitude,
      'limit': limit,
    });
    final body = response.data;
    final raw = body is List
        ? body
        : body is Map
            ? body['recommendations'] ??
                body['items'] ??
                body['data'] ??
                const []
            : const [];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) =>
            BackendRecommendation.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.venueId.isNotEmpty)
        .toList();
  }

  Future<void> recordInteraction({
    required String type,
    String? venueId,
    String? offerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _dio.post('/recommendations/events', data: {
        'type': type,
        if (venueId != null) 'venueId': venueId,
        if (offerId != null) 'offerId': offerId,
        if (metadata != null && metadata.isNotEmpty) 'metadata': metadata,
      });
    } on DioException catch (error) {
      appLogger.w('Recommendation event not recorded: ${error.message}');
    }
  }

  Future<List<Map<String, dynamic>>> crowdPredictions({
    required String venueId,
    required DateTime from,
    int hours = 24,
  }) async {
    final response = await _dio.get(
      '/venues/$venueId/busyness/predictions',
      queryParameters: {
        'from': from.toUtc().toIso8601String(),
        'hours': hours,
      },
    );
    final body = response.data;
    final raw = body is List
        ? body
        : body is Map
            ? body['predictions'] ?? body['items'] ?? body['data'] ?? const []
            : const [];
    return raw is List
        ? raw
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
        : const [];
  }
}
