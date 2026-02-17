import '../../../../core/utils/result.dart';

abstract class AuthRepository {
  Future<Result<void>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  });
  
  Future<Result<Map<String, dynamic>>> login(String email, String password);
}
