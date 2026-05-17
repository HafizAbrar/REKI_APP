import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/admin_models.dart';
import '../data/admin_provider.dart';

class UserActivityScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userName;

  const UserActivityScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  ConsumerState<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends ConsumerState<UserActivityScreen> {
  late Future<UserActivityData> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(adminProvider.notifier).getUserActivity(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(widget.userName,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<UserActivityData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2DD4BF)));
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(snap.error.toString(),
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() {
                    _future = ref
                        .read(adminProvider.notifier)
                        .getUserActivity(widget.userId);
                  }),
                  child: const Text('Retry',
                      style: TextStyle(color: Color(0xFF2DD4BF))),
                ),
              ]),
            );
          }

          final data = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _userInfoCard(data),
              const SizedBox(height: 20),
              Row(children: [
                const Text('REDEMPTIONS',
                    style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2DD4BF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${data.totalRedemptions} total',
                      style: const TextStyle(
                          color: Color(0xFF2DD4BF),
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 12),
              if (data.redemptions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('No redemptions yet',
                        style: TextStyle(color: Color(0xFF64748B))),
                  ),
                )
              else
                ...data.redemptions.map(_redemptionCard),
            ],
          );
        },
      ),
    );
  }

  Widget _userInfoCard(UserActivityData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2DD4BF).withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFF2DD4BF).withValues(alpha: 0.15),
            child: Text(
              data.name.isNotEmpty ? data.name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: Color(0xFF2DD4BF),
                  fontWeight: FontWeight.w800,
                  fontSize: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(data.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              const SizedBox(height: 2),
              Text(
                data.email?.isNotEmpty == true ? data.email! : 'No email',
                style:
                    const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
            ]),
          ),
          _roleBadge(data.role),
        ]),
        const SizedBox(height: 14),
        const Divider(color: Color(0xFF334155)),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.calendar_today_outlined,
              color: Color(0xFF64748B), size: 13),
          const SizedBox(width: 6),
          Text('Joined ${_formatDate(data.createdAt)}',
              style:
                  const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const Spacer(),
          const Icon(Icons.confirmation_number_outlined,
              color: Color(0xFF64748B), size: 13),
          const SizedBox(width: 6),
          Text('${data.totalRedemptions} redemptions',
              style:
                  const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        ]),
      ]),
    );
  }

  Widget _redemptionCard(UserActivityRedemption r) {
    final statusColor = r.status == 'active'
        ? const Color(0xFF10B981)
        : r.status == 'used'
            ? const Color(0xFF3B82F6)
            : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(r.offerTitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ),
          _statusBadge(r.status, statusColor),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.store_outlined, color: Color(0xFF64748B), size: 13),
          const SizedBox(width: 5),
          Text(r.venueName,
              style:
                  const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(width: 8),
          const Icon(Icons.location_on_outlined,
              color: Color(0xFF64748B), size: 13),
          const SizedBox(width: 4),
          Expanded(
            child: Text(r.venueAddress,
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 11),
                overflow: TextOverflow.ellipsis),
          ),
        ]),
        const SizedBox(height: 10),
        const Divider(color: Color(0xFF334155), height: 1),
        const SizedBox(height: 10),
        Row(children: [
          _infoChip(Icons.confirmation_number_outlined, r.voucherCode),
          const SizedBox(width: 8),
          _infoChip(Icons.tag, r.transactionId),
          const Spacer(),
          Text('${r.currency} ${r.savingValue}',
              style: const TextStyle(
                  color: Color(0xFF2DD4BF),
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.access_time, color: Color(0xFF64748B), size: 12),
          const SizedBox(width: 4),
          Text('Claimed ${_formatDate(r.createdAt)}',
              style:
                  const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          if (r.redeemedAt != null) ...[
            const SizedBox(width: 12),
            const Icon(Icons.check_circle_outline,
                color: Color(0xFF10B981), size: 12),
            const SizedBox(width: 4),
            Text('Used ${_formatDate(r.redeemedAt!)}',
                style: const TextStyle(
                    color: Color(0xFF10B981), fontSize: 11)),
          ],
        ]),
      ]),
    );
  }

  Widget _roleBadge(String role) {
    final color = role == 'admin'
        ? const Color(0xFFEF4444)
        : role == 'guest'
            ? const Color(0xFF64748B)
            : const Color(0xFF2DD4BF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(role,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: const Color(0xFF64748B), size: 12),
      const SizedBox(width: 4),
      Text(label,
          style:
              const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
    ]);
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
