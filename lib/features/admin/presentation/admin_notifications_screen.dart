import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/admin_models.dart';
import '../data/admin_provider.dart';

class AdminNotificationsScreen extends ConsumerStatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  ConsumerState<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState
    extends ConsumerState<AdminNotificationsScreen> {
  int _page = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(adminProvider.notifier).loadNotificationLogs(page: _page));
  }

  void _goToPage(int page) {
    setState(() => _page = page);
    ref.read(adminProvider.notifier).loadNotificationLogs(page: page);
  }

  @override
  Widget build(BuildContext context) {
    final notifsAsync = ref.watch(adminProvider).notificationLogs;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Notifications',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: notifsAsync.when(
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF1E293B),
              child: Row(children: [
                Text(
                  '${page.total} notification${page.total == 1 ? '' : 's'}',
                  style: const TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 13),
                ),
                const SizedBox(width: 12),
                // unread count
                Builder(builder: (_) {
                  final unread = page.notifications
                      .where((n) => !n.isRead)
                      .length;
                  if (unread == 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$unread unread',
                        style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  );
                }),
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
                child: page.notifications.isEmpty
                    ? const Center(
                        child: Text('No notifications',
                            style: TextStyle(color: Color(0xFF64748B))),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: page.notifications.length,
                        itemBuilder: (_, i) =>
                            _notifCard(page.notifications[i]),
                      ),
              ),
            ),
            if (page.pages > 1) _paginationBar(page),
          ],
        ),
      ),
    );
  }

  Widget _notifCard(AdminNotification n) {
    final meta = _typeMeta(n.type);
    final isUnread = !n.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnread
            ? const Color(0xFF1E293B)
            : const Color(0xFF1E293B).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread
              ? meta.color.withValues(alpha: 0.3)
              : const Color(0xFF334155),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: meta.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(meta.icon, color: meta.color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.title,
                      style: TextStyle(
                          color: isUnread
                              ? Colors.white
                              : const Color(0xFF94A3B8),
                          fontWeight: isUnread
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 13)),
                  const SizedBox(height: 2),
                  _chip(n.type.replaceAll('_', ' '), meta.color),
                ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEF4444),
                ),
              )
            else
              const Icon(Icons.check_circle_outline,
                  color: Color(0xFF475569), size: 14),
            const SizedBox(height: 4),
            Text(_formatDateTime(n.createdAt),
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 10)),
          ]),
        ]),

        const SizedBox(height: 8),
        Text(n.message,
            style: TextStyle(
                color: isUnread
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                fontSize: 12,
                height: 1.4)),

        if (n.venueId != null || n.offerId != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            if (n.venueId != null)
              _contextBadge(
                  Icons.store_outlined, 'Venue', const Color(0xFF8B5CF6)),
            if (n.venueId != null && n.offerId != null)
              const SizedBox(width: 6),
            if (n.offerId != null)
              _contextBadge(Icons.local_offer_outlined, 'Offer',
                  const Color(0xFF2DD4BF)),
          ]),
        ],

        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.person_outline,
              color: Color(0xFF64748B), size: 11),
          const SizedBox(width: 4),
          Text(
            'User: ${n.userId.substring(0, 8)}…',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
          ),
        ]),
      ]),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

  Widget _contextBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 10),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  _NotifTypeMeta _typeMeta(String type) {
    switch (type) {
      case 'welcome':
        return _NotifTypeMeta(
            icon: Icons.waving_hand_outlined,
            color: const Color(0xFF2DD4BF));
      case 'vibe_alert':
        return _NotifTypeMeta(
            icon: Icons.bolt_outlined, color: const Color(0xFFF59E0B));
      case 'offer_confirmation':
        return _NotifTypeMeta(
            icon: Icons.local_offer_outlined,
            color: const Color(0xFF10B981));
      case 'live_performance':
        return _NotifTypeMeta(
            icon: Icons.music_note_outlined,
            color: const Color(0xFF8B5CF6));
      case 'social_checkin':
        return _NotifTypeMeta(
            icon: Icons.people_outline, color: const Color(0xFF3B82F6));
      case 'weekly_recap':
        return _NotifTypeMeta(
            icon: Icons.bar_chart_outlined,
            color: const Color(0xFF6366F1));
      case 'ticket_secured':
        return _NotifTypeMeta(
            icon: Icons.confirmation_number_outlined,
            color: const Color(0xFFEC4899));
      default:
        return _NotifTypeMeta(
            icon: Icons.notifications_outlined,
            color: const Color(0xFF64748B));
    }
  }

  Widget _paginationBar(AdminNotificationsPage page) {
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

class _NotifTypeMeta {
  final IconData icon;
  final Color color;
  const _NotifTypeMeta({required this.icon, required this.color});
}
