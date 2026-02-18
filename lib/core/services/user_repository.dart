import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../network/user_api_service.dart';
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
      return Result.failure(e.toString());
    }
  }

  Future<Result<User>> getUserById(String id) async {
    try {
      final user = await _apiService.getUserById(id);
      return Result.success(user);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<User>> updateUser(String id, Map<String, dynamic> updates) async {
    try {
      final user = await _apiService.updateUser(id, updates);
      return Result.success(user);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<void>> deleteUser(String id) async {
    try {
      await _apiService.deleteUser(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<User>> updatePreferences(List<String> preferences) async {
    try {
      final user = await _apiService.updatePreferences(preferences);
      return Result.success(user);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
