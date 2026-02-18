import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/automation_status.dart';
import '../../../core/services/automation_repository.dart';

final automationStatusProvider = FutureProvider<AutomationStatus>((ref) async {
  final repository = ref.read(automationRepositoryProvider);
  final result = await repository.getStatus();
  return result.when(
    success: (data) => data,
    failure: (error) => throw Exception(error),
  );
});

final automationActionsProvider = Provider<AutomationActions>((ref) {
  return AutomationActions(ref.read(automationRepositoryProvider));
});

class AutomationActions {
  final AutomationRepository _repository;

  AutomationActions(this._repository);

  Future<String> triggerDemoScenario() async {
    final result = await _repository.triggerDemoScenario();
    return result.when(
      success: (data) => data['message'] ?? 'Demo scenario triggered',
      failure: (error) => throw Exception(error),
    );
  }

  Future<String> updateVibes() async {
    final result = await _repository.updateVibes();
    return result.when(
      success: (data) => data['message'] ?? 'Vibes updated',
      failure: (error) => throw Exception(error),
    );
  }

  Future<String> updateBusyness() async {
    final result = await _repository.updateBusyness();
    return result.when(
      success: (data) => data['message'] ?? 'Busyness updated',
      failure: (error) => throw Exception(error),
    );
  }
}
