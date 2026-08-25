import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user.dart';
import '../../../core/services/user_repository.dart';
import '../../../shared/widgets/app_cached_image.dart';
import '../data/user_preferences_provider.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = AuthService().currentUser;
    final profileState = ref.watch(userProfileProvider);

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
                const Icon(Icons.person_outline,
                    color: Color(0xFF2DD4BF), size: 64),
                const SizedBox(height: 24),
                const Text(
                  'Sign in to view your profile',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Create an account to save venues, track offers, and manage your preferences.',
                  style: TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 14, height: 1.5),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999)),
                      elevation: 0,
                    ),
                    onPressed: () => context.go('/signup'),
                    child: const Text('Create Account',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF334155)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999)),
                    ),
                    onPressed: () => context.go('/login'),
                    child: const Text('Log In',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(userProfileProvider.notifier).load(),
          ),
        ],
      ),
      body: profileState.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF2DD4BF))),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error: $e', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(userProfileProvider.notifier).load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) => _buildProfileContent(context, ref, profile),
      ),
    );
  }

  Widget _buildProfileContent(
      BuildContext context, WidgetRef ref, Map<String, dynamic> profile) {
    final name = profile['name']?.toString() ?? 'User';
    final email = profile['email']?.toString() ?? '';
    final phone = profile['phone']?.toString();
    final authProvider = profile['authProvider']?.toString() ?? 'email';
    final isVerified = profile['isVerified'] == true;
    final savedVenuesCount = profile['savedVenuesCount'] ?? 0;
    final preferences = profile['preferences'] as Map<String, dynamic>? ?? {};
    final vibes = (preferences['vibes'] as List?)?.cast<String>() ?? [];
    final music = (preferences['music'] as List?)?.cast<String>() ?? [];
    final location = profile['location'] as Map<String, dynamic>? ?? {};
    final locationEnabled = location['locationEnabled'] == true;
    final createdAt = profile['createdAt'] != null
        ? DateTime.tryParse(profile['createdAt'] as String)
        : null;

    final avatarUrl = profile['avatar']?.toString() ??
        profile['profilePicture']?.toString() ??
        profile['picture']?.toString();

    return SingleChildScrollView(
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
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? AppCachedImage(
                      url: avatarUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: _avatarFallback(),
                    )
                  : _avatarFallback(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
          ),
          if (phone != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone, color: Color(0xFF64748B), size: 14),
                const SizedBox(width: 4),
                Text(phone,
                    style: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 14)),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge(
                icon: isVerified ? Icons.verified : Icons.warning_amber,
                label: isVerified ? 'Verified' : 'Not Verified',
                color: isVerified
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              _buildBadge(
                icon: _getAuthIcon(authProvider),
                label: authProvider.toUpperCase(),
                color: const Color(0xFF3B82F6),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            title: 'Account Stats',
            children: [
              _buildStatRow(
                  'Saved Venues', savedVenuesCount.toString(), Icons.bookmark),
              const Divider(color: Color(0xFF334155), height: 24),
              _buildStatRow('Location',
                  locationEnabled ? 'Enabled' : 'Disabled', Icons.location_on),
              if (createdAt != null) ...[
                const Divider(color: Color(0xFF334155), height: 24),
                _buildStatRow('Member Since', _formatDateShort(createdAt),
                    Icons.calendar_today),
              ],
            ],
          ),
          if (vibes.isNotEmpty || music.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Preferences',
              children: [
                if (vibes.isNotEmpty) ...[
                  const Text('Vibes',
                      style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: vibes.map((v) => _buildChip(v)).toList(),
                  ),
                ],
                if (vibes.isNotEmpty && music.isNotEmpty)
                  const SizedBox(height: 12),
                if (music.isNotEmpty) ...[
                  const Text('Music',
                      style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: music.map((m) => _buildChip(m)).toList(),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 24),
          _buildMenuItem(context,
              icon: Icons.bookmark,
              title: 'Saved Venues ($savedVenuesCount)',
              onTap: () => _showSavedVenues(context, ref)),
          _buildMenuItem(context,
              icon: Icons.receipt_long,
              title: 'Redemption History',
              onTap: () => _showRedemptions(context, ref)),
          _buildMenuItem(context,
              icon: Icons.emoji_events_outlined,
              title: 'Activity, Badges & Leaderboard',
              onTap: () => context.push('/social')),
          _buildMenuItem(context,
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () => context.push('/edit-profile')),
          _buildMenuItem(context,
              icon: Icons.settings,
              title: 'Preferences',
              onTap: () => context.push('/user-preferences')),
          _buildMenuItem(context,
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () => context.push('/notifications')),
          _buildMenuItem(context,
              icon: Icons.notifications_active_outlined,
              title: 'Notification Preferences',
              onTap: () => context.push('/notification-preferences')),
          const SizedBox(height: 16),
          _buildMenuItem(context,
              icon: Icons.logout,
              title: 'Logout',
              isDestructive: true, onTap: () {
            AuthService().logout();
            context.go('/login');
          }),
          const SizedBox(height: 8),
          _buildMenuItem(context,
              icon: Icons.delete_forever,
              title: 'Delete Account',
              isDestructive: true,
              onTap: () => _showDeleteAccountSheet(context, ref)),
        ],
      ),
    );
  }

  Widget _avatarFallback() => Container(
        color: const Color(0xFF2DD4BF),
        child: const Icon(Icons.person, color: Colors.white, size: 50),
      );

  Widget _buildInfoCard(
      {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2DD4BF), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
        ),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildBadge(
      {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF2DD4BF).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Color(0xFF2DD4BF),
            fontSize: 12,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  IconData _getAuthIcon(String provider) {
    switch (provider.toLowerCase()) {
      case 'google':
        return Icons.g_mobiledata;
      case 'apple':
        return Icons.apple;
      case 'facebook':
        return Icons.facebook;
      default:
        return Icons.email;
    }
  }

  String _formatDateShort(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  void _showSavedVenues(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Consumer(builder: (context, ref, _) {
        final state = ref.watch(savedVenuesProvider);
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) => Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.bookmark, color: Color(0xFF2DD4BF), size: 20),
                    SizedBox(width: 8),
                    Text('Saved Venues',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: state.when(
                  loading: () => const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF2DD4BF))),
                  error: (e, _) => Center(
                      child: Text('Error: $e',
                          style: const TextStyle(color: Colors.white))),
                  data: (venues) => venues.isEmpty
                      ? const Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bookmark_border,
                                color: Color(0xFF334155), size: 48),
                            SizedBox(height: 12),
                            Text('No saved venues yet',
                                style: TextStyle(
                                    color: Color(0xFF94A3B8), fontSize: 16)),
                          ],
                        ))
                      : ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: venues.length,
                          itemBuilder: (_, i) {
                            final v = venues[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.06)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2DD4BF)
                                        .withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.store_outlined,
                                      color: Color(0xFF2DD4BF), size: 20),
                                ),
                                title: Text(v.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text('${v.type} · ${v.address}',
                                    style: const TextStyle(
                                        color: Color(0xFF64748B), fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                trailing: IconButton(
                                  icon: const Icon(Icons.bookmark_remove,
                                      color: Color(0xFF2DD4BF)),
                                  onPressed: () => ref
                                      .read(savedVenuesProvider.notifier)
                                      .unsaveVenue(v.id),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  context.push('/venue-detail?id=${v.id}');
                                },
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showRedemptions(BuildContext context, WidgetRef ref) {
    // Force fresh load every time the sheet opens
    ref.read(redemptionsProvider.notifier).load();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Consumer(builder: (context, ref, _) {
        final state = ref.watch(redemptionsProvider);
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) => Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long,
                        color: Color(0xFF2DD4BF), size: 20),
                    SizedBox(width: 8),
                    Text('Redemption History',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: state.when(
                  loading: () => const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF2DD4BF))),
                  error: (e, _) => Center(
                      child: Text('Error: $e',
                          style: const TextStyle(color: Colors.white))),
                  data: (redemptions) => redemptions.isEmpty
                      ? const Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                color: Color(0xFF334155), size: 48),
                            SizedBox(height: 12),
                            Text('No redemptions yet',
                                style: TextStyle(
                                    color: Color(0xFF94A3B8), fontSize: 16)),
                          ],
                        ))
                      : ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: redemptions.length,
                          itemBuilder: (_, i) =>
                              _RedemptionCard(data: redemptions[i]),
                        ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showDeleteAccountSheet(BuildContext context, WidgetRef ref) {
    final confirmController = TextEditingController();
    bool isDeleting = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 8,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Warning icon
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_forever,
                      color: Colors.red, size: 32),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('Delete Account',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'This is permanent and cannot be undone.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              // What gets deleted
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('The following will be permanently deleted:',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: 10),
                    _BulletItem('Your profile and personal data'),
                    _BulletItem('Saved venues and preferences'),
                    _BulletItem('Offer redemption history'),
                    _BulletItem('All account activity'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Confirmation input
              const Text('Type DELETE to confirm',
                  style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setSheetState(() {}),
                decoration: InputDecoration(
                  hintText: 'DELETE',
                  hintStyle: const TextStyle(color: Color(0xFF475569)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Buttons
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.15)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed:
                        isDeleting ? null : () => Navigator.pop(sheetContext),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      disabledBackgroundColor: Colors.red.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: (confirmController.text == 'DELETE' &&
                            !isDeleting)
                        ? () async {
                            setSheetState(() => isDeleting = true);
                            final result = await ref
                                .read(userRepositoryProvider)
                                .deleteAccount();
                            if (!context.mounted) return;
                            Navigator.pop(sheetContext);
                            result.when(
                              success: (_) async {
                                await AuthService().logout();
                                if (context.mounted) context.go('/login');
                              },
                              failure: (msg) =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(msg),
                                  backgroundColor: Colors.red[700],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            );
                          }
                        : null,
                    child: isDeleting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Delete Account',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ],
          ),
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
        leading: Icon(icon,
            color: isDestructive ? Colors.red : const Color(0xFF2DD4BF)),
        title: Text(title,
            style: TextStyle(
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

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Icon(Icons.circle, color: Colors.red, size: 6),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style:
                      const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
            ),
          ],
        ),
      );
}

