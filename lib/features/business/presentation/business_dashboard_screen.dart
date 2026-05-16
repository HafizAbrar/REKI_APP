import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'business_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';

class BusinessDashboardScreen extends ConsumerStatefulWidget {
  const BusinessDashboardScreen({super.key});
  
  @override
  ConsumerState<BusinessDashboardScreen> createState() => _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends ConsumerState<BusinessDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final venueId = user?.venueId ?? '';

    if (venueId.isEmpty) {
      return _buildNoVenue();
    }

    final dashboardAsync = ref.watch(businessDashboardProvider(venueId));

    return dashboardAsync.when(
      data: (data) => _buildDashboard(context, data, venueId),
      loading: () => const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      ),
      error: (e, _) => _buildError(e.toString()),
    );
  }

  Widget _buildNoVenue() => Scaffold(
    backgroundColor: AppTheme.backgroundDark,
    body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.store_outlined, color: Colors.white.withOpacity(0.3), size: 64),
        const SizedBox(height: 16),
        const Text('No venue found', style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => context.push('/admin/create-venue'),
          child: const Text('Create Venue', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
        ),
      ]),
    ),
  );

  Widget _buildError(String error) => Scaffold(
    backgroundColor: AppTheme.backgroundDark,
    body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 64),
        const SizedBox(height: 16),
        Text(error, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() {}),
          child: const Text('Retry', style: TextStyle(color: AppTheme.primaryColor)),
        ),
      ]),
    ),
  );

  Widget _buildDashboard(BuildContext context, Map<String, dynamic> data, String venueId) {
    final venue = data['venue'] as Map<String, dynamic>? ?? {};
    final stats = data['stats'] as Map<String, dynamic>? ?? {};
    final vibeStatus = data['vibeStatus'] as Map<String, dynamic>? ?? {};
    final engagement = data['engagement'] as Map<String, dynamic>? ?? {};
    final weather = data['weather'] as Map<String, dynamic>? ?? {};

    final venueName = venue['name']?.toString() ?? 'Your Venue';
    final venueAddress = venue['address']?.toString() ?? '';
    final openUntil = venue['openUntil']?.toString() ?? '';
    final isLive = venue['isLive'] ?? false;
    final isVerified = venue['isVerified'] ?? false;

    final busyness = stats['liveBusyness'] as Map<String, dynamic>? ?? {};
    final busynessPercent = busyness['percentage'] ?? 0;
    final busynessLevel = busyness['level']?.toString() ?? 'quiet';
    final busynessChange = busyness['change']?.toString() ?? '→';

    final dwellTime = stats['avgDwellTime'] as Map<String, dynamic>? ?? {};
    final dwellMinutes = dwellTime['minutes'] ?? 0;

    final vibeLabel = vibeStatus['label']?.toString() ?? 'No Vibe Set';
    final vibeTags = (vibeStatus['tags'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final activeUsers = vibeStatus['activeUsers'] ?? 0;

    final vibeChecks = engagement['vibeChecks'] as Map<String, dynamic>? ?? {};
    final vibeScore = vibeChecks['score'] ?? 0;
    final vibeResponses = vibeChecks['responses'] ?? 0;

    final socialShares = engagement['socialShares'] as Map<String, dynamic>? ?? {};
    final sharesCount = socialShares['count'] ?? 0;

    final weatherMsg = weather['message']?.toString() ?? '';
    final weatherIcon = weather['icon']?.toString() ?? 'cloud';
    final temperature = weather['temperature'] ?? 0;
    final condition = weather['condition']?.toString() ?? '';

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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primaryColor, Color(0xFF0F766E)]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('REKI Biz', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
            onPressed: () => ref.refresh(businessDashboardProvider(venueId)),
          ),
        ],
      ),
      drawer: _buildDrawer(context, venueId),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.surface,
        onRefresh: () async => ref.refresh(businessDashboardProvider(venueId)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Venue Header Card
              _VenueHeaderCard(
                name: venueName,
                address: venueAddress,
                openUntil: openUntil,
                isLive: isLive,
                isVerified: isVerified,
                onTap: () => context.push('/venue-status/$venueId?name=${Uri.encodeComponent(venueName)}'),
              ),
              const SizedBox(height: 16),

              // Live Busyness Card
              _BusynessCard(
                percentage: busynessPercent,
                level: busynessLevel,
                change: busynessChange,
                dwellMinutes: dwellMinutes,
              ),
              const SizedBox(height: 16),

              // Vibe Status Card
              _VibeStatusCard(
                label: vibeLabel,
                tags: vibeTags,
                activeUsers: activeUsers,
                onEdit: () => context.push('/venue-status/$venueId?name=${Uri.encodeComponent(venueName)}'),
              ),
              const SizedBox(height: 16),

              // Engagement Row
              Row(children: [
                Expanded(
                  child: _EngagementCard(
                    icon: Icons.star_outline,
                    title: 'Vibe Checks',
                    value: vibeScore.toStringAsFixed(1),
                    subtitle: '$vibeResponses responses',
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _EngagementCard(
                    icon: Icons.share_outlined,
                    title: 'Social Shares',
                    value: sharesCount.toString(),
                    subtitle: 'Instagram & Feed',
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // Weather Insight Card
              if (weatherMsg.isNotEmpty)
                _WeatherCard(
                  message: weatherMsg,
                  icon: weatherIcon,
                  temperature: temperature,
                  condition: condition,
                ),
              if (weatherMsg.isNotEmpty) const SizedBox(height: 16),

              // Quick Actions
              _QuickActionsGrid(venueId: venueId, venueName: venueName),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-offer?venueId=$venueId'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.backgroundDark,
        icon: const Icon(Icons.add),
        label: const Text('New Offer', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, String venueId) => Drawer(
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
              Icon(Icons.business, color: Colors.white, size: 48),
              SizedBox(height: 8),
              Text('Business Portal', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              Text('Manage your venue', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dashboard, color: AppTheme.primaryColor),
          title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
          onTap: () => context.go('/business-dashboard'),
        ),
        ListTile(
          leading: const Icon(Icons.store, color: Colors.white),
          title: const Text('My Venues', style: TextStyle(color: Colors.white)),
          onTap: () => context.push('/my-venues'),
        ),
        ListTile(
          leading: const Icon(Icons.local_offer, color: Colors.white),
          title: const Text('Manage Offers', style: TextStyle(color: Colors.white)),
          onTap: () => context.push('/manage-offers'),
        ),
        ListTile(
          leading: const Icon(Icons.bar_chart, color: Colors.white),
          title: const Text('Analytics', style: TextStyle(color: Colors.white)),
          onTap: () => context.push('/venue-analytics/$venueId'),
        ),
        ListTile(
          leading: const Icon(Icons.person, color: Colors.white),
          title: const Text('Profile', style: TextStyle(color: Colors.white)),
          onTap: () => context.push('/business-profile'),
        ),
        const Divider(color: Colors.white24),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: () => context.go('/login'),
        ),
      ],
    ),
  );
}

// ── Venue Header Card ────────────────────────────────────────────────────────

class _VenueHeaderCard extends StatelessWidget {
  final String name;
  final String address;
  final String openUntil;
  final bool isLive;
  final bool isVerified;
  final VoidCallback onTap;

  const _VenueHeaderCard({
    required this.name,
    required this.address,
    required this.openUntil,
    required this.isLive,
    required this.isVerified,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor.withOpacity(0.15), AppTheme.primaryColor.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(name,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    if (isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, color: AppTheme.primaryColor, size: 18),
                    ],
                  ]),
                  const SizedBox(height: 4),
                  if (address.isNotEmpty)
                    Text(address,
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isLive
                      ? const Color(0xFF10B981).withOpacity(0.15)
                      : const Color(0xFF475569).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      color: isLive ? const Color(0xFF10B981) : const Color(0xFF475569),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isLive ? 'LIVE' : 'OFFLINE',
                    style: TextStyle(
                      color: isLive ? const Color(0xFF10B981) : const Color(0xFF64748B),
                      fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5,
                    ),
                  ),
                ]),
              ),
            ]),
            if (openUntil.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.access_time_outlined, color: Color(0xFF64748B), size: 14),
                const SizedBox(width: 6),
                Text('Open until $openUntil',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Busyness Card ────────────────────────────────────────────────────────────

class _BusynessCard extends StatelessWidget {
  final int percentage;
  final String level;
  final String change;
  final int dwellMinutes;

  const _BusynessCard({
    required this.percentage,
    required this.level,
    required this.change,
    required this.dwellMinutes,
  });

  Color get _levelColor {
    if (percentage >= 75) return const Color(0xFFEF4444);
    if (percentage >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String get _levelLabel {
    switch (level.toLowerCase()) {
      case 'quiet': return 'QUIET';
      case 'moderate': return 'MODERATE';
      case 'busy': return 'BUSY';
      case 'packed': return 'PACKED';
      default: return level.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _levelColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('LIVE BUSYNESS',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Row(children: [
                Text('$percentage%',
                    style: TextStyle(color: _levelColor, fontSize: 36, fontWeight: FontWeight.w900)),
                const SizedBox(width: 8),
                Text(change, style: TextStyle(color: _levelColor, fontSize: 24)),
              ]),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _levelColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_levelLabel,
                  style: TextStyle(color: _levelColor, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1)),
            ),
          ]),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 12,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: AlwaysStoppedAnimation(_levelColor),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.timer_outlined, color: Color(0xFF64748B), size: 14),
            const SizedBox(width: 6),
            Text('Avg. dwell time: ${dwellMinutes}m',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          ]),
        ],
      ),
    );
  }
}

