import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../network/user_api_service.dart';
import '../utils/error_handler.dart';
import '../utils/result.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(userApiServiceProvider));
});

class UserRepository {
  final UserApiService _apiService;

  UserRepository(this._apiService);

  Future<Result<List<User>>> getAllUsers() async {
    try {
      final users = await _apiService.getAllUsers();
      return Result.success(users);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<User>> getUserById(String id) async {
    try {
      final user = await _apiService.getUserById(id);
      return Result.success(user);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<User>> updateUser(String id, Map<String, dynamic> updates) async {
    try {
      final user = await _apiService.updateUser(id, updates);
      return Result.success(user);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<void>> deleteUser(String id) async {
    try {
      await _apiService.deleteUser(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<Map<String, dynamic>>> getPreferences() async {
    try {
      final prefs = await _apiService.getPreferences();
      return Result.success(prefs);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<Map<String, dynamic>>> savePreferences(Map<String, dynamic> preferences) async {
    try {
      final prefs = await _apiService.savePreferences(preferences);
      return Result.success(prefs);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<Map<String, dynamic>>> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      final prefs = await _apiService.updatePreferences(preferences);
      return Result.success(prefs);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<List<Map<String, dynamic>>>> getSavedVenues() async {
    try {
      final venues = await _apiService.getSavedVenues();
      return Result.success(venues);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<Map<String, dynamic>>> saveVenue(String venueId) async {
    try {
      final result = await _apiService.saveVenue(venueId);
      return Result.success(result);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<void>> unsaveVenue(String venueId) async {
    try {
      await _apiService.unsaveVenue(venueId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<Result<List<Map<String, dynamic>>>> getRedemptions() async {
    try {
      final redemptions = await _apiService.getRedemptions();
      return Result.success(redemptions);
    } catch (e) {
      return Result.failure(ErrorHandler.getErrorMessage(e));
    }
  }
}
