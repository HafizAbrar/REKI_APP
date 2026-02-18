import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/automation_status.dart';
import '../network/automation_api_service.dart';
import '../utils/result.dart';

final automationRepositoryProvider = Provider<AutomationRepository>((ref) {
  return AutomationRepository(ref.read(automationApiServiceProvider));
});

class AutomationRepository {
  final AutomationApiService _apiService;

  AutomationRepository(this._apiService);

  Future<Result<AutomationStatus>> getStatus() async {
    try {
      final status = await _apiService.getStatus();
      return Result.success(status);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> triggerDemoScenario() async {
    try {
      final result = await _apiService.triggerDemoScenario();
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> updateVibes() async {
    try {
      final result = await _apiService.updateVibes();
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> updateBusyness() async {
    try {
      final result = await _apiService.updateBusyness();
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
