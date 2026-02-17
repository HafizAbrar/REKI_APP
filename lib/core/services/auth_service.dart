import '../models/user.dart';
import 'mock_data_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;
  bool get isBusinessUser => _currentUser?.type == UserType.business;

  Future<bool> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1)); // Simulate API call
    
    if (email.contains('business')) {
      _currentUser = MockDataService.getDemoBusinessUser();
    } else {
      _currentUser = MockDataService.getDemoUser();
    }
    
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  Future<bool> register(String email, String password, String name, UserType type) async {
    await Future.delayed(Duration(seconds: 1)); // Simulate API call
    
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      type: type,
      preferences: [],
    );
    
    return true;
  }
}