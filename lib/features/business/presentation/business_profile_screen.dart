import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/app_cached_image.dart';
import 'business_provider.dart';

class BusinessProfileScreen extends ConsumerWidget {
  const BusinessProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(businessProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
        title: const Text('Business Profile',
            style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF14B8A6)),
            tooltip: 'Edit Profile',
            onPressed: () => context.push('/edit-business-profile'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF14B8A6)),
            onPressed: () =>
                ref.read(businessProfileProvider.notifier).load(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF14B8A6))),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(e.toString(),
                  style: const TextStyle(color: Color(0xFF64748B)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6)),
                onPressed: () =>
                    ref.read(businessProfileProvider.notifier).load(),
                child: const Text('Retry',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        data: (profile) => _buildContent(context, ref, profile),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, Map<String, dynamic> profile) {
    final name = profile['name']?.toString() ?? 'Business';
    final email = profile['email']?.toString() ?? '';
    final phone = profile['phone']?.toString();
    final role = profile['role']?.toString() ?? 'owner';
    final isApproved = profile['isApproved'] == true;
    final avatarUrl = profile['avatar']?.toString();
    final venues =
        (profile['venues'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final createdAt = profile['createdAt'] != null
        ? DateTime.tryParse(profile['createdAt'] as String)
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04), blurRadius: 12)
              ],
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF14B8A6), width: 3),
                  ),
                  child: ClipOval(
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? AppCachedImage(
                            url: avatarUrl,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                            placeholder: _avatarFallback(name),
                          )
                        : _avatarFallback(name),
                  ),
                ),
                const SizedBox(height: 14),
                Text(name,
                    style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(email,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 14)),
                if (phone != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone_outlined,
                          color: Color(0xFF94A3B8), size: 14),
                      const SizedBox(width: 4),
                      Text(phone,
                          style: const TextStyle(
                              color: Color(0xFF94A3B8), fontSize: 13)),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _badge(
                      label: role.toUpperCase(),
                      icon: Icons.business_center_outlined,
                      color: const Color(0xFF14B8A6),
                    ),
                    const SizedBox(width: 8),
                    _badge(
                      label: isApproved ? 'APPROVED' : 'PENDING',
                      icon: isApproved
                          ? Icons.verified_outlined
                          : Icons.hourglass_empty,
                      color: isApproved
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                    ),
                  ],
                ),
                if (createdAt != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Member since ${_formatDate(createdAt)}',
                    style: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats row
          Row(
            children: [
              Expanded(
                  child: _statCard(
                      icon: Icons.store_outlined,
                      value: venues.length.toString(),
                      label: 'VENUES',
                      color: const Color(0xFF14B8A6))),
              const SizedBox(width: 12),
              Expanded(
                  child: _statCard(
                      icon: Icons.check_circle_outline,
                      value: isApproved ? 'Active' : 'Pending',
                      label: 'STATUS',
                      color: isApproved
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B))),
            ],
          ),

          const SizedBox(height: 24),

          // Venues section
          _sectionLabel('My Venues (${venues.length})'),
          const SizedBox(height: 12),
          if (venues.isEmpty)
            _emptyVenues(context)
          else
            ...venues.map((v) => _venueCard(context, v)),

          const SizedBox(height: 24),

          // Actions
          _sectionLabel('Account'),
          const SizedBox(height: 12),
          _actionTile(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            color: const Color(0xFF14B8A6),
            onTap: () => context.push('/edit-business-profile'),
          ),
          _actionTile(
            icon: Icons.add_business_outlined,
            label: 'Create New Venue',
            color: const Color(0xFF14B8A6),
            onTap: () => context.push('/admin/create-venue'),
          ),
          _actionTile(
            icon: Icons.store_outlined,
            label: 'Manage Venues',
            color: const Color(0xFF3B82F6),
            onTap: () => context.push('/my-venues'),
          ),
          _actionTile(
            icon: Icons.local_offer_outlined,
            label: 'Manage Offers',
            color: const Color(0xFF8B5CF6),
            onTap: () => context.push('/manage-offers'),
          ),
          _actionTile(
            icon: Icons.logout,
            label: 'Logout',
            color: Colors.red,
            onTap: () async {
              await AuthService().logout();
              if (context.mounted) context.go('/login');
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(String name) => Container(
        color: const Color(0xFF14B8A6),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'B',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800),
          ),
        ),
      );

  Widget _badge(
      {required String label,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _statCard(
      {required IconData icon,
      required String value,
      required String label,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(label,
      style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8));

  Widget _venueCard(BuildContext context, Map<String, dynamic> venue) {
    final name = venue['name']?.toString() ?? 'Venue';
    final address = venue['address']?.toString() ?? '';
    final id = venue['id']?.toString() ?? '';

    return GestureDetector(
      onTap: () => context.push(
        '/business-venue/$id?name=${Uri.encodeComponent(name)}&address=${Uri.encodeComponent(address)}',
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03), blurRadius: 8)
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.store_outlined,
                  color: Color(0xFF14B8A6), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(address,
                      style: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Color(0xFF94A3B8), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _emptyVenues(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Icon(Icons.store_outlined,
                color: Color(0xFFCBD5E1), size: 48),
            const SizedBox(height: 12),
            const Text('No venues yet',
                style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text('Create Venue',
                  style: TextStyle(color: Colors.white)),
              onPressed: () => context.push('/admin/create-venue'),
            ),
          ],
        ),
      );

  Widget _actionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDestructive
                ? Colors.red.withOpacity(0.2)
                : const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(label,
            style: TextStyle(
                color: isDestructive ? Colors.red : const Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.chevron_right,
            color: isDestructive ? Colors.red : const Color(0xFF94A3B8),
            size: 20),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}
