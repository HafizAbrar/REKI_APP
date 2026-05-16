import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/notification_management_provider.dart';
import '../../../core/models/notification.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user.dart';

// Tab definitions: label → types it matches (empty = all)
const _tabs = [
  ('All',    <NotificationType>[]),
  ('Vibes',  [NotificationType.vibe, NotificationType.venue]),
  ('Offers', [NotificationType.offer]),
  ('Other',  [NotificationType.welcome, NotificationType.system, NotificationType.alert]),
];

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _selectedTab = 0;

  List<AppNotification> _applyFilter(List<AppNotification> all) {
    final types = _tabs[_selectedTab].$2;
    if (types.isEmpty) return all;
    return all.where((n) => types.contains(n.type)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null || user.isGuest) return _buildGuestView(context);

    final notificationsAsync = ref.watch(notificationManagementProvider);
    final notifier = ref.read(notificationManagementProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Column(
        children: [
          _buildHeader(notifier),
          Expanded(
            child: notificationsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2DD4BF))),
              error: (e, _) => _buildError(e.toString(), notifier),
              data: (grouped) {
                final all = <AppNotification>[
                  ...grouped['today'] ?? [],
                  ...grouped['yesterday'] ?? [],
                  ...grouped['earlier'] ?? [],
                ];
                final filtered = _applyFilter(all);

                if (filtered.isEmpty) return _buildEmpty();

                // Re-bucket filtered list by time group
                final todayIds = (grouped['today'] ?? []).map((n) => n.id).toSet();
                final yesterdayIds = (grouped['yesterday'] ?? []).map((n) => n.id).toSet();

                final today = filtered.where((n) => todayIds.contains(n.id)).toList();
                final yesterday = filtered.where((n) => yesterdayIds.contains(n.id)).toList();
                final earlier = filtered.where((n) => !todayIds.contains(n.id) && !yesterdayIds.contains(n.id)).toList();

                return ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    if (today.isNotEmpty) ...[
                      _sectionHeader('TODAY'),
                      ...today.map((n) => _notificationTile(n, notifier)),
                    ],
                    if (yesterday.isNotEmpty) ...[
                      _sectionHeader('YESTERDAY'),
                      ...yesterday.map((n) => _notificationTile(n, notifier)),
                    ],
                    if (earlier.isNotEmpty) ...[
                      _sectionHeader('EARLIER'),
                      ...earlier.map((n) => _notificationTile(n, notifier)),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(NotificationManagementNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  const Text('Notifications',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800)),
                  const Spacer(),
                  // Unread count badge
                  Consumer(builder: (_, ref, __) {
                    final count = ref.watch(notificationManagementProvider
                        .select((s) => s.valueOrNull != null
                            ? [
                                ...?s.valueOrNull!['today'],
                                ...?s.valueOrNull!['yesterday'],
                                ...?s.valueOrNull!['earlier'],
                              ].where((n) => !n.isRead).length
                            : 0));
                    if (count > 0)
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2DD4BF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF2DD4BF).withOpacity(0.3)),
                        ),
                        child: Text('$count unread',
                            style: const TextStyle(
                                color: Color(0xFF2DD4BF),
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      );
                    return const SizedBox.shrink();
                  }),
                  GestureDetector(
                    onTap: () => notifier.markAllAsRead(),
                    child: const Text('Mark all read',
                        style: TextStyle(
                            color: Color(0xFF2DD4BF),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            // Filter tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final isSelected = _selectedTab == i;
                  return Padding(
                    padding: EdgeInsets.only(right: i < _tabs.length - 1 ? 10 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2DD4BF)
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(18),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2DD4BF)
                                        .withOpacity(0.3),
                                    blurRadius: 12,
                                  )
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            _tabs[i].$1,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF94A3B8),
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
        child: Text(title,
            style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2)),
      );

  Widget _notificationTile(
      AppNotification n, NotificationManagementNotifier notifier) {
    final (color, icon) = _typeConfig(n.type);
    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => notifier.deleteNotification(n.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.withOpacity(0.8),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () {
          if (!n.isRead) notifier.markAsRead(n.id);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: n.isRead
                ? Colors.transparent
                : const Color(0xFF1E293B).withOpacity(0.5),
            border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: n.icon != null && n.icon!.isNotEmpty
                    ? Center(
                        child: Text(n.icon!,
                            style: const TextStyle(fontSize: 20)))
                    : Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(n.title,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: n.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700)),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: Color(0xFF2DD4BF),
                              shape: BoxShape.circle),
                        ),
                    ]),
                    const SizedBox(height: 4),
                    Text(n.message,
                        style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                            height: 1.4)),
                    const SizedBox(height: 6),
                    Text(_formatTime(n.timestamp),
                        style: const TextStyle(
                            color: Color(0xFF475569), fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none,
                color: Colors.white.withOpacity(0.15), size: 64),
            const SizedBox(height: 16),
            Text(
              _selectedTab == 0
                  ? 'No notifications yet'
                  : 'No ${_tabs[_selectedTab].$1.toLowerCase()} notifications',
              style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );

  Widget _buildError(String msg, NotificationManagementNotifier notifier) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.notifications_off_outlined,
                  color: Color(0xFF475569), size: 56),
              const SizedBox(height: 16),
              Text(msg,
                  style: const TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 14),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DD4BF),
                  foregroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => notifier.loadNotifications(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );

  Widget _buildGuestView(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('Notifications'),
            elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.notifications_none,
                    color: Color(0xFF2DD4BF), size: 64),
                const SizedBox(height: 24),
                const Text('Sign in to see notifications',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                const Text(
                    'Get notified about venue updates, new offers, and more.',
                    style: TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 14, height: 1.5),
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2DD4BF),
                      foregroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999)),
                      elevation: 0,
                    ),
                    onPressed: () => context.go('/signup'),
                    child: const Text('Create Account',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF334155)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999)),
                    ),
                    onPressed: () => context.go('/login'),
                    child: const Text('Log In',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  (Color, IconData) _typeConfig(NotificationType type) {
    switch (type) {
      case NotificationType.offer:
        return (const Color(0xFF06B6D4), Icons.local_offer);
      case NotificationType.venue:
        return (const Color(0xFF0D9488), Icons.store);
      case NotificationType.welcome:
        return (const Color(0xFF8B5CF6), Icons.celebration);
      case NotificationType.vibe:
        return (const Color(0xFFF59E0B), Icons.local_fire_department);
      case NotificationType.alert:
        return (const Color(0xFFEF4444), Icons.warning_amber);
      case NotificationType.system:
        return (const Color(0xFF6B7280), Icons.info_outline);
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
