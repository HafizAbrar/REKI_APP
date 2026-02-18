import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/auth_api_service.dart';
import '../../../core/services/auth_service.dart';

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authApiServiceProvider),
    AuthService(),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApiService _apiService;
  final AuthService _authService;

  AuthNotifier(this._apiService, this._authService) : super(const AuthStateInitial());

  bool get isLoading => state is AuthStateLoading;
  bool get isAuthenticated => state is AuthStateAuthenticated;

  Future<void> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    state = const AuthStateLoading();
    try {
      final response = await _apiService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      await _storeTokens(response);
      state = const AuthStateRegisterSuccess();
    } catch (e) {
      state = AuthStateError(e.toString());
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthStateLoading();
    try {
      final response = await _apiService.login(email: email, password: password);
      await _storeTokens(response);
      state = const AuthStateLoginSuccess();
    } catch (e) {
      state = AuthStateError(e.toString());
    }
  }

  Future<void> forgotPassword(String email) async {
    state = const AuthStateLoading();
    try {
      await _apiService.forgotPassword(email);
      state = const AuthStateForgotPasswordSuccess();
    } catch (e) {
      state = AuthStateError(e.toString());
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    state = const AuthStateLoading();
    try {
      await _apiService.resetPassword(token: token, newPassword: newPassword);
      state = const AuthStateResetPasswordSuccess();
    } catch (e) {
      state = AuthStateError(e.toString());
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    state = const AuthStateLoading();
    try {
      await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = const AuthStateChangePasswordSuccess();
    } catch (e) {
      state = AuthStateError(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {}
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    state = const AuthStateInitial();
  }

  Future<void> getCurrentUser() async {
    try {
      final response = await _apiService.getCurrentUser();
      state = AuthStateAuthenticated(response['user']);
    } catch (e) {
      state = const AuthStateInitial();
    }
  }

  Future<void> _storeTokens(Map<String, dynamic> response) async {
    const storage = FlutterSecureStorage();
    if (response['access_token'] != null) {
      await storage.write(key: 'access_token', value: response['access_token']);
    }
    if (response['refresh_token'] != null) {
      await storage.write(key: 'refresh_token', value: response['refresh_token']);
    }
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
  final Map<String, dynamic> user;
  const AuthStateAuthenticated(this.user);
}

class AuthStateRegisterSuccess extends AuthState {
  const AuthStateRegisterSuccess();
}

class AuthStateLoginSuccess extends AuthState {
  const AuthStateLoginSuccess();
}

class AuthStateForgotPasswordSuccess extends AuthState {
  const AuthStateForgotPasswordSuccess();
}

class AuthStateResetPasswordSuccess extends AuthState {
  const AuthStateResetPasswordSuccess();
}

class AuthStateChangePasswordSuccess extends AuthState {
  const AuthStateChangePasswordSuccess();
}

class AuthStateError extends AuthState {
  final String message;
  const AuthStateError(this.message);
}