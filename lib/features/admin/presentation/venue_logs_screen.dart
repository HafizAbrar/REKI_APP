import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/admin_models.dart';
import '../data/admin_provider.dart';

class VenueLogsScreen extends ConsumerStatefulWidget {
  final String venueId;
  final String venueName;

  const VenueLogsScreen({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  ConsumerState<VenueLogsScreen> createState() => _VenueLogsScreenState();
}

class _VenueLogsScreenState extends ConsumerState<VenueLogsScreen> {
  late Future<VenueLogsData> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ref.read(adminProvider.notifier).getVenueLogs(widget.venueId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.venueName,
                style: const TextStyle(color: Colors.white, fontSize: 15)),
            const Text('Activity Logs',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<VenueLogsData>(
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
                  onPressed: () => setState(_load),
                  child: const Text('Retry',
                      style: TextStyle(color: Color(0xFF2DD4BF))),
                ),
              ]),
            );
          }

          final data = snap.data!;
          return Column(
            children: [
              // Summary bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: const Color(0xFF1E293B),
                child: Row(children: [
                  const Icon(Icons.history, color: Color(0xFF2DD4BF), size: 16),
                  const SizedBox(width: 8),
                  Text('${data.count} log${data.count == 1 ? '' : 's'} recorded',
                      style: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 13)),
                ]),
              ),
              Expanded(
                child: data.logs.isEmpty
                    ? const Center(
                        child: Text('No logs found',
                            style: TextStyle(color: Color(0xFF64748B))),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: data.logs.length,
                        itemBuilder: (_, i) => _logCard(data.logs[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _logCard(VenueLog log) {
    final actionMeta = _actionMeta(log.action);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: actionMeta.color.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: actionMeta.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(actionMeta.icon, color: actionMeta.color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(actionMeta.label,
                      style: TextStyle(
                          color: actionMeta.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                  const SizedBox(height: 2),
                  Row(children: [
                    _roleBadge(log.actorRole),
                    const SizedBox(width: 6),
                    Text(
                      log.actorId.substring(0, 8) + '...',
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ]),
                ]),
          ),
          Text(_formatDateTime(log.createdAt),
              style: const TextStyle(
                  color: Color(0xFF64748B), fontSize: 11)),
        ]),

        // Details
        if (_hasDetails(log.details)) ...[
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 12),
          _buildDetails(log.details, actionMeta.color),
        ],
      ]),
    );
  }

  bool _hasDetails(VenueLogDetails d) =>
      d.busyness != null ||
      d.percentage != null ||
      d.vibes.isNotEmpty ||
      d.name != null;

  Widget _buildDetails(VenueLogDetails d, Color accentColor) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (d.name != null)
        _detailRow(Icons.store_outlined, 'Name', d.name!, accentColor),

      if (d.busyness != null || d.percentage != null) ...[
        if (d.name != null) const SizedBox(height: 8),
        Row(children: [
          if (d.busyness != null) ...[
            _chip(d.busyness!, _busynessColor(d.busyness!)),
            const SizedBox(width: 8),
          ],
          if (d.percentage != null) ...[
            Text('${d.percentage}%',
                style: TextStyle(
                    color: _busynessColor(d.busyness ?? ''),
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (d.percentage ?? 0) / 100,
                  minHeight: 5,
                  backgroundColor: const Color(0xFF0F172A),
                  valueColor: AlwaysStoppedAnimation(
                      _busynessColor(d.busyness ?? '')),
                ),
              ),
            ),
          ],
        ]),
      ],

      if (d.vibes.isNotEmpty) ...[
        const SizedBox(height: 10),
        const Text('VIBES',
            style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: d.vibes
              .map((v) => _chip(v, const Color(0xFF3B82F6)))
              .toList(),
        ),
      ],
    ]);
  }

  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Row(children: [
      Icon(icon, color: const Color(0xFF64748B), size: 13),
      const SizedBox(width: 6),
      Text('$label: ',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
      Text(value,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    ]);
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

  Widget _roleBadge(String role) {
    final color = role == 'admin'
        ? const Color(0xFFEF4444)
        : role == 'business'
            ? const Color(0xFF8B5CF6)
            : const Color(0xFF2DD4BF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
      case 'STATUS_UPDATE':
        return _ActionMeta(
          icon: Icons.update,
          label: 'Status Update',
          color: const Color(0xFF3B82F6),
        );
      case 'VENUE_CREATED':
        return _ActionMeta(
          icon: Icons.add_business,
          label: 'Venue Created',
          color: const Color(0xFF10B981),
        );
      case 'VENUE_DELETED':
        return _ActionMeta(
          icon: Icons.delete_outline,
          label: 'Venue Deleted',
          color: const Color(0xFFEF4444),
        );
      case 'OFFER_CREATED':
        return _ActionMeta(
          icon: Icons.local_offer_outlined,
          label: 'Offer Created',
          color: const Color(0xFF2DD4BF),
        );
      default:
        return _ActionMeta(
          icon: Icons.info_outline,
          label: action.replaceAll('_', ' '),
          color: const Color(0xFF8B5CF6),
        );
    }
  }

  String _formatDateTime(DateTime dt) {
    final date = '${dt.day}/${dt.month}/${dt.year}';
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}

class _ActionMeta {
  final IconData icon;
  final String label;
  final Color color;
  const _ActionMeta({required this.icon, required this.label, required this.color});
}
