import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/analytics_provider.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(ownerDashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Owner Dashboard')),
      body: dashboardAsync.when(
        data: (dashboard) => RefreshIndicator(
          onRefresh: () async => ref.refresh(ownerDashboardProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildMetricCard('Total Revenue', '\$${dashboard.totalRevenue}', Icons.attach_money),
              _buildMetricCard('Total Offers', '${dashboard.totalOffers}', Icons.local_offer),
              _buildMetricCard('Active Offers', '${dashboard.activeOffers}', Icons.check_circle),
              _buildMetricCard('Total Redemptions', '${dashboard.totalRedemptions}', Icons.redeem),
              _buildMetricCard('Total Views', '${dashboard.totalViews}', Icons.visibility),
              _buildMetricCard('Total Clicks', '${dashboard.totalClicks}', Icons.touch_app),
              _buildMetricCard('Conversion Rate', '${(dashboard.conversionRate * 100).toStringAsFixed(1)}%', Icons.trending_up),
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
