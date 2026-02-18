import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/analytics_provider.dart';

class OfferAnalyticsScreen extends ConsumerWidget {
  final String offerId;

  const OfferAnalyticsScreen({super.key, required this.offerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(offerAnalyticsProvider(offerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Offer Analytics')),
      body: analyticsAsync.when(
        data: (analytics) => RefreshIndicator(
          onRefresh: () async => ref.refresh(offerAnalyticsProvider(offerId)),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(analytics.offerTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildMetricCard('Views', '${analytics.views}', Icons.visibility),
              _buildMetricCard('Clicks', '${analytics.clicks}', Icons.touch_app),
              _buildMetricCard('Redemptions', '${analytics.redemptions}', Icons.redeem),
              _buildMetricCard('Click-Through Rate', '${(analytics.clickThroughRate * 100).toStringAsFixed(1)}%', Icons.trending_up),
              _buildMetricCard('Conversion Rate', '${(analytics.conversionRate * 100).toStringAsFixed(1)}%', Icons.show_chart),
              _buildMetricCard('Revenue', '\$${analytics.revenue}', Icons.attach_money),
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
