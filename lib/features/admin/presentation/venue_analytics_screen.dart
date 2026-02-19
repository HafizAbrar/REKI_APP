import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/admin_api_service.dart';
import '../../../core/utils/error_handler.dart';

final venueAnalyticsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, venueId) async {
  final apiService = ref.watch(adminApiServiceProvider);
  return await apiService.getVenueAnalytics(venueId);
});

class VenueAnalyticsScreen extends ConsumerWidget {
  final String venueId;

  const VenueAnalyticsScreen({super.key, required this.venueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(venueAnalyticsProvider(venueId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/admin-dashboard'),
        ),
        title: const Text('Venue Analytics', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
      ),
      body: analyticsAsync.when(
        data: (data) => _buildAnalytics(context, data),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text('Error Loading Analytics', style: TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 8),
                Text(ErrorHandler.getErrorMessage(error), style: TextStyle(color: Colors.white54, fontSize: 14), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(venueAnalyticsProvider(venueId)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalytics(BuildContext context, Map<String, dynamic> data) {
    final venue = data['venue'] ?? {};
    final offers = data['offers'] ?? {};
    final performance = data['performance'] ?? {};
    final topOffers = data['topOffers'] as List? ?? [];
    final recentRedemptions = data['recentRedemptions'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor.withOpacity(0.2), AppTheme.primaryColor.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venue['name'] ?? 'Venue', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(venue['category'] ?? 'N/A', style: TextStyle(color: AppTheme.primaryColor, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Offers Overview', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total', offers['total']?.toString() ?? '0', Icons.local_offer, const Color(0xFF3B82F6))),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Active', offers['active']?.toString() ?? '0', Icons.check_circle, const Color(0xFF10B981))),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Expired', offers['expired']?.toString() ?? '0', Icons.cancel, const Color(0xFFEF4444))),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Performance Metrics', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Views', performance['totalViews']?.toString() ?? '0', Icons.visibility, const Color(0xFF3B82F6))),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Clicks', performance['totalClicks']?.toString() ?? '0', Icons.touch_app, const Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Redemptions', performance['totalRedemptions']?.toString() ?? '0', Icons.redeem, const Color(0xFFF59E0B))),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Rate', '${((performance['overallConversionRate'] ?? 0) * 100).toStringAsFixed(1)}%', Icons.trending_up, const Color(0xFF8B5CF6))),
            ],
          ),
          if (topOffers.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Performance Trend', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _buildPerformanceChart(performance),
            const SizedBox(height: 24),
            const Text('Top Offers', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...topOffers.map((offer) => _buildOfferCard(offer)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: AppTheme.iceBlue.withOpacity(0.6), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(offer['title'] ?? 'Offer', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${offer['views'] ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    Text('Views', style: TextStyle(color: AppTheme.iceBlue.withOpacity(0.6), fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${offer['clicks'] ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    Text('Clicks', style: TextStyle(color: AppTheme.iceBlue.withOpacity(0.6), fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${offer['redemptions'] ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    Text('Redemptions', style: TextStyle(color: AppTheme.iceBlue.withOpacity(0.6), fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${((offer['conversionRate'] ?? 0) * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    Text('Rate', style: TextStyle(color: AppTheme.iceBlue.withOpacity(0.6), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(Map<String, dynamic> performance) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withOpacity(0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: TextStyle(color: AppTheme.iceBlue.withOpacity(0.6), fontSize: 12),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  if (value.toInt() >= 0 && value.toInt() < labels.length) {
                    return Text(
                      labels[value.toInt()],
                      style: TextStyle(color: AppTheme.iceBlue.withOpacity(0.6), fontSize: 12),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 3),
                const FlSpot(1, 5),
                const FlSpot(2, 4),
                const FlSpot(3, 7),
                const FlSpot(4, 6),
                const FlSpot(5, 8),
                const FlSpot(6, 9),
              ],
              isCurved: true,
              color: const Color(0xFF3B82F6),
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF3B82F6).withOpacity(0.1),
              ),
            ),
            LineChartBarData(
              spots: [
                const FlSpot(0, 2),
                const FlSpot(1, 3),
                const FlSpot(2, 3),
                const FlSpot(3, 5),
                const FlSpot(4, 4),
                const FlSpot(5, 6),
                const FlSpot(6, 7),
              ],
              isCurved: true,
              color: const Color(0xFF10B981),
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF10B981).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
