import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user.dart';
import '../../../core/services/user_repository.dart';
import '../../../core/utils/result.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = AuthService();
    final currentUser = authService.currentUser;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: currentUser == null
          ? const Center(child: Text('Not logged in', style: TextStyle(color: Colors.white)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2DD4BF), width: 3),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://i.pravatar.cc/150?img=1',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF2DD4BF),
                          child: const Icon(Icons.person, color: Colors.white, size: 50),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUser.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentUser.email,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildMenuItem(
                    context,
                    icon: Icons.person,
                    title: 'Edit Profile',
                    onTap: () => context.push('/user-detail?id=${currentUser.id}'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.tune,
                    title: 'Preferences',
                    onTap: () => context.push('/user-preferences'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () => context.push('/notifications'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.favorite,
                    title: 'Saved Venues',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.history,
                    title: 'Offer History',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    isDestructive: true,
                    onTap: () {
                      AuthService().logout();
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF2DD4BF),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? Colors.red : const Color(0xFF94A3B8),
        ),
        onTap: onTap,
      ),
    );
  }
}
