import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/automation_status.dart';
import 'api_client.dart';

final automationApiServiceProvider = Provider<AutomationApiService>((ref) {
  return AutomationApiService(ref.read(apiClientProvider));
});

class AutomationApiService {
  final Dio _dio;

  AutomationApiService(this._dio);

  Future<AutomationStatus> getStatus() async {
    final response = await _dio.get('/automation/status');
    return AutomationStatus.fromJson(response.data);
  }

  Future<Map<String, dynamic>> triggerDemoScenario() async {
    final response = await _dio.post('/automation/demo/scenario');
    return response.data;
  }

  Future<Map<String, dynamic>> updateVibes() async {
    final response = await _dio.post('/automation/update-vibes');
    return response.data;
  }

  Future<Map<String, dynamic>> updateBusyness() async {
    final response = await _dio.post('/automation/update-busyness');
    return response.data;
  }
}
