import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user.dart';
import '../data/user_preferences_provider.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = AuthService().currentUser;

    if (currentUser == null || currentUser.isGuest) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Profile'),
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_outline, color: Color(0xFF2DD4BF), size: 64),
                const SizedBox(height: 24),
                const Text(
                  'Sign in to view your profile',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Create an account to save venues, track offers, and manage your preferences.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2DD4BF),
                      foregroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      elevation: 0,
                    ),
                    onPressed: () => context.go('/signup'),
                    child: const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF334155)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    ),
                    onPressed: () => context.go('/login'),
                    child: const Text('Log In', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              currentUser.email,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
            ),
            const SizedBox(height: 32),
            _buildMenuItem(context, icon: Icons.bookmark, title: 'Saved Venues',
                onTap: () => _showSavedVenues(context, ref)),
            _buildMenuItem(context, icon: Icons.receipt_long, title: 'Redemption History',
                onTap: () => _showRedemptions(context, ref)),
            _buildMenuItem(context, icon: Icons.person, title: 'Edit Profile',
                onTap: () => context.push('/user-detail?id=${currentUser.id}')),
            _buildMenuItem(context, icon: Icons.notifications, title: 'Notifications',
                onTap: () => context.push('/notifications')),
            const SizedBox(height: 16),
            _buildMenuItem(context, icon: Icons.logout, title: 'Logout', isDestructive: true,
                onTap: () { AuthService().logout(); context.go('/login'); }),
          ],
        ),
      ),
    );
  }

  void _showSavedVenues(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      builder: (_) => Consumer(builder: (context, ref, _) {
        final state = ref.watch(savedVenuesProvider);
        return state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
          data: (venues) => venues.isEmpty
              ? const Center(child: Text('No saved venues', style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  itemCount: venues.length,
                  itemBuilder: (_, i) => ListTile(
                    title: Text(venues[i]['name']?.toString() ?? '', style: const TextStyle(color: Colors.white)),
                    trailing: IconButton(
                      icon: const Icon(Icons.bookmark_remove, color: Color(0xFF2DD4BF)),
                      onPressed: () => ref.read(savedVenuesProvider.notifier).unsaveVenue(venues[i]['id'].toString()),
                    ),
                  ),
                ),
        );
      }),
    );
  }

  void _showRedemptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      builder: (_) => Consumer(builder: (context, ref, _) {
        final state = ref.watch(redemptionsProvider);
        return state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
          data: (redemptions) => redemptions.isEmpty
              ? const Center(child: Text('No redemptions yet', style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  itemCount: redemptions.length,
                  itemBuilder: (_, i) => ListTile(
                    title: Text(redemptions[i]['offer']?['title']?.toString() ?? 'Offer',
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(redemptions[i]['redeemedAt']?.toString() ?? '',
                        style: const TextStyle(color: Color(0xFF94A3B8))),
                  ),
                ),
        );
      }),
    );
  }

  Widget _buildMenuItem(BuildContext context, {
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
        leading: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF2DD4BF)),
        title: Text(title, style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontWeight: FontWeight.w600,
        )),
        trailing: Icon(Icons.chevron_right,
            color: isDestructive ? Colors.red : const Color(0xFF94A3B8)),
        onTap: onTap,
      ),
    );
  }
}
