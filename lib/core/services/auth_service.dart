import '../models/user.dart';
import '../network/auth_api_service.dart';
import 'mock_data_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  Future<bool> login(String email, String password) async {
    print('DEBUG: AuthService.login called, useMockData: $useMockData, apiService: $_apiService');
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
      _accessToken = response['access_token'];
      _refreshToken = response['refresh_token'];
      await _storage.write(key: 'access_token', value: _accessToken);
      await _storage.write(key: 'refresh_token', value: _refreshToken);
      print('DEBUG: Tokens stored, calling fetchCurrentUser');
      await fetchCurrentUser();
      return true;
    } catch (e) {
      print('DEBUG: Login error: $e');
      return false;
    }
  }

  Future<User?> fetchCurrentUser() async {
    if (useMockData || _apiService == null) {
      return _currentUser;
    }

    try {
      if (_accessToken == null) {
        _accessToken = await _storage.read(key: 'access_token');
      }
      if (_accessToken == null) return null;
      
      print('DEBUG: Fetching current user from API');
      final response = await _apiService!.getCurrentUser();
      print('DEBUG: API response: $response');
      _currentUser = User.fromJson(response);
      print('DEBUG: User set: ${_currentUser?.email}, Role: ${_currentUser?.role}');
      return _currentUser;
    } catch (e) {
      print('DEBUG: Error fetching user: $e');
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
      _accessToken = response['access_token'];
      _refreshToken = response['refresh_token'];
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