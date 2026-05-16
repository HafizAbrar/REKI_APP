import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/notification_preferences.dart';
import '../../users/data/user_preferences_provider.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  NotificationPreferences? _prefs;
  bool _saving = false;

  // Local mutable state
  late bool vibeAlerts;
  late bool livePerformance;
  late bool socialCheckins;
  late bool offerAlerts;
  late bool weeklyRecap;
  late bool proximityAlerts;
  String? quietHoursStart;
  String? quietHoursEnd;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final result = await ref
        .read(notificationPreferencesProvider.notifier)
        .load()
        .then((_) => ref.read(notificationPreferencesProvider).valueOrNull);
    if (!mounted || result == null) return;
    _applyPrefs(result);
  }

  void _applyPrefs(NotificationPreferences p) {
    setState(() {
      _prefs = p;
      vibeAlerts = p.vibeAlerts;
      livePerformance = p.livePerformance;
      socialCheckins = p.socialCheckins;
      offerAlerts = p.offerAlerts;
      weeklyRecap = p.weeklyRecap;
      proximityAlerts = p.proximityAlerts;
      quietHoursStart = p.quietHoursStart;
      quietHoursEnd = p.quietHoursEnd;
    });
  }

  Future<void> _save() async {
    if (_prefs == null) return;
    setState(() => _saving = true);
    final updated = _prefs!.copyWith(
      vibeAlerts: vibeAlerts,
      livePerformance: livePerformance,
      socialCheckins: socialCheckins,
      offerAlerts: offerAlerts,
      weeklyRecap: weeklyRecap,
      proximityAlerts: proximityAlerts,
      quietHoursStart: quietHoursStart,
      quietHoursEnd: quietHoursEnd,
    );
    final success = await ref
        .read(notificationPreferencesProvider.notifier)
        .update(updated);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success
          ? 'Notification preferences saved'
          : 'Failed to save preferences'),
      backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
    if (success) context.pop();
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = _parseTime(isStart ? quietHoursStart : quietHoursEnd);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF2DD4BF),
            surface: Color(0xFF1E293B),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (isStart) {
        quietHoursStart = formatted;
      } else {
        quietHoursEnd = formatted;
      }
    });
  }

  TimeOfDay _parseTime(String? t) {
    if (t == null) return const TimeOfDay(hour: 22, minute: 0);
    final parts = t.split(':');
    return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 22,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notifications',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: state.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Color(0xFF2DD4BF))),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.toString(),
                  style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _load,
                child: const Text('Retry',
                    style: TextStyle(color: Color(0xFF2DD4BF))),
              ),
            ],
          ),
        ),
        data: (_) => _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final quietEnabled = quietHoursStart != null || quietHoursEnd != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          _headerCard(),
          const SizedBox(height: 24),

          // Alert toggles
          _sectionLabel('Alert Types'),
          const SizedBox(height: 12),
          _toggleTile(
            icon: Icons.local_fire_department_outlined,
            iconColor: const Color(0xFFF97316),
            title: 'Vibe Alerts',
            subtitle: 'Get notified when a venue\'s vibe matches your taste',
            value: vibeAlerts,
            onChanged: (v) => setState(() => vibeAlerts = v),
          ),
          _toggleTile(
            icon: Icons.music_note_outlined,
            iconColor: const Color(0xFF8B5CF6),
            title: 'Live Performance',
            subtitle: 'Alerts for live music and performances nearby',
            value: livePerformance,
            onChanged: (v) => setState(() => livePerformance = v),
          ),
          _toggleTile(
            icon: Icons.people_outline,
            iconColor: const Color(0xFF2DD4BF),
            title: 'Social Check-ins',
            subtitle: 'When friends or contacts check in at a venue',
            value: socialCheckins,
            onChanged: (v) => setState(() => socialCheckins = v),
          ),
          _toggleTile(
            icon: Icons.local_offer_outlined,
            iconColor: const Color(0xFFEAB308),
            title: 'Offer Alerts',
            subtitle: 'Exclusive deals and offers from venues',
            value: offerAlerts,
            onChanged: (v) => setState(() => offerAlerts = v),
          ),
          _toggleTile(
            icon: Icons.calendar_today_outlined,
            iconColor: const Color(0xFF3B82F6),
            title: 'Weekly Recap',
            subtitle: 'A summary of your activity every week',
            value: weeklyRecap,
            onChanged: (v) => setState(() => weeklyRecap = v),
          ),
          _toggleTile(
            icon: Icons.location_on_outlined,
            iconColor: const Color(0xFFEC4899),
            title: 'Proximity Alerts',
            subtitle: 'Notify when you\'re near a venue you\'d love',
            value: proximityAlerts,
            onChanged: (v) => setState(() => proximityAlerts = v),
          ),

          const SizedBox(height: 28),

          // Quiet hours
          _sectionLabel('Quiet Hours'),
          const SizedBox(height: 12),
          _quietHoursCard(quietEnabled),

          const SizedBox(height: 36),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2DD4BF),
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Color(0xFF0F172A), strokeWidth: 2))
                  : const Text('Save Preferences',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2DD4BF).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: const Color(0xFF2DD4BF).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_outlined,
              color: Color(0xFF2DD4BF), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Notification Preferences',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  'Choose what you want to be notified about',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label,
        style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8));
  }

  Widget _toggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: value
                ? iconColor.withOpacity(0.3)
                : const Color(0xFF334155)),
      ),
      child: SwitchListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: TextStyle(
                color: Colors.white.withOpacity(0.45), fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeColor: iconColor,
        inactiveThumbColor: const Color(0xFF475569),
        inactiveTrackColor: const Color(0xFF334155),
      ),
    );
  }

  Widget _quietHoursCard(bool enabled) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: enabled
                ? const Color(0xFF2DD4BF).withOpacity(0.3)
                : const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF2DD4BF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bedtime_outlined,
                    color: Color(0xFF2DD4BF), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quiet Hours',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    Text('Silence notifications during set hours',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: (v) => setState(() {
                  if (v) {
                    quietHoursStart ??= '22:00';
                    quietHoursEnd ??= '09:00';
                  } else {
                    quietHoursStart = null;
                    quietHoursEnd = null;
                  }
                }),
                activeColor: const Color(0xFF2DD4BF),
                inactiveThumbColor: const Color(0xFF475569),
                inactiveTrackColor: const Color(0xFF334155),
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF334155), height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _timePicker(
                        label: 'Start',
                        time: quietHoursStart ?? '22:00',
                        onTap: () => _pickTime(true))),
                const SizedBox(width: 12),
                Expanded(
                    child: _timePicker(
                        label: 'End',
                        time: quietHoursEnd ?? '09:00',
                        onTap: () => _pickTime(false))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _timePicker(
      {required String label,
      required String time,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time,
                    color: Color(0xFF2DD4BF), size: 16),
                const SizedBox(width: 6),
                Text(time,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
