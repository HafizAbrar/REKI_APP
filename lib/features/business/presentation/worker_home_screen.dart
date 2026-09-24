import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import 'business_provider.dart';

final workerVenuesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final res = await ref.read(apiClientProvider).get('/worker/venues');
  final raw = res.data;
  if (raw is List) return List<Map<String, dynamic>>.from(raw);
  if (raw is Map) {
    final inner = raw['data'] ?? raw['venues'] ?? raw['items'] ?? [];
    if (inner is List) return List<Map<String, dynamic>>.from(inner);
  }
  return [];
});

class WorkerHomeScreen extends ConsumerWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = AuthService().currentUser;
    final name = user?.name ?? 'Staff';
    final venuesAsync = ref.watch(workerVenuesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'S',
              style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15),
            ),
          ),
          const SizedBox(width: 10),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const Text('Staff Portal',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
              ]),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF64748B)),
            tooltip: 'Sign out',
            onPressed: () async {
              await AuthService().logout();
              ref.invalidate(myVenuesProvider);
              ref.invalidate(selectedVenueIdProvider);
              if (context.mounted) context.go('/business-login');
            },
          ),
        ],
      ),
      body: venuesAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (e, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off, color: Color(0xFF334155), size: 48),
            const SizedBox(height: 12),
            const Text('Could not load assigned venues.',
                style: TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.darkBg),
              onPressed: () => ref.invalidate(workerVenuesProvider),
              child: const Text('Retry'),
            ),
          ]),
        ),
        data: (venues) => venues.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            width: 2),
                      ),
                      child: const Icon(Icons.store_outlined,
                          color: AppTheme.primaryColor, size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text('No Venues Assigned',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text(
                      'Ask your venue owner to assign you\nto a venue to get started.',
                      style: TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 14, height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                  ]),
                ),
              )
            : RefreshIndicator(
                color: AppTheme.primaryColor,
                backgroundColor: const Color(0xFF1E293B),
                onRefresh: () async => ref.invalidate(workerVenuesProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: venues.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => _VenueCard(venue: venues[i]),
                ),
              ),
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  final Map<String, dynamic> venue;
  const _VenueCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    final id = venue['id']?.toString() ?? '';
    final name = venue['name']?.toString() ?? 'Venue';
    final address = venue['address']?.toString() ?? '';
    final busyness = venue['busyness']?.toString() ??
        venue['currentBusyness']?.toString() ??
        '';
    final isLive = venue['isLive'] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFF334155).withValues(alpha: 0.6)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppTheme.primaryColor.withValues(alpha: 0.12),
              AppTheme.primaryColor.withValues(alpha: 0.04),
            ]),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isLive
                              ? const Color(0xFF10B981).withValues(alpha: 0.15)
                              : const Color(0xFF475569).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isLive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF475569),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isLive ? 'LIVE' : 'OFFLINE',
                            style: TextStyle(
                                color: isLive
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF64748B),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5),
                          ),
                        ]),
                      ),
                    ]),
                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.location_on_outlined,
                            color: Color(0xFF64748B), size: 13),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(address,
                              style: const TextStyle(
                                  color: Color(0xFF94A3B8), fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    ],
                    if (busyness.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _BusynessChip(level: busyness),
                    ],
                  ]),
            ),
          ]),
        ),

        // Actions
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _ActionButton(
              icon: Icons.qr_code_scanner,
              label: 'Scan Customer Voucher',
              subtitle: 'Redeem offers at the door',
              color: AppTheme.primaryColor,
              onTap: () =>
                  context.push('/qr-scan?venueId=${Uri.encodeComponent(id)}'),
            ),
            const SizedBox(height: 10),
            _ActionButton(
              icon: Icons.bolt,
              label: 'Update Busyness & Vibe',
              subtitle: 'Set current crowd level',
              color: const Color(0xFFF59E0B),
              onTap: () => context
                  .push('/venue-status/$id?name=${Uri.encodeComponent(name)}'),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _BusynessChip extends StatelessWidget {
  final String level;
  const _BusynessChip({required this.level});

  Color get _color {
    switch (level.toLowerCase()) {
      case 'busy':
      case 'packed':
        return const Color(0xFFEF4444);
      case 'moderate':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(level.toUpperCase(),
          style: TextStyle(
              color: _color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            ]),
          ),
          Icon(Icons.chevron_right,
              color: color.withValues(alpha: 0.6), size: 20),
        ]),
      ),
    );
  }
}
