import '../models/user.dart';
import '../network/auth_api_service.dart';
import 'mock_data_service.dart';

class AuthService {
  AuthApiService? _apiService;
  final bool useMockData;

  static final AuthService _instance = AuthService._internal();
  factory AuthService({AuthApiService? apiService, bool useMockData = true}) {
    if (apiService != null) _instance._apiService = apiService;
    return _instance;
  }
  AuthService._internal() : useMockData = true, _apiService = null;

  User? _currentUser;
  String? _accessToken;
  String? _refreshToken;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isBusinessUser => _currentUser?.type == UserType.business;

  Future<bool> login(String email, String password) async {
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
      _currentUser = User.fromJson(response['user']);
      return true;
    } catch (e) {
      return false;
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
  }

  Future<bool> register(String email, String password, String name, UserType type) async {
    if (useMockData || _apiService == null) {
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        type: type,
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
      _currentUser = User.fromJson(response['user']);
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
    if (useMockData || _apiService == null) {
      return _currentUser;
    }

    try {
      final response = await _apiService!.getCurrentUser();
      _currentUser = User.fromJson(response['user']);
      return _currentUser;
    } catch (e) {
      return null;
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

  String? get accessToken => _accessToken;
}