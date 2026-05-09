import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/admin_api_service.dart';
import '../utils/error_handler.dart';
import '../utils/result.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.read(adminApiServiceProvider));
});

class AdminRepository {
  final AdminApiService _api;
  AdminRepository(this._api);

  Future<Result<Map<String, dynamic>>> getStats() async {
    try { return Result.success(await _api.getStats()); }
    catch (e) { return Result.failure(ErrorHandler.getErrorMessage(e)); }
  }

  Future<Result<Map<String, dynamic>>> getLocationStats() async {
    try { return Result.success(await _api.getLocationStats()); }
    catch (e) { return Result.failure(ErrorHandler.getErrorMessage(e)); }
  }

  Future<Result<List<Map<String, dynamic>>>> getUsers({int page = 1, int limit = 20}) async {
    try { return Result.success(await _api.getUsers(page: page, limit: limit)); }
    catch (e) { return Result.failure(ErrorHandler.getErrorMessage(e)); }
  }

  Future<Result<Map<String, dynamic>>> getUserActivity(String userId) async {
    try { return Result.success(await _api.getUserActivity(userId)); }
    catch (e) { return Result.failure(ErrorHandler.getErrorMessage(e)); }
  }

  Future<Result<List<Map<String, dynamic>>>> getVenues() async {
    try { return Result.success(await _api.getVenues()); }
    catch (e) { return Result.failure(ErrorHandler.getErrorMessage(e)); }
  }

  Future<Result<List<Map<String, dynamic>>>> getVenueLogs(String venueId) async {
    try { return Result.success(await _api.getVenueLogs(venueId)); }
    catch (e) { return Result.failure(ErrorHandler.getErrorMessage(e)); }
  }

  Future<Result<List<Map<String, dynamic>>>> getOffers() async {
    try { return Result.success(await _api.getOffers()); }
    catch (e) { return Result.failure(ErrorHandler.getErrorMessage(e)); }
  }

  Future<Result<List<Map<String, dynamic>>>> getRedemptions() async {
    try { return Result.success(await _api.getRedemptions()); }
    catch (e) { return Result.failure(ErrorHandler.getErrorMessage(e)); }
  }

  Future<Result<List<Map<String, dynamic>>>> getActivityLogs() async {
    try { return Result.success(await _api.getActivityLogs()); }
    catch (e) { return Result.failure(ErrorHandler.getErrorMessage(e)); }
  }

  Future<Result<List<Map<String, dynamic>>>> getNotifications() async {
    try { return Result.success(await _api.getNotifications()); }
    catch (e) { return Result.failure(ErrorHandler.getErrorMessage(e)); }
  }

  Future<Result<Map<String, dynamic>>> getRealtimeStats() async {
    try { return Result.success(await _api.getRealtimeStats()); }
    catch (e) { return Result.failure(ErrorHandler.getErrorMessage(e)); }
  }

  Future<Result<Map<String, dynamic>>> getOfflineStats() async {
    try { return Result.success(await _api.getOfflineStats()); }
    catch (e) { return Result.failure(ErrorHandler.getErrorMessage(e)); }
  }

  Future<Result<Map<String, dynamic>>> sendTestPush({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      return Result.success(await _api.sendTestPush(userId: userId, title: title, body: body));
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }
}
