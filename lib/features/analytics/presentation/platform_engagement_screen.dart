import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/analytics_provider.dart';

class PlatformEngagementScreen extends ConsumerWidget {
  const PlatformEngagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engagementAsync = ref.watch(platformEngagementProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Platform Engagement')),
      body: engagementAsync.when(
        data: (engagement) => RefreshIndicator(
          onRefresh: () async => ref.refresh(platformEngagementProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildMetricCard('Total Users', '${engagement.totalUsers}', Icons.people),
              _buildMetricCard('Active Users', '${engagement.activeUsers}', Icons.person),
              _buildMetricCard('Total Venues', '${engagement.totalVenues}', Icons.location_on),
              _buildMetricCard('Total Offers', '${engagement.totalOffers}', Icons.local_offer),
              _buildMetricCard('Total Redemptions', '${engagement.totalRedemptions}', Icons.redeem),
              const SizedBox(height: 16),
              const Text('Users by City', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...engagement.usersByCity.entries.map((e) => ListTile(title: Text(e.key), trailing: Text('${e.value}'))),
              const SizedBox(height: 16),
              const Text('Venues by Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...engagement.venuesByType.entries.map((e) => ListTile(title: Text(e.key), trailing: Text('${e.value}'))),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
