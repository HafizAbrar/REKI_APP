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
    final venuesAsync = ref.watch(myVenuesProvider);

    return venuesAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      ),
      error: (e, _) => _buildError(e.toString()),
      data: (venues) {
        if (venues.isEmpty) return _buildNoVenue();

        // Initialise selected venue on first load
        final selectedId = ref.watch(selectedVenueIdProvider) ?? venues.first['id']?.toString() ?? '';
        final dashboardAsync = ref.watch(businessDashboardProvider(selectedId));

        return dashboardAsync.when(
          loading: () => _buildScaffoldShell(
            venues: venues,
            selectedId: selectedId,
            child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
          ),
          error: (e, _) => _buildScaffoldShell(
            venues: venues,
            selectedId: selectedId,
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(e.toString(),
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => ref.refresh(businessDashboardProvider(selectedId)),
                  child: const Text('Retry', style: TextStyle(color: AppTheme.primaryColor)),
                ),
              ]),
            ),
          ),
          data: (data) => _buildDashboard(context, data, selectedId, venues),
        );
      },
    );
  }

  Widget _buildNoVenue() => Scaffold(
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
            child: Text(
              (AuthService().currentUser?.name.isNotEmpty == true)
                  ? AuthService().currentUser!.name[0].toUpperCase()
                  : 'B',
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
              Text(
                AuthService().currentUser?.name ?? 'Business',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
              const Text(
                'Business Portal',
                style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    ),
    drawer: _buildDrawer(context, ''),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 2),
              ),
              child: const Icon(Icons.store_outlined,
                  color: AppTheme.primaryColor, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to REKI Business',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'You haven\'t added a venue yet.\nCreate your first venue to start managing your business.',
              style: TextStyle(
                  color: Color(0xFF94A3B8), fontSize: 14, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.backgroundDark,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_business, size: 20),
                label: const Text('Create Your First Venue',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                onPressed: () => context.push('/admin/create-venue'),
              ),
            ),
          ],
        ),
      ),
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
          onPressed: () => ref.refresh(myVenuesProvider),
          child: const Text('Retry', style: TextStyle(color: AppTheme.primaryColor)),
        ),
      ]),
    ),
  );

  // Scaffold shell used while dashboard data is loading/erroring
  Widget _buildScaffoldShell({
    required List<Map<String, dynamic>> venues,
    required String selectedId,
    required Widget child,
  }) =>
      Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: _buildAppBar(venues, selectedId),
        drawer: _buildDrawer(context, selectedId),
        body: child,
      );

  AppBar _buildAppBar(List<Map<String, dynamic>> venues, String selectedId) {
    final user = AuthService().currentUser;
    final userName = user?.name ?? 'Business';
    final profilePic = user?.profilePicture;

    return AppBar(
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
            backgroundImage:
                profilePic != null ? NetworkImage(profilePic) : null,
            child: profilePic == null
                ? Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'B',
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
                'Business Portal',
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
        // Venue selector dropdown
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _VenueDropdown(
            venues: venues,
            selectedId: selectedId,
            onChanged: (id) {
              if (id != null) {
                ref.read(selectedVenueIdProvider.notifier).state = id;
              }
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
          onPressed: () => ref.refresh(businessDashboardProvider(selectedId)),
        ),
      ],
    );
  }

  Widget _buildDashboard(
      BuildContext context,
      Map<String, dynamic> data,
      String venueId,
      List<Map<String, dynamic>> venues,
      ) {
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
      appBar: _buildAppBar(venues, venueId),
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

// ── Venue Dropdown ───────────────────────────────────────────────────────────

class _VenueDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> venues;
  final String selectedId;
  final ValueChanged<String?> onChanged;

  const _VenueDropdown({
    required this.venues,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final validId = venues.any((v) => v['id']?.toString() == selectedId)
        ? selectedId
        : venues.first['id']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: validId,
          isDense: true,
          dropdownColor: const Color(0xFF1E293B),
          icon: const Icon(Icons.expand_more, color: AppTheme.primaryColor, size: 18),
          style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          items: venues.map((v) {
            final id = v['id']?.toString() ?? '';
            final name = v['name']?.toString() ?? id;
            return DropdownMenuItem<String>(
              value: id,
              child: Text(
                name.length > 18 ? '${name.substring(0, 16)}…' : name,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
