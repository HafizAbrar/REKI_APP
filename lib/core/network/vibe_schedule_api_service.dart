import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

final vibeScheduleApiServiceProvider = Provider<VibeScheduleApiService>((ref) {
  return VibeScheduleApiService(ref.read(apiClientProvider));
});

class VibeScheduleApiService {
  final Dio _dio;

  VibeScheduleApiService(this._dio);

  Future<List<dynamic>> getVibeSchedules(String venueId) async {
    final response = await _dio.get('/venues/$venueId/vibe-schedules');
    return response.data as List;
  }

  Future<Map<String, dynamic>> createVibeSchedule(String venueId, Map<String, dynamic> data) async {
    final response = await _dio.post('/venues/$venueId/vibe-schedules', data: data);
    return response.data;
  }
}
