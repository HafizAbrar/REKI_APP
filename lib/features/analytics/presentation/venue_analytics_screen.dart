import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/analytics_provider.dart';

class VenueAnalyticsScreen extends ConsumerWidget {
  final String venueId;

  const VenueAnalyticsScreen({super.key, required this.venueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(venueAnalyticsProvider(venueId));

    return Scaffold(
      appBar: AppBar(title: const Text('Venue Analytics')),
      body: analyticsAsync.when(
        data: (analytics) => RefreshIndicator(
          onRefresh: () async => ref.refresh(venueAnalyticsProvider(venueId)),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(analytics.venueName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildMetricCard('Total Visits', '${analytics.totalVisits}', Icons.people),
              _buildMetricCard('Unique Visitors', '${analytics.uniqueVisitors}', Icons.person),
              _buildMetricCard('Avg Stay', '${analytics.averageStayMinutes} min', Icons.access_time),
              const SizedBox(height: 16),
              const Text('Peak Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...analytics.peakHours.entries.map((e) => ListTile(title: Text(e.key), trailing: Text('${e.value}'))),
              const SizedBox(height: 16),
              const Text('Vibe Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...analytics.vibeDistribution.entries.map((e) => ListTile(title: Text(e.key), trailing: Text('${e.value}'))),
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