class _RedemptionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RedemptionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final offer = data['offer'] as Map<String, dynamic>?;
    final venue = data['venue'] as Map<String, dynamic>?;
    final status = data['status'] as String? ?? '';
    final isRedeemed = status == 'redeemed';
    final transactionId = data['transactionId'] as String? ?? '';
    final voucherCode = data['voucherCode'] as String? ?? '';
    final savingValue =
        double.tryParse(data['savingValue']?.toString() ?? '0') ?? 0;
    final redeemedAt = data['redeemedAt'] != null
        ? DateTime.tryParse(data['redeemedAt'] as String)
        : null;
    final createdAt = data['createdAt'] != null
        ? DateTime.tryParse(data['createdAt'] as String)
        : null;
    final statusColor =
        isRedeemed ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final statusLabel = isRedeemed ? 'Redeemed' : 'Active';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRedeemed
                        ? Icons.check_circle_outline
                        : Icons.confirmation_number_outlined,
                    color: statusColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    offer?['title'] as String? ?? 'Offer',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              color: statusColor, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text(statusLabel,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (venue != null) ...[
                  Row(children: [
                    const Icon(Icons.store_outlined,
                        color: Color(0xFF64748B), size: 13),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '${venue['name']} · ${venue['area'] ?? venue['city'] ?? ''}',
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    Expanded(
                        child:
                            _infoItem('Voucher', voucherCode, monospace: true)),
                    Expanded(child: _infoItem('Transaction', transactionId)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _infoItem(
                        isRedeemed ? 'Redeemed' : 'Claimed',
                        _formatDate(isRedeemed ? redeemedAt : createdAt),
                      ),
                    ),
                    if (savingValue > 0)
                      Expanded(
                        child: _infoItem(
                            'Saved', '£${savingValue.toStringAsFixed(2)}',
                            valueColor: const Color(0xFF10B981)),
                      ),
                  ],
                ),
                if (offer?['type'] != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (offer!['type'] as String)
                          .replaceAll('-', ' ')
                          .toUpperCase(),
                      style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value,
      {bool monospace = false, Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: monospace ? 'monospace' : null,
            letterSpacing: monospace ? 1.5 : 0,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
