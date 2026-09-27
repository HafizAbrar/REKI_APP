import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';
import '../../recommendations/data/intelligence_api_service.dart';
import '../data/crowd_prediction_service.dart';

/// Phase 7 — crowd prediction per venue.
///
/// Trains a [CrowdPredictionModel] from backend history when available
/// (GET /venues/{id}/busyness/history — see PHASE7_BACKEND_REQUIREMENTS.md);
/// otherwise falls back to the locally cached rolling history.
final crowdPredictionProvider =
    FutureProvider.family<CrowdPrediction, CrowdPredictionRequest>(
        (ref, request) async {
  try {
    final predictions =
        await ref.read(intelligenceApiServiceProvider).crowdPredictions(
              venueId: request.venueId,
              from: request.forTime,
              hours: 1,
            );
    if (predictions.isNotEmpty) {
      return CrowdPrediction.fromBackend(
        predictions.first,
        fallbackTime: request.forTime,
      );
    }
  } on DioException catch (e) {
    appLogger.w('Crowd prediction unavailable ($e) - training local model');
  }

  final model = CrowdPredictionModel();
  List<CrowdObservation> history = const [];
  try {
    final dio = ref.read(apiClientProvider);
    final response = await dio.get(
      '/venues/${request.venueId}/busyness/history',
      queryParameters: {
        'from': request.forTime
            .subtract(const Duration(days: 84))
            .toUtc()
            .toIso8601String(),
        'to': request.forTime.toUtc().toIso8601String(),
      },
    );
    final body = response.data;
    final raw = body is List
        ? body
        : body is Map
            ? body['history'] ?? body['items'] ?? body['data'] ?? const []
            : const [];
    history = (raw as List)
        .whereType<Map>()
        .map((j) => CrowdObservation.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  } on DioException catch (e) {
    // Endpoint optional — degrade to local rolling history.
    appLogger.w('Busyness history unavailable ($e) — using local history');
    history = CrowdHistoryStore.instance.observationsFor(request.venueId);
  }
  model.train(history);
  return model.predict(request.forTime);
});

class CrowdPredictionRequest {
  final String venueId;
  final DateTime forTime;
  const CrowdPredictionRequest(this.venueId, this.forTime);

  @override
  bool operator ==(Object other) =>
      other is CrowdPredictionRequest &&
      other.venueId == venueId &&
      other.forTime == forTime;

  @override
  int get hashCode => Object.hash(venueId, forTime);
}

/// Rolling local history: records each observed live busyness snapshot so the
/// model keeps improving even without the backend history endpoint.
class CrowdHistoryStore {
  static final CrowdHistoryStore instance = CrowdHistoryStore._();
  CrowdHistoryStore._();

  static const int _maxPerVenue = 500;
  final Map<String, List<CrowdObservation>> _byVenue = {};

  static int levelFromLabel(String busyness) => switch (busyness) {
        'busy' => 2,
        'moderate' => 1,
        _ => 0,
      };

  void record(String venueId, String busyness, DateTime timestamp) {
    final list = _byVenue.putIfAbsent(venueId, () => []);
    list.add(CrowdObservation(timestamp, levelFromLabel(busyness)));
    if (list.length > _maxPerVenue) {
      list.removeRange(0, list.length - _maxPerVenue);
    }
  }

  List<CrowdObservation> observationsFor(String venueId) =>
      List.unmodifiable(_byVenue[venueId] ?? const []);
}
