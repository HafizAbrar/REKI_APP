import '../../domain/repositories/auth_repository.dart';
import '../sources/auth_remote_data_source.dart';
import '../models/register_request_dto.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/app_exception.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<void>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      final request = RegisterRequestDto(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      await _remoteDataSource.register(request);
      return Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Registration failed');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> login(String email, String password) async {
    try {
      final response = await _remoteDataSource.login(email, password);
      return Result.success(response['data']);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Login failed');
    }
  }
}
