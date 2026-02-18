import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user.dart';
import '../../../core/services/user_repository.dart';

final userListProvider = StateNotifierProvider<UserListNotifier, AsyncValue<List<User>>>((ref) {
  return UserListNotifier(ref.read(userRepositoryProvider));
});

class UserListNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final UserRepository _repository;

  UserListNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadUsers() async {
    state = const AsyncValue.loading();
    final result = await _repository.getAllUsers();
    state = result.when(
      success: (users) => AsyncValue.data(users),
      failure: (error) => AsyncValue.error(error, StackTrace.current),
    );
  }

  Future<bool> deleteUser(String id) async {
    final result = await _repository.deleteUser(id);
    return result.when(
      success: (_) {
        loadUsers();
        return true;
      },
      failure: (_) => false,
    );
  }
}

final userDetailProvider = FutureProvider.family<User, String>((ref, id) async {
  final repository = ref.read(userRepositoryProvider);
  final result = await repository.getUserById(id);
  return result.when(
    success: (user) => user,
    failure: (error) => throw Exception(error),
  );
});
