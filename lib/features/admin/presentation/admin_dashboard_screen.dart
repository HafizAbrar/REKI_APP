import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    Future.microtask(() => ref.read(adminProvider.notifier).loadAll());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Stats'),
            Tab(text: 'Users'),
            Tab(text: 'Venues'),
            Tab(text: 'Offers'),
            Tab(text: 'Redemptions'),
            Tab(text: 'Activity'),
            Tab(text: 'Notifications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(adminState),
          _buildUsersTab(adminState),
          _buildVenuesTab(adminState),
          _buildOffersTab(adminState),
          _buildRedemptionsTab(adminState),
          _buildActivityTab(adminState),
          _buildNotificationsTab(adminState),
        ],
      ),
    );
  }

  Widget _buildStatsTab(AdminState state) {
    return state.stats.when(
      data: (stats) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatCard('Total Users', stats.totalUsers.toString()),
            _buildStatCard('Total Venues', stats.totalVenues.toString()),
            _buildStatCard('Total Offers', stats.totalOffers.toString()),
            _buildStatCard('Total Redemptions', stats.totalRedemptions.toString()),
            _buildStatCard('Active Venues', stats.activeVenues.toString()),
            _buildStatCard('Active Offers', stats.activeOffers.toString()),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildUsersTab(AdminState state) {
    return state.users.when(
      data: (users) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (_, i) {
          final u = users[i];
          return Card(
            color: const Color(0xFF1E293B),
            child: ListTile(
              title: Text(u.name, style: const TextStyle(color: Colors.white)),
              subtitle: Text(u.email, style: const TextStyle(color: Color(0xFF94A3B8))),
              trailing: Chip(
                label: Text(u.role),
                backgroundColor: u.isActive ? Colors.green : Colors.red,
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildVenuesTab(AdminState state) {
    return state.venues.when(
      data: (venues) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: venues.length,
        itemBuilder: (_, i) {
          final v = venues[i];
          return Card(
            color: const Color(0xFF1E293B),
            child: ListTile(
              title: Text(v.name, style: const TextStyle(color: Colors.white)),
              subtitle: Text('${v.category} • ${v.busyness}',
                  style: const TextStyle(color: Color(0xFF94A3B8))),
              trailing: Text('${v.activeOffersCount} offers',
                  style: const TextStyle(color: Color(0xFF2DD4BF))),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildOffersTab(AdminState state) {
    return state.offers.when(
      data: (offers) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: offers.length,
        itemBuilder: (_, i) {
          final o = offers[i];
          return Card(
            color: const Color(0xFF1E293B),
            child: ListTile(
              title: Text(o.title, style: const TextStyle(color: Colors.white)),
              subtitle: Text(o.venueName, style: const TextStyle(color: Color(0xFF94A3B8))),
              trailing: Chip(
                label: Text('${o.redemptionCount} redeemed'),
                backgroundColor: o.isActive ? Colors.green : Colors.grey,
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildRedemptionsTab(AdminState state) {
    return state.redemptions.when(
      data: (redemptions) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: redemptions.length,
        itemBuilder: (_, i) {
          final r = redemptions[i];
          return Card(
            color: const Color(0xFF1E293B),
            child: ListTile(
              title: Text(r.offerTitle, style: const TextStyle(color: Colors.white)),
              subtitle: Text('${r.userName} @ ${r.venueName}',
                  style: const TextStyle(color: Color(0xFF94A3B8))),
              trailing: Text(
                _formatDate(r.redeemedAt),
                style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 12),
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildActivityTab(AdminState state) {
    return state.activityLogs.when(
      data: (logs) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (_, i) {
          final log = logs[i];
          return Card(
            color: const Color(0xFF1E293B),
            child: ListTile(
              title: Text(log.action, style: const TextStyle(color: Colors.white)),
              subtitle: Text(log.details ?? 'No details',
                  style: const TextStyle(color: Color(0xFF94A3B8))),
              trailing: Text(
                _formatDate(log.createdAt),
                style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 12),
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildNotificationsTab(AdminState state) {
    return state.notificationLogs.when(
      data: (logs) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (_, i) {
          final log = logs[i];
          return Card(
            color: const Color(0xFF1E293B),
            child: ListTile(
              title: Text(log['title'] ?? 'Notification',
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(log['message'] ?? '',
                  style: const TextStyle(color: Color(0xFF94A3B8))),
              trailing: Text(
                log['timestamp'] != null
                    ? _formatDate(DateTime.parse(log['timestamp']))
                    : 'N/A',
                style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 12),
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF94A3B8))),
            Text(value,
                style: const TextStyle(
                    color: Color(0xFF2DD4BF),
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
