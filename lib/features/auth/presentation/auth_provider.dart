import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/auth_api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/device_registration_service.dart';

// Auth service provider
final authNotifierProvider = Provider<AuthService>((ref) {
  return AuthService(apiService: ref.watch(authApiServiceProvider));
});

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authApiServiceProvider),
    ref.watch(authNotifierProvider),
    ref.read(deviceRegistrationServiceProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApiService _apiService;
  final AuthService _authService;
  final DeviceRegistrationService _deviceReg;

  AuthNotifier(this._apiService, this._authService, this._deviceReg)
      : super(const AuthStateInitial());

  bool get isLoading => state is AuthStateLoading;
  bool get isAuthenticated => state is AuthStateAuthenticated;

  String _parseError(Object e) {
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      final serverMessage = e.response?.data is Map
          ? e.response?.data['message'] as String?
          : null;
      switch (statusCode) {
        case 400:
          return serverMessage ?? 'Invalid request. Please check your details and try again.';
        case 401:
          return 'Incorrect email or password. Please try again.';
        case 404:
          return serverMessage ?? 'Account not found. Please check your email or sign up.';
        case 409:
          return serverMessage ?? 'An account with this email already exists.';
        case 422:
          return serverMessage ?? 'Please fill in all required fields correctly.';
        case 429:
          return 'Too many attempts. Please wait a moment and try again.';
        case 500:
        case 502:
        case 503:
          return 'Something went wrong on our end. Please try again later.';
        default:
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            return 'Connection timed out. Please check your internet and try again.';
          }
          if (e.type == DioExceptionType.connectionError) {
            return 'No internet connection. Please check your network and try again.';
          }
      }
    }
    return 'Something went wrong. Please try again.';
  }

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
      await _handleTokenResponse(response);
      state = const AuthStateRegisterSuccess();
    } catch (e) {
      state = AuthStateError(_parseError(e));
    }
  }

  Future<void> registerBusiness({
    required String email,
    required String password,
    required String name,
    required String venueName,
    required String venueAddress,
    required String venueCategory,
    String? phone,
  }) async {
    state = const AuthStateLoading();
    try {
      // Response: {success, message, status} — no tokens returned
      await _apiService.registerBusiness(
        email: email,
        password: password,
        name: name,
        venueName: venueName,
        venueAddress: venueAddress,
        venueCategory: venueCategory,
        phone: phone,
      );
      state = const AuthStateRegisterSuccess();
    } catch (e) {
      state = AuthStateError(_parseError(e));
    }
  }

  Future<void> businessLogin({
    required String email,
    required String password,
  }) async {
    state = const AuthStateLoading();
    try {
      final response = await _apiService.businessLogin(email: email, password: password);
      // Response: { user: {...}, tokens: { accessToken, refreshToken } }
      final tokens = response['tokens'] as Map<String, dynamic>;
      const storage = FlutterSecureStorage();
      await storage.write(key: 'access_token', value: tokens['accessToken']);
      await storage.write(key: 'refresh_token', value: tokens['refreshToken']);
      await _authService.setAccessToken(tokens['accessToken']);
      if (response['user'] != null) {
        _authService.setCurrentUserFromJson(response['user'] as Map<String, dynamic>);
      }
      // Register device for push notifications
      _deviceReg.register();
      state = const AuthStateLoginSuccess();
    } catch (e) {
      state = AuthStateError(_parseError(e));
    }
  }

  Future<void> login({
    required String email,
    required String password,
    }) async {
    state = const AuthStateLoading();
    try {
      final response = await _apiService.login(email: email, password: password);
      await _handleTokenResponse(response);
      state = const AuthStateLoginSuccess();
    } catch (e) {
      state = AuthStateError(_parseError(e));
    }
  }

  Future<void> loginWithGoogle(String idToken, {String? photoUrl}) async {
    state = const AuthStateLoading();
    try {
      final response = await _apiService.loginWithGoogle(idToken);
      await _handleTokenResponse(response, photoUrl: photoUrl);
      state = const AuthStateLoginSuccess();
    } catch (e) {
      state = AuthStateError(_parseError(e));
    }
  }

  Future<void> loginWithApple({required String identityToken, String? fullName}) async {
    state = const AuthStateLoading();
    try {
      final response = await _apiService.loginWithApple(
        identityToken: identityToken,
        fullName: fullName,
      );
      await _handleTokenResponse(response);
      state = const AuthStateLoginSuccess();
    } catch (e) {
      state = AuthStateError(_parseError(e));
    }
  }

  Future<void> loginAsGuest() async {
    state = const AuthStateLoading();
    try {
      final response = await _apiService.loginAsGuest();
      // Guest response uses same shape as regular login: { tokens: { accessToken, refreshToken }, user: {...} }
      await _handleTokenResponse(response);
      state = const AuthStateGuestSuccess();
    } catch (e) {
      state = AuthStateError(_parseError(e));
    }
  }

  Future<void> forgotPassword(String email) async {
    state = const AuthStateLoading();
    try {
      await _apiService.forgotPassword(email);
      state = const AuthStateForgotPasswordSuccess();
    } catch (e) {
      state = AuthStateError(_parseError(e));
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    state = const AuthStateLoading();
    try {
      await _apiService.resetPassword(token: token, newPassword: newPassword);
      state = const AuthStateResetPasswordSuccess();
    } catch (e) {
      state = AuthStateError(_parseError(e));
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
      state = AuthStateError(_parseError(e));
    }
  }

  Future<void> logout() async {
    await _deviceReg.deactivate();
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

  Future<void> _handleTokenResponse(Map<String, dynamic> response, {String? photoUrl}) async {
    const storage = FlutterSecureStorage();
    final tokens = response['tokens'] as Map<String, dynamic>?;
    final accessToken = tokens?['accessToken'] ?? response['access_token'];
    final refreshToken = tokens?['refreshToken'] ?? response['refresh_token'];
    if (accessToken != null) {
      await storage.write(key: 'access_token', value: accessToken);
      await _authService.setAccessToken(accessToken);
    }
    if (refreshToken != null) {
      await storage.write(key: 'refresh_token', value: refreshToken);
    }
    if (response['user'] != null) {
      _authService.setCurrentUserFromJson(response['user'] as Map<String, dynamic>);
    } else {
      await _authService.fetchCurrentUser();
    }
    if (photoUrl != null) {
      _authService.setProfilePicture(photoUrl);
    }
    // Register device for push notifications after every successful auth
    _deviceReg.register();
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

class AuthStateGuestSuccess extends AuthState {
  const AuthStateGuestSuccess();
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