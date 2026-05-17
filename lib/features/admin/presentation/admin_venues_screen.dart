import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/admin_models.dart';
import '../data/admin_provider.dart';
import 'venue_logs_screen.dart';

class AdminVenuesScreen extends ConsumerStatefulWidget {
  const AdminVenuesScreen({super.key});

  @override
  ConsumerState<AdminVenuesScreen> createState() => _AdminVenuesScreenState();
}

class _AdminVenuesScreenState extends ConsumerState<AdminVenuesScreen> {
  int _page = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).loadVenues(page: _page));
  }

  void _goToPage(int page) {
    setState(() => _page = page);
    ref.read(adminProvider.notifier).loadVenues(page: page);
  }

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(adminProvider).venues;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Venues', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: venuesAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF2DD4BF))),
        error: (err, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(err.toString(),
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _goToPage(_page),
              child: const Text('Retry',
                  style: TextStyle(color: Color(0xFF2DD4BF))),
            ),
          ]),
        ),
        data: (page) => Column(
          children: [
            // Summary bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF1E293B),
              child: Row(children: [
                Text('${page.total} venues total',
                    style: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 13)),
                const Spacer(),
                Text('Page $_page of ${page.pages}',
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 12)),
              ]),
            ),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF2DD4BF),
                backgroundColor: const Color(0xFF1E293B),
                onRefresh: () async => _goToPage(_page),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: page.venues.length,
                  itemBuilder: (_, i) => _venueCard(page.venues[i]),
                ),
              ),
            ),
            if (page.pages > 1) _paginationBar(page),
          ],
        ),
      ),
    );
  }

  Widget _venueCard(AdminVenue v) {
    final busynessColor = v.busynessLevel == 'busy'
        ? const Color(0xFFEF4444)
        : v.busynessLevel == 'moderate'
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981);

    final categoryLabel = v.category.replaceAll('_', ' ');

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VenueLogsScreen(
            venueId: v.id,
            venueName: v.name,
          ),
        ),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: busynessColor.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row
        Row(children: [
          Expanded(
            child: Text(v.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ),
          if (v.isLive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 5),
                const Text('LIVE',
                    style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5)),
              ]),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('OFFLINE',
                  style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
        ]),
        const SizedBox(height: 6),

        // Address + city
        Row(children: [
          const Icon(Icons.location_on_outlined,
              color: Color(0xFF64748B), size: 13),
          const SizedBox(width: 4),
          Expanded(
            child: Text('${v.address}, ${v.city}',
                style: const TextStyle(
                    color: Color(0xFF94A3B8), fontSize: 12),
                overflow: TextOverflow.ellipsis),
          ),
        ]),
        const SizedBox(height: 10),

        // Category + busyness level
        Row(children: [
          _chip(categoryLabel, const Color(0xFF8B5CF6)),
          const SizedBox(width: 8),
          _chip(v.busynessLevel, busynessColor),
          const Spacer(),
          Text('${v.busynessPercent}%',
              style: TextStyle(
                  color: busynessColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 14)),
        ]),
        const SizedBox(height: 8),

        // Busyness bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: v.busynessPercent / 100,
            minHeight: 5,
            backgroundColor: const Color(0xFF0F172A),
            valueColor: AlwaysStoppedAnimation(busynessColor),
          ),
        ),

        // Vibes
        if (v.vibes.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: v.vibes
                .map((vibe) => _chip(vibe, const Color(0xFF3B82F6)))
                .toList(),
          ),
        ],
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          const Icon(Icons.history, color: Color(0xFF64748B), size: 12),
          const SizedBox(width: 4),
          const Text('View Logs',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          const SizedBox(width: 2),
          const Icon(Icons.chevron_right,
              color: Color(0xFF64748B), size: 14),
        ]),
      ]),
    ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _paginationBar(AdminVenuesPage page) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF1E293B),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _pageBtn(
          icon: Icons.chevron_left,
          enabled: page.hasPrev,
          onTap: () => _goToPage(_page - 1),
        ),
        const SizedBox(width: 16),
        ...List.generate(page.pages, (i) {
          final p = i + 1;
          final isCurrent = p == _page;
          return GestureDetector(
            onTap: isCurrent ? null : () => _goToPage(p),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCurrent
                    ? const Color(0xFF2DD4BF)
                    : const Color(0xFF334155),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('$p',
                    style: TextStyle(
                        color: isCurrent
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
            ),
          );
        }),
        const SizedBox(width: 16),
        _pageBtn(
          icon: Icons.chevron_right,
          enabled: page.hasNext,
          onTap: () => _goToPage(_page + 1),
        ),
      ]),
    );
  }

  Widget _pageBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF2DD4BF).withValues(alpha: 0.15)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: enabled
                  ? const Color(0xFF2DD4BF).withValues(alpha: 0.4)
                  : const Color(0xFF334155)),
        ),
        child: Icon(icon,
            color: enabled
                ? const Color(0xFF2DD4BF)
                : const Color(0xFF475569),
            size: 18),
      ),
    );
  }
}