// ── Vibe Status Card ─────────────────────────────────────────────────────────

class _VibeStatusCard extends StatelessWidget {
  final String label;
  final List<String> tags;
  final int activeUsers;
  final VoidCallback onEdit;

  const _VibeStatusCard({
    required this.label,
    required this.tags,
    required this.activeUsers,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('CURRENT VIBE',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 14),
              label: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.take(6).map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(tag,
                  style: const TextStyle(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w600)),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.people_outline, color: Color(0xFF64748B), size: 14),
            const SizedBox(width: 6),
            Text('$activeUsers active users',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          ]),
        ],
      ),
    );
  }
}

// ── Engagement Card ──────────────────────────────────────────────────────────

class _EngagementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _EngagementCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(color: Color(0xFF475569), fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Weather Card ─────────────────────────────────────────────────────────────

class _WeatherCard extends StatelessWidget {
  final String message;
  final String icon;
  final int temperature;
  final String condition;

  const _WeatherCard({
    required this.message,
    required this.icon,
    required this.temperature,
    required this.condition,
  });

  IconData get _weatherIcon {
    switch (icon.toLowerCase()) {
      case 'rain': return Icons.water_drop;
      case 'cloud': return Icons.cloud;
      case 'sun': return Icons.wb_sunny;
      case 'snow': return Icons.ac_unit;
      default: return Icons.cloud_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF3B82F6).withOpacity(0.15), const Color(0xFF3B82F6).withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_weatherIcon, color: const Color(0xFF3B82F6), size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('$temperature°C',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Text(condition,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
            ]),
            const SizedBox(height: 4),
            Text(message,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4)),
          ]),
        ),
      ]),
    );
  }
}

// ── Quick Actions Grid ───────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  final String venueId;
  final String venueName;

  const _QuickActionsGrid({required this.venueId, required this.venueName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('QUICK ACTIONS',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _ActionTile(
              icon: Icons.bolt,
              label: 'Update Status',
              color: AppTheme.primaryColor,
              onTap: () => context.push('/venue-status/$venueId?name=${Uri.encodeComponent(venueName)}'),
            ),
            _ActionTile(
              icon: Icons.local_offer_outlined,
              label: 'Manage Offers',
              color: const Color(0xFF8B5CF6),
              onTap: () => context.push('/manage-offers'),
            ),
            _ActionTile(
              icon: Icons.bar_chart,
              label: 'Analytics',
              color: const Color(0xFF3B82F6),
              onTap: () => context.push('/venue-analytics/$venueId?name=${Uri.encodeComponent(venueName)}'),
            ),
            _ActionTile(
              icon: Icons.add_business,
              label: 'Create Venue',
              color: const Color(0xFFF59E0B),
              onTap: () => context.push('/admin/create-venue'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
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
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
