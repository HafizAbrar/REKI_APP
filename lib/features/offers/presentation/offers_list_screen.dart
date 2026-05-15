import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/offers_provider.dart';
import '../../../core/models/offer.dart';

class OffersListScreen extends ConsumerStatefulWidget {
  final String? venueId;
  final String? venueName;
  const OffersListScreen({super.key, this.venueId, this.venueName});

  @override
  ConsumerState<OffersListScreen> createState() => _OffersListScreenState();
}

class _OffersListScreenState extends ConsumerState<OffersListScreen> {
  String _selectedType = 'All';
  String _selectedStatus = 'All';

  static const _types = ['All', '2-for-1', 'discount', 'freebie', 'guestlist', 'happy-hour'];
  static const _statuses = ['All', 'active', 'upcoming', 'inactive'];

  @override
  Widget build(BuildContext context) {
    final isVenueMode = widget.venueId != null && widget.venueId!.isNotEmpty;
    final offersAsync = isVenueMode
        ? ref.watch(venueOffersProvider(widget.venueId!))
        : ref.watch(offersProvider);
    final title = isVenueMode && widget.venueName != null
        ? '${widget.venueName} Offers'
        : 'Offers';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => isVenueMode
                ? ref.invalidate(venueOffersProvider(widget.venueId!))
                : ref.invalidate(offersProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: offersAsync.when(
              data: (offers) {
                final filtered = offers.where((o) {
                  final typeMatch = _selectedType == 'All' || o.type == _selectedType;
                  final statusMatch = _selectedStatus == 'All' || o.status == _selectedStatus;
                  return typeMatch && statusMatch;
                }).toList();

                if (filtered.isEmpty) return _buildEmpty();

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _OfferCard(offer: filtered[i]),
                );
              },
              loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2DD4BF))),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFF94A3B8), size: 48),
                    const SizedBox(height: 16),
                    Text('$e',
                        style: const TextStyle(color: Color(0xFF94A3B8)),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => ref.invalidate(offersProvider),
                      child: const Text('Retry', style: TextStyle(color: Color(0xFF2DD4BF))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Type', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _types.map((t) => _FilterChip(
                label: t == 'All' ? 'All' : t.replaceAll('-', ' '),
                selected: _selectedType == t,
                onTap: () => setState(() => _selectedType = t),
              )).toList(),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Status', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 6),
          Row(
            children: _statuses.map((s) => _FilterChip(
              label: s[0].toUpperCase() + s.substring(1),
              selected: _selectedStatus == s,
              color: _statusColor(s),
              onTap: () => setState(() => _selectedStatus = s),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_activity_outlined, color: Color(0xFF334155), size: 64),
          const SizedBox(height: 16),
          const Text('No offers found',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Try adjusting your filters',
              style: TextStyle(color: Color(0xFF94A3B8))),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => setState(() {
              _selectedType = 'All';
              _selectedStatus = 'All';
            }),
            child: const Text('Clear filters', style: TextStyle(color: Color(0xFF2DD4BF))),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'active': return const Color(0xFF10B981);
      case 'upcoming': return const Color(0xFFF59E0B);
      case 'inactive': return const Color(0xFF64748B);
      default: return const Color(0xFF2DD4BF);
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = const Color(0xFF2DD4BF),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : const Color(0xFF334155)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : const Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Offer offer;
  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final status = offer.status;
    final isAvailableNow = offer.isAvailableNow;
    final venueName = offer.venue?['name'] as String? ?? '';
    final venueAddress = offer.venue?['address'] as String? ?? '';
    final savingValue = offer.savingValue ?? 0;

    final statusColor = _statusColor(status);
    final typeIcon = _typeIcon(offer.type);

    return GestureDetector(
      onTap: () => context.push('/offer-detail?id=${offer.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAvailableNow
                ? const Color(0xFF2DD4BF).withOpacity(0.4)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isAvailableNow
                    ? const Color(0xFF2DD4BF).withOpacity(0.08)
                    : Colors.transparent,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(typeIcon, color: statusColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      offer.title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _StatusBadge(status: status, isAvailableNow: isAvailableNow),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.description,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Venue
                      const Icon(Icons.store_outlined, color: Color(0xFF64748B), size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          venueName.isNotEmpty ? '$venueName · $venueAddress' : venueAddress,
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Time window
                      const Icon(Icons.access_time, color: Color(0xFF64748B), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${offer.validTimeStart ?? ''} – ${offer.validTimeEnd ?? ''}  ·  ${_formatDays(offer.validDays)}',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                      const Spacer(),
                      // Saving value
                      if (savingValue > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Save £$savingValue',
                            style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Type tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      offer.type.replaceAll('-', ' ').toUpperCase(),
                      style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDays(List<String> days) {
    if (days.length == 7) return 'Every day';
    if (days.length <= 3) return days.join(', ');
    return '${days.first}–${days.last}';
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'active': return const Color(0xFF10B981);
      case 'upcoming': return const Color(0xFFF59E0B);
      default: return const Color(0xFF64748B);
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case '2-for-1': return Icons.people_outline;
      case 'discount': return Icons.percent;
      case 'freebie': return Icons.card_giftcard;
      case 'guestlist': return Icons.playlist_add_check;
      case 'happy-hour': return Icons.local_bar_outlined;
      default: return Icons.local_activity;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isAvailableNow;
  const _StatusBadge({required this.status, required this.isAvailableNow});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    if (isAvailableNow) {
      color = const Color(0xFF10B981);
      label = 'Live Now';
    } else {
      switch (status) {
        case 'upcoming':
          color = const Color(0xFFF59E0B);
          label = 'Upcoming';
          break;
        case 'inactive':
          color = const Color(0xFF64748B);
          label = 'Inactive';
          break;
        default:
          color = const Color(0xFF64748B);
          label = status[0].toUpperCase() + status.substring(1);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6, height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
