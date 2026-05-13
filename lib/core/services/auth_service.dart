import '../models/user.dart';
import '../network/auth_api_service.dart';
import 'mock_data_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_logger.dart';

class AuthService {
  AuthApiService? _apiService;
  bool useMockData;
  final _storage = const FlutterSecureStorage();

  static final AuthService _instance = AuthService._internal();
  factory AuthService({AuthApiService? apiService, bool useMockData = false}) {
    if (apiService != null) _instance._apiService = apiService;
    _instance.useMockData = useMockData;
    return _instance;
  }
  AuthService._internal() : useMockData = false, _apiService = null;

  User? _currentUser;
  String? _accessToken;
  String? _refreshToken;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isBusinessUser => _currentUser?.type == UserType.business;
  String? get accessToken => _accessToken;

  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    await _storage.write(key: 'access_token', value: token);
  }

  void setCurrentUserFromJson(Map<String, dynamic> json) {
    _currentUser = User.fromJson(json);
  }

  void setProfilePicture(String url) {
    if (_currentUser == null) return;
    _currentUser = User(
      id: _currentUser!.id,
      email: _currentUser!.email,
      name: _currentUser!.name,
      type: _currentUser!.type,
      role: _currentUser!.role,
      preferences: _currentUser!.preferences,
      isActive: _currentUser!.isActive,
      venueId: _currentUser!.venueId,
      venueName: _currentUser!.venueName,
      profilePicture: url,
    );
  }

  Future<bool> login(String email, String password) async {
    appLogger.d('AuthService.login called, useMockData: $useMockData, apiService: $_apiService');
    if (useMockData || _apiService == null) {
      await Future.delayed(const Duration(seconds: 1));
      if (email.contains('business')) {
        _currentUser = MockDataService.getDemoBusinessUser();
      } else {
        _currentUser = MockDataService.getDemoUser();
      }
      return true;
    }

    try {
      final response = await _apiService!.login(email: email, password: password);
      final tokens = response['tokens'] as Map<String, dynamic>;
      _accessToken = tokens['accessToken'];
      _refreshToken = tokens['refreshToken'];
      await _storage.write(key: 'access_token', value: _accessToken);
      await _storage.write(key: 'refresh_token', value: _refreshToken);
      if (response['user'] != null) {
        _currentUser = User.fromJson(response['user'] as Map<String, dynamic>);
      } else {
        await fetchCurrentUser();
      }
      return true;
    } catch (e) {
      appLogger.e('Login error', error: e);
      return false;
    }
  }

  Future<User?> fetchCurrentUser() async {
    if (useMockData || _apiService == null) {
      return _currentUser;
    }

    try {
      _accessToken ??= await _storage.read(key: 'access_token');
      if (_accessToken == null) return null;
      
      appLogger.d('Fetching current user from API');
      final response = await _apiService!.getCurrentUser();
      appLogger.d('API response: $response');
      _currentUser = User.fromJson(response);
      appLogger.d('User set: ${_currentUser?.email}, Role: ${_currentUser?.role}');
      return _currentUser;
    } catch (e) {
      appLogger.e('Error fetching user', error: e);
      return null;
    }
  }

  Future<void> logout() async {
    if (!useMockData && _apiService != null) {
      try {
        await _apiService!.logout();
      } catch (e) {}
    }
    _currentUser = null;
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<bool> register(String email, String password, String name, UserType type) async {
    if (useMockData || _apiService == null) {
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        type: type,
        role: type == UserType.business ? UserRole.BUSINESS : UserRole.USER,
        preferences: [],
      );
      return true;
    }

    try {
      final response = await _apiService!.register(
        email: email,
        password: password,
        name: name,
      );
      final tokens = response['tokens'] as Map<String, dynamic>;
      _accessToken = tokens['accessToken'];
      _refreshToken = tokens['refreshToken'];
      await _storage.write(key: 'access_token', value: _accessToken);
      await _storage.write(key: 'refresh_token', value: _refreshToken);
      if (response['user'] != null) {
        _currentUser = User.fromJson(response['user'] as Map<String, dynamic>);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    if (useMockData || _apiService == null) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    try {
      await _apiService!.forgotPassword(email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    if (useMockData || _apiService == null) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    try {
      await _apiService!.resetPassword(token: token, newPassword: newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (useMockData || _apiService == null) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    try {
      await _apiService!.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  Future<bool> loginWithGoogle(String idToken) async {
    if (useMockData || _apiService == null) {
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = MockDataService.getDemoUser();
      return true;
    }
    try {
      final response = await _apiService!.loginWithGoogle(idToken);
      final tokens = response['tokens'] as Map<String, dynamic>;
      _accessToken = tokens['accessToken'];
      _refreshToken = tokens['refreshToken'];
      await _storage.write(key: 'access_token', value: _accessToken);
      await _storage.write(key: 'refresh_token', value: _refreshToken);
      if (response['user'] != null) {
        _currentUser = User.fromJson(response['user'] as Map<String, dynamic>);
      } else {
        await fetchCurrentUser();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginWithApple({required String identityToken, String? fullName}) async {
    if (useMockData || _apiService == null) {
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = MockDataService.getDemoUser();
      return true;
    }
    try {
      final response = await _apiService!.loginWithApple(
        identityToken: identityToken,
        fullName: fullName,
      );
      final tokens = response['tokens'] as Map<String, dynamic>;
      _accessToken = tokens['accessToken'];
      _refreshToken = tokens['refreshToken'];
      await _storage.write(key: 'access_token', value: _accessToken);
      await _storage.write(key: 'refresh_token', value: _refreshToken);
      if (response['user'] != null) {
        _currentUser = User.fromJson(response['user'] as Map<String, dynamic>);
      } else {
        await fetchCurrentUser();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginAsGuest() async {
    if (useMockData || _apiService == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = User(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        email: 'guest@reki.app',
        name: 'Guest',
        type: UserType.customer,
        role: UserRole.USER,
        preferences: [],
      );
      return true;
    }
    try {
      final response = await _apiService!.loginAsGuest();
      if (response['access_token'] != null) {
        _accessToken = response['access_token'];
        await _storage.write(key: 'access_token', value: _accessToken);
      }
      if (response['user'] != null) {
        _currentUser = User.fromJson(response['user'] as Map<String, dynamic>);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> refreshAccessToken() async {
    if (useMockData || _apiService == null || _refreshToken == null) {
      return false;
    }

    try {
      final response = await _apiService!.refreshToken(_refreshToken!);
      _accessToken = response['access_token'];
      return true;
    } catch (e) {
      return false;
    }
  }
}