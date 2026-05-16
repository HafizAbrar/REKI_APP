import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'business_provider.dart';

class VenueAnalyticsScreen extends ConsumerStatefulWidget {
  final String venueId;
  final String venueName;

  const VenueAnalyticsScreen({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  ConsumerState<VenueAnalyticsScreen> createState() =>
      _VenueAnalyticsScreenState();
}

class _VenueAnalyticsScreenState extends ConsumerState<VenueAnalyticsScreen> {
  String _period = 'week';

  static const _periods = [
    ('today', 'Today'),
    ('week', 'This Week'),
    ('month', 'This Month'),
  ];

  @override
  Widget build(BuildContext context) {
    final args = (venueId: widget.venueId, period: _period);
    final state = ref.watch(businessAnalyticsProvider(args));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Analytics',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            Text(widget.venueName,
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
            onPressed: () =>
                ref.read(businessAnalyticsProvider(args).notifier).load(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Period selector
          Container(
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: _periods.map((p) {
                final selected = _period == p.$1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _period = p.$1),
                    child: Container(
                      margin: EdgeInsets.only(
                          right: p.$1 != 'month' ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primaryColor
                            : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: selected
                                ? AppTheme.primaryColor
                                : const Color(0xFF334155)),
                      ),
                      child: Text(
                        p.$2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected
                              ? AppTheme.darkBg
                              : const Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Content
          Expanded(
            child: state.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.primaryColor)),
              error: (e, _) => _buildError(e.toString(), args),
              data: (data) => _buildContent(data),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message, ({String venueId, String period}) args) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bar_chart, color: Color(0xFF334155), size: 64),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(color: Color(0xFF64748B)),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.darkBg),
            onPressed: () =>
                ref.read(businessAnalyticsProvider(args).notifier).load(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final views = _metric(data, 'views');
    final saves = _metric(data, 'saves');
    final offerClicks = _metric(data, 'offerClicks');
    final redemptions = _metric(data, 'redemptions');

    // Optional extended fields
    final conversionRate = _doubleVal(data, 'conversionRate');
    final avgSessionTime = data['avgSessionTime']?.toString();
    final topOffers = (data['topOffers'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final peakHours = (data['peakHours'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      backgroundColor: const Color(0xFF1E293B),
      onRefresh: () async {
        final args = (venueId: widget.venueId, period: _period);
        await ref.read(businessAnalyticsProvider(args).notifier).load();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary KPI grid
            _sectionLabel('KEY METRICS'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
              children: [
                _kpiCard(
                  icon: Icons.visibility_outlined,
                  label: 'Views',
                  total: views.$1,
                  change: views.$2,
                  color: const Color(0xFF3B82F6),
                ),
                _kpiCard(
                  icon: Icons.bookmark_outline,
                  label: 'Saves',
                  total: saves.$1,
                  change: saves.$2,
                  color: const Color(0xFF8B5CF6),
                ),
                _kpiCard(
                  icon: Icons.touch_app_outlined,
                  label: 'Offer Clicks',
                  total: offerClicks.$1,
                  change: offerClicks.$2,
                  color: const Color(0xFFF59E0B),
                ),
                _kpiCard(
                  icon: Icons.redeem_outlined,
                  label: 'Redemptions',
                  total: redemptions.$1,
                  change: redemptions.$2,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),

            // Conversion rate + session time
            if (conversionRate != null || avgSessionTime != null) ...[
              const SizedBox(height: 20),
              _sectionLabel('PERFORMANCE'),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (conversionRate != null)
                    Expanded(
                      child: _statCard(
                        icon: Icons.trending_up,
                        label: 'Conversion Rate',
                        value:
                            '${(conversionRate * 100).toStringAsFixed(1)}%',
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  if (conversionRate != null && avgSessionTime != null)
                    const SizedBox(width: 12),
                  if (avgSessionTime != null)
                    Expanded(
                      child: _statCard(
                        icon: Icons.timer_outlined,
                        label: 'Avg Session',
                        value: avgSessionTime,
                        color: const Color(0xFFEC4899),
                      ),
                    ),
                ],
              ),
            ],

            // Top offers
            if (topOffers.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionLabel('TOP OFFERS'),
              const SizedBox(height: 12),
              ...topOffers.map((o) => _offerRow(o)),
            ],

            // Peak hours
            if (peakHours.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionLabel('PEAK HOURS'),
              const SizedBox(height: 12),
              _peakHoursChart(peakHours),
            ],

            // Quick actions
            const SizedBox(height: 24),
            _sectionLabel('ACTIONS'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _actionBtn(
                icon: Icons.local_offer_outlined,
                label: 'Create Offer',
                color: AppTheme.primaryColor,
                onTap: () => context
                    .push('/create-offer?venueId=${widget.venueId}'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Extracts (total, change) from a metric map e.g. { total: 1, change: "+15%" }
  (int, String) _metric(Map<String, dynamic> data, String key) {
    final m = data[key];
    if (m is Map) {
      return (
        (m['total'] as num?)?.toInt() ?? 0,
        m['change']?.toString() ?? '',
      );
    }
    return (0, '');
  }

  double? _doubleVal(Map<String, dynamic> data, String key) {
    final v = data[key];
    if (v == null) return null;
    return double.tryParse(v.toString());
  }

  Widget _sectionLabel(String label) => Text(label,
      style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5));

  Widget _kpiCard({
    required IconData icon,
    required String label,
    required int total,
    required String change,
    required Color color,
  }) {
    final isPositive = change.startsWith('+');
    final isNegative = change.startsWith('-');
    final changeColor = isPositive
        ? const Color(0xFF10B981)
        : isNegative
            ? const Color(0xFFEF4444)
            : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              if (change.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(change,
                      style: TextStyle(
                          color: changeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ),
            ],
          ),
          const Spacer(),
          Text(
            total.toString(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900),
          ),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _offerRow(Map<String, dynamic> offer) {
    final title = offer['title']?.toString() ?? 'Offer';
    final clicks = (offer['clicks'] as num?)?.toInt() ?? 0;
    final redemptions = (offer['redemptions'] as num?)?.toInt() ?? 0;
    final maxVal = clicks > 0 ? clicks : 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer_outlined,
                  color: AppTheme.primaryColor, size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
              Text('$redemptions redeemed',
                  style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: redemptions / maxVal,
              backgroundColor: const Color(0xFF334155),
              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$clicks clicks',
                  style: const TextStyle(
                      color: Color(0xFF64748B), fontSize: 11)),
              Text(
                  clicks > 0
                      ? '${((redemptions / clicks) * 100).toStringAsFixed(0)}% conversion'
                      : '—',
                  style: const TextStyle(
                      color: Color(0xFF64748B), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _peakHoursChart(List<Map<String, dynamic>> hours) {
    final maxCount =
        hours.map((h) => (h['count'] as num?)?.toInt() ?? 0).fold(0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: hours.map((h) {
                final count = (h['count'] as num?)?.toInt() ?? 0;
                final ratio = maxCount > 0 ? count / maxCount : 0.0;
                final isPeak = ratio >= 0.8;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: ratio.clamp(0.05, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isPeak
                                    ? AppTheme.primaryColor
                                    : AppTheme.primaryColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: hours.map((h) {
              final label = h['hour']?.toString() ?? '';
              return Expanded(
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 9,
                        fontWeight: FontWeight.w500)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
