import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/admin_models.dart';
import '../data/admin_provider.dart';

class AdminActivityLogsScreen extends ConsumerStatefulWidget {
  const AdminActivityLogsScreen({super.key});

  @override
  ConsumerState<AdminActivityLogsScreen> createState() =>
      _AdminActivityLogsScreenState();
}

class _AdminActivityLogsScreenState
    extends ConsumerState<AdminActivityLogsScreen> {
  int _page = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(adminProvider.notifier).loadActivityLogs(page: _page));
  }

  void _goToPage(int page) {
    setState(() => _page = page);
    ref.read(adminProvider.notifier).loadActivityLogs(page: page);
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(adminProvider).activityLogs;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Activity Logs',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: logsAsync.when(
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
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF1E293B),
              child: Row(children: [
                Text('${page.total} log${page.total == 1 ? '' : 's'} total',
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
                child: page.logs.isEmpty
                    ? const Center(
                        child: Text('No activity logs',
                            style: TextStyle(color: Color(0xFF64748B))),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: page.logs.length,
                        itemBuilder: (_, i) => _logCard(page.logs[i]),
                      ),
              ),
            ),
            if (page.pages > 1) _paginationBar(page),
          ],
        ),
      ),
    );
  }

  Widget _logCard(ActivityLog log) {
    final meta = _actionMeta(log.action);
    final hasDetails = log.details != null && log.details!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: meta.color.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: meta.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(meta.icon, color: meta.color, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meta.label,
                      style: TextStyle(
                          color: meta.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                  const SizedBox(height: 2),
                  Row(children: [
                    _roleBadge(log.actorRole),
                    const SizedBox(width: 6),
                    Text(
                      '${log.target.replaceAll('_', ' ')} · ${log.targetId.substring(0, 8)}…',
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 10),
                    ),
                  ]),
                ]),
          ),
          Text(_formatDateTime(log.createdAt),
              style: const TextStyle(
                  color: Color(0xFF64748B), fontSize: 10)),
        ]),

        if (hasDetails) ...[
          const SizedBox(height: 10),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 8),
          _buildDetails(log.details!, meta.color),
        ],
      ]),
    );
  }

  Widget _buildDetails(Map<String, dynamic> details, Color accent) {
    final name = details['name']?.toString();
    final title = details['title']?.toString();
    final busyness = details['busyness']?.toString();
    final percentage = details['percentage'];
    final vibes = (details['vibes'] as List?)?.map((e) => e.toString()).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (name != null)
        _detailRow(Icons.store_outlined, 'Venue', name, accent),
      if (title != null)
        _detailRow(Icons.local_offer_outlined, 'Offer', title, accent),
      if (busyness != null || percentage != null) ...[
        if (name != null || title != null) const SizedBox(height: 6),
        Row(children: [
          if (busyness != null) ...[
            _chip(busyness, _busynessColor(busyness)),
            const SizedBox(width: 8),
          ],
          if (percentage != null) ...[
            Text('$percentage%',
                style: TextStyle(
                    color: _busynessColor(busyness ?? ''),
                    fontWeight: FontWeight.w800,
                    fontSize: 13)),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ((percentage as num) / 100).clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: const Color(0xFF0F172A),
                  valueColor: AlwaysStoppedAnimation(
                      _busynessColor(busyness ?? '')),
                ),
              ),
            ),
          ],
        ]),
      ],
      if (vibes != null && vibes.isNotEmpty) ...[
        const SizedBox(height: 8),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: vibes
              .map((v) => _chip(v, const Color(0xFF3B82F6)))
              .toList(),
        ),
      ],
    ]);
  }

  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF64748B), size: 12),
        const SizedBox(width: 5),
        Text('$label: ',
            style:
                const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }

  Widget _roleBadge(String role) {
    final color = role == 'admin'
        ? const Color(0xFFEF4444)
        : role == 'business'
            ? const Color(0xFF8B5CF6)
            : const Color(0xFF2DD4BF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(role,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }

  Color _busynessColor(String level) => level == 'busy'
      ? const Color(0xFFEF4444)
      : level == 'moderate'
          ? const Color(0xFFF59E0B)
          : const Color(0xFF10B981);

  _ActionMeta _actionMeta(String action) {
    switch (action) {
      case 'BUSINESS_LOGIN':
        return _ActionMeta(
            icon: Icons.login,
            label: 'Business Login',
            color: const Color(0xFF64748B));
      case 'STATUS_UPDATE':
        return _ActionMeta(
            icon: Icons.update,
            label: 'Status Update',
            color: const Color(0xFF3B82F6));
      case 'OFFER_CREATED':
        return _ActionMeta(
            icon: Icons.local_offer_outlined,
            label: 'Offer Created',
            color: const Color(0xFF2DD4BF));
      case 'VENUE_CREATED':
        return _ActionMeta(
            icon: Icons.add_business,
            label: 'Venue Created',
            color: const Color(0xFF10B981));
      case 'VENUE_DELETED':
        return _ActionMeta(
            icon: Icons.delete_outline,
            label: 'Venue Deleted',
            color: const Color(0xFFEF4444));
      case 'USER_LOGIN':
        return _ActionMeta(
            icon: Icons.person_outline,
            label: 'User Login',
            color: const Color(0xFF8B5CF6));
      default:
        return _ActionMeta(
            icon: Icons.info_outline,
            label: action.replaceAll('_', ' '),
            color: const Color(0xFFF59E0B));
    }
  }

  Widget _paginationBar(ActivityLogsPage page) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF1E293B),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _pageBtn(
            icon: Icons.chevron_left,
            enabled: page.hasPrev,
            onTap: () => _goToPage(_page - 1)),
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
            onTap: () => _goToPage(_page + 1)),
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

  String _formatDateTime(DateTime dt) =>
      '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _ActionMeta {
  final IconData icon;
  final String label;
  final Color color;
  const _ActionMeta(
      {required this.icon, required this.label, required this.color});
}
