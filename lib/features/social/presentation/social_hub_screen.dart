import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/social_models.dart';
import '../data/social_provider.dart';

class SocialHubScreen extends ConsumerWidget {
  const SocialHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('My REKI'),
          bottom: const TabBar(
            indicatorColor: Color(0xFF2DD4BF),
            labelColor: Color(0xFF2DD4BF),
            unselectedLabelColor: Color(0xFF94A3B8),
            tabs: [
              Tab(text: 'Activity'),
              Tab(text: 'Badges'),
              Tab(text: 'Leaderboard'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_ActivityTab(), _BadgesTab(), _LeaderboardTab()],
        ),
      ),
    );
  }
}

class _ActivityTab extends ConsumerWidget {
  const _ActivityTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(venueHistoryProvider);
    final checkIns = ref.watch(checkInsProvider);
    return RefreshIndicator(
      color: const Color(0xFF2DD4BF),
      onRefresh: () async {
        await ref.read(venueHistoryProvider.notifier).load();
        ref.invalidate(checkInsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Expanded(child: _SectionTitle('Recent venues')),
              TextButton(
                onPressed: history.valueOrNull?.isNotEmpty == true
                    ? () => ref.read(venueHistoryProvider.notifier).clear()
                    : null,
                child: const Text('Clear'),
              ),
            ],
          ),
          history.when(
            loading: () => const _Loading(),
            error: (e, _) => _ErrorText(e),
            data: (items) => items.isEmpty
                ? const _Empty('Venues you view will appear here.')
                : Column(
                    children: items.map((item) {
                      final visited = DateTime.fromMillisecondsSinceEpoch(
                          item['visited_at'] as int);
                      return _ActivityTile(
                        icon: Icons.history,
                        title: item['venue_name'] as String,
                        subtitle: DateFormat('d MMM, h:mm a').format(visited),
                        onTap: () => context.push('/venue/${item['venue_id']}'),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Check-ins'),
          const SizedBox(height: 8),
          checkIns.when(
            loading: () => const _Loading(),
            error: (e, _) => _ErrorText(e),
            data: (items) => items.isEmpty
                ? const _Empty('Check in at a venue to start earning points.')
                : Column(
                    children: items
                        .map((item) => _ActivityTile(
                              icon: Icons.location_on,
                              title: item.venueName,
                              subtitle: DateFormat('d MMM, h:mm a')
                                  .format(item.checkedInAt),
                              onTap: () =>
                                  context.push('/venue/${item.venueId}'),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BadgesTab extends ConsumerWidget {
  const _BadgesTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(achievementsProvider);
    return state.when(
      loading: () => const _Loading(),
      error: (e, _) => _ErrorText(e),
      data: (items) {
        final unlocked = items.where((badge) => badge.isUnlocked).length;
        return RefreshIndicator(
          color: const Color(0xFF2DD4BF),
          backgroundColor: const Color(0xFF1E293B),
          onRefresh: () async => ref.invalidate(achievementsProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                sliver: SliverToBoxAdapter(
                  child: _BadgeSummary(
                    unlocked: unlocked,
                    total: items.length,
                  ),
                ),
              ),
              if (items.isEmpty)
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _Empty(
                      'Your achievements will appear here as you explore.',
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 230,
                      mainAxisExtent: 224,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => _BadgeCard(badge: items[index]),
                      childCount: items.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BadgeSummary extends StatelessWidget {
  final int unlocked;
  final int total;

  const _BadgeSummary({required this.unlocked, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : unlocked / total;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF17263A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF2DD4BF).withValues(alpha: .12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFF2DD4BF),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$unlocked of $total unlocked',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Keep exploring to grow your collection.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    color: const Color(0xFF2DD4BF),
                    backgroundColor: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final Achievement badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.isUnlocked;
    final accent = _badgeColor('${badge.id} ${badge.title}');
    final current = badge.progress.clamp(0, badge.target);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              unlocked ? accent.withValues(alpha: .7) : const Color(0xFF334155),
        ),
        boxShadow: [
          BoxShadow(
            color: unlocked ? accent.withValues(alpha: .08) : Colors.black12,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: unlocked ? .16 : .08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _badgeIcon('${badge.icon} ${badge.id} ${badge.title}'),
                  color: unlocked ? accent : const Color(0xFF64748B),
                  size: 25,
                ),
              ),
              Icon(
                unlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
                color: unlocked ? accent : const Color(0xFF64748B),
                size: 19,
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            badge.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: unlocked ? Colors.white : const Color(0xFFCBD5E1),
              fontSize: 15,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                unlocked ? 'Completed' : 'Progress',
                style: TextStyle(
                  color: unlocked ? accent : const Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '$current/${badge.target}',
                style: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: badge.fraction,
              minHeight: 5,
              color: unlocked ? accent : const Color(0xFF2DD4BF),
              backgroundColor: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _badgeIcon(String value) {
    final key = value.toLowerCase();
    if (key.contains('first') || key.contains('night')) {
      return Icons.celebration_rounded;
    }
    if (key.contains('explor') ||
        key.contains('city') ||
        key.contains('compass')) {
      return Icons.explore_rounded;
    }
    if (key.contains('critic') ||
        key.contains('review') ||
        key.contains('star')) {
      return Icons.rate_review_rounded;
    }
    if (key.contains('social') || key.contains('friend')) {
      return Icons.groups_rounded;
    }
    if (key.contains('collect') ||
        key.contains('save') ||
        key.contains('bookmark')) {
      return Icons.bookmark_rounded;
    }
    if (key.contains('regular') ||
        key.contains('fire') ||
        key.contains('streak')) {
      return Icons.local_fire_department_rounded;
    }
    return Icons.workspace_premium_rounded;
  }

  static Color _badgeColor(String value) {
    final key = value.toLowerCase();
    if (key.contains('critic') || key.contains('review')) {
      return const Color(0xFFF59E0B);
    }
    if (key.contains('social') || key.contains('friend')) {
      return const Color(0xFF8B5CF6);
    }
    if (key.contains('regular') || key.contains('streak')) {
      return const Color(0xFFF97316);
    }
    return const Color(0xFF2DD4BF);
  }
}

class _LeaderboardTab extends ConsumerWidget {
  const _LeaderboardTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaderboardProvider);
    return state.when(
      loading: () => const _Loading(),
      error: (e, _) => _ErrorText(e),
      data: (items) => RefreshIndicator(
        color: const Color(0xFF2DD4BF),
        onRefresh: () async => ref.invalidate(leaderboardProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Weekly points',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Check-ins +20 • Reviews +10 • Saves +5',
                style: TextStyle(color: Color(0xFF94A3B8))),
            const SizedBox(height: 16),
            if (items.length == 1)
              const _Empty(
                  'Your personal score is ready. Community rankings appear when the cloud leaderboard is enabled.'),
            ...items.map((entry) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: entry.isCurrentUser
                        ? const Color(0xFF2DD4BF).withValues(alpha: .12)
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: entry.isCurrentUser
                            ? const Color(0xFF2DD4BF)
                            : const Color(0xFF334155)),
                  ),
                  child: Row(children: [
                    SizedBox(
                      width: 38,
                      child: Text('#${entry.rank}',
                          style: const TextStyle(
                              color: Color(0xFF2DD4BF),
                              fontWeight: FontWeight.w800)),
                    ),
                    Expanded(
                      child: Text(entry.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                    Text('${entry.points} pts',
                        style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            fontWeight: FontWeight.w700)),
                  ]),
                )),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActivityTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
        color: const Color(0xFF1E293B),
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: const Color(0xFF2DD4BF)),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          subtitle:
              Text(subtitle, style: const TextStyle(color: Color(0xFF94A3B8))),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800));
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty(this.text);
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14)),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF94A3B8))),
      );
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Center(
      child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: Color(0xFF2DD4BF))));
}

class _ErrorText extends StatelessWidget {
  final Object error;
  const _ErrorText(this.error);
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Could not load: $error',
              style: const TextStyle(color: Colors.redAccent))));
}
