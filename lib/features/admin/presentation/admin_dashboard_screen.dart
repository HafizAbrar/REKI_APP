import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_provider.dart';
import 'admin_venues_screen.dart';
import 'admin_offers_screen.dart';
import 'admin_redemptions_screen.dart';
import 'admin_activity_logs_screen.dart';
import 'admin_notifications_screen.dart';
import 'admin_users_screen.dart';
import 'admin_profile_screen.dart';
import 'test_push_screen.dart';
import '../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/presentation/auth_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final user = AuthService().currentUser;
    final userName = user?.name ?? 'Admin';
    final profilePic = user?.profilePicture;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              backgroundImage: profilePic != null ? NetworkImage(profilePic) : null,
              child: profilePic == null
                  ? Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                      style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
                const Text(
                  'Admin Portal',
                  style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
            onPressed: () => ref.read(adminProvider.notifier).loadAll(),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppTheme.primaryColor),
            tooltip: 'Test Push',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TestPushScreen()),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.surface,
        onRefresh: () async => ref.read(adminProvider.notifier).loadAll(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsSection(adminState),
              const SizedBox(height: 16),
              _buildRealtimeSection(adminState),
              const SizedBox(height: 16),
              _buildOfflineSection(adminState),
              const SizedBox(height: 16),
              _buildLocationSection(adminState),
              const SizedBox(height: 16),
              _buildQuickActions(context),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) => Drawer(
    backgroundColor: AppTheme.backgroundDark,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.white, size: 48),
              SizedBox(height: 8),
              Text('Admin Portal', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              Text('System Management', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dashboard, color: AppTheme.primaryColor),
          title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          leading: const Icon(Icons.people, color: Colors.white),
          title: const Text('Users', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.store, color: Colors.white),
          title: const Text('Venues', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminVenuesScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.local_offer, color: Colors.white),
          title: const Text('Offers', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOffersScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.confirmation_number, color: Colors.white),
          title: const Text('Redemptions', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRedemptionsScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.history, color: Colors.white),
          title: const Text('Activity Logs', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminActivityLogsScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications, color: Colors.white),
          title: const Text('Notifications', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationsScreen()));
          },
        ),
        const Divider(color: Colors.white24),
        ListTile(
          leading: const Icon(Icons.admin_panel_settings, color: Colors.white),
          title: const Text('My Profile', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProfileScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: () async {
            Navigator.pop(context);
            await ref.read(authStateProvider.notifier).logout();
            if (context.mounted) context.go('/login');
          },
        ),
      ],
    ),
  );

  Widget _buildStatsSection(AdminState state) {
    return state.stats.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      error: (err, stack) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 36),
          const SizedBox(height: 8),
          Text('Stats failed: $err',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.read(adminProvider.notifier).loadStats(),
            child: const Text('Retry', style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ]),
      ),
      data: (stats) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OVERVIEW', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _StatCard(icon: Icons.people_outline, label: 'Total Users', value: stats.totalUsers.toString(), color: const Color(0xFF3B82F6))),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(icon: Icons.store_outlined, label: 'Total Venues', value: stats.totalVenues.toString(), color: const Color(0xFF8B5CF6))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _StatCard(icon: Icons.local_offer_outlined, label: 'Active Offers', value: stats.activeOffers.toString(), color: AppTheme.primaryColor)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(icon: Icons.bolt_outlined, label: 'Live Venues', value: stats.liveVenuesNow.toString(), color: const Color(0xFF10B981))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _StatCard(icon: Icons.confirmation_number_outlined, label: 'Redemptions Today', value: stats.redemptionsToday.toString(), color: const Color(0xFFF59E0B))),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(icon: Icons.person_add_outlined, label: 'New Signups', value: stats.newSignupsToday.toString(), color: const Color(0xFFEF4444))),
          ]),
        ],
      ),
    );
  }

  Widget _buildRealtimeSection(AdminState state) {
    return state.realtimeStats.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (rt) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('REALTIME', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: rt.fcmConfigured ? const Color(0xFF10B981).withValues(alpha: 0.15) : const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: rt.fcmConfigured ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                const SizedBox(width: 6),
                Text(rt.fcmConfigured ? 'FCM Active' : 'FCM Inactive', style: TextStyle(color: rt.fcmConfigured ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _StatCard(icon: Icons.wifi, label: 'WS Connections', value: rt.activeWebSocketConnections.toString(), color: const Color(0xFF3B82F6))),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(icon: Icons.people_outline, label: 'Connected Users', value: rt.uniqueConnectedUsers.toString(), color: const Color(0xFF8B5CF6))),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF334155))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('PUSH NOTIFICATIONS', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _PushStat('Delivered', rt.pushDelivered, const Color(0xFF10B981))),
                Container(width: 1, height: 50, color: const Color(0xFF334155)),
                Expanded(child: _PushStat('Failed', rt.pushFailed, const Color(0xFFEF4444))),
                Container(width: 1, height: 50, color: const Color(0xFF334155)),
                Expanded(child: _PushStat('Open Rate', null, const Color(0xFFF59E0B), valueLabel: rt.pushOpenRate)),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineSection(AdminState state) {
    return state.offlineStats.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (off) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OFFLINE SYNC', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _StatCard(icon: Icons.sync, label: 'Total Syncs', value: off.totalSyncActions.toString(), color: const Color(0xFF3B82F6))),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(icon: Icons.check_circle_outline, label: 'Successful', value: off.successfulSyncs.toString(), color: const Color(0xFF10B981))),
          ]),
        ],
      ),
    );
  }

  Widget _buildLocationSection(AdminState state) {
    return state.locationStats.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (loc) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('LOCATION STATS', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _StatCard(icon: Icons.location_on_outlined, label: 'Users With Location', value: loc.usersWithLocation.toString(), color: const Color(0xFF3B82F6))),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(icon: Icons.notifications_outlined, label: 'Geofence Alerts', value: loc.geofenceNotificationsSent.toString(), color: const Color(0xFF8B5CF6))),
          ]),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('QUICK ACTIONS', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _ActionTile(icon: Icons.people, label: 'View Users', color: const Color(0xFF3B82F6), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen()))),
            _ActionTile(icon: Icons.store, label: 'Manage Venues', color: const Color(0xFF8B5CF6), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminVenuesScreen()))),
            _ActionTile(icon: Icons.local_offer, label: 'View Offers', color: AppTheme.primaryColor, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOffersScreen()))),
            _ActionTile(icon: Icons.history, label: 'Activity Logs', color: const Color(0xFFF59E0B), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminActivityLogsScreen()))),
          ],
        ),
      ],
    );
  }

}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
        const SizedBox(height: 12),
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _PushStat extends StatelessWidget {
  final String title;
  final int? value;
  final Color color;
  final String? valueLabel;

  const _PushStat(this.title, this.value, this.color, {this.valueLabel});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(valueLabel ?? value.toString(), style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500)),
    ]);
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
          const SizedBox(height: 10),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
