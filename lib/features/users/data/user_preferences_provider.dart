import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/network/user_api_service.dart';

final currentUserPreferencesProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authService = AuthService();
  final currentUser = authService.currentUser;
  
  if (currentUser == null) return null;
  
  try {
    final apiService = ref.read(userApiServiceProvider);
    final user = await apiService.getUserById('me');
    return user.toJson()['preferences'];
  } catch (e) {
    return null;
  }
});
