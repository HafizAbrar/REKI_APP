import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../data/sources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';

// Dio provider
final dioProvider = Provider<Dio>((ref) {
  return ref.watch(apiClientProvider);
});

// Data source provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
});

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthStateInitial());

  bool get isLoading => state is AuthStateLoading;
  bool get isAuthenticated => state is AuthStateAuthenticated;

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    state = const AuthStateLoading();
    
    // Mock authentication - accept any credentials
    await Future.delayed(const Duration(milliseconds: 500));
    state = const AuthStateRegisterSuccess();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthStateLoading();
    
    // Mock authentication - accept any credentials
    await Future.delayed(const Duration(milliseconds: 500));
    state = const AuthStateLoginSuccess();
  }

  Future<void> logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    state = const AuthStateInitial();
  }

  Future<void> _storeTokens(Map<String, dynamic> tokenData) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'access_token', value: tokenData['accessToken']);
    await storage.write(key: 'refresh_token', value: tokenData['refreshToken']);
  }
}

sealed class AuthState {
  const AuthState();
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  final String token;
  const AuthStateAuthenticated(this.token);
}

class AuthStateRegisterSuccess extends AuthState {
  const AuthStateRegisterSuccess();
}

class AuthStateLoginSuccess extends AuthState {
  const AuthStateLoginSuccess();
}

class AuthStateError extends AuthState {
  final String message;
  const AuthStateError(this.message);
}