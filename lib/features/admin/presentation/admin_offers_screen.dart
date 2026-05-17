import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/admin_models.dart';
import '../data/admin_provider.dart';

class AdminOffersScreen extends ConsumerStatefulWidget {
  const AdminOffersScreen({super.key});

  @override
  ConsumerState<AdminOffersScreen> createState() => _AdminOffersScreenState();
}

class _AdminOffersScreenState extends ConsumerState<AdminOffersScreen> {
  int _page = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(adminProvider.notifier).loadOffers(page: _page));
  }

  void _goToPage(int page) {
    setState(() => _page = page);
    ref.read(adminProvider.notifier).loadOffers(page: page);
  }

  @override
  Widget build(BuildContext context) {
    final offersAsync = ref.watch(adminProvider).offers;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Offers', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: offersAsync.when(
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
                Text('${page.total} offers total',
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
                  itemCount: page.offers.length,
                  itemBuilder: (_, i) => _offerCard(page.offers[i]),
                ),
              ),
            ),
            if (page.pages > 1) _paginationBar(page),
          ],
        ),
      ),
    );
  }

  Widget _offerCard(AdminOffer o) {
    final typeMeta = _typeMeta(o.type);
    final redemptionRatio =
        o.maxRedemptions > 0 ? o.redemptionCount / o.maxRedemptions : 0.0;
    final isExpired = o.expiresAt.isBefore(DateTime.now());
    final expiryColor =
        isExpired ? const Color(0xFFEF4444) : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: typeMeta.color.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: typeMeta.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(typeMeta.icon, color: typeMeta.color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.store_outlined,
                        color: Color(0xFF64748B), size: 12),
                    const SizedBox(width: 4),
                    Text(o.venueName,
                        style: const TextStyle(
                            color: Color(0xFF94A3B8), fontSize: 12)),
                  ]),
                ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _chip(o.type, typeMeta.color),
            const SizedBox(height: 4),
            _chip(
              o.isActive ? 'active' : 'inactive',
              o.isActive
                  ? const Color(0xFF10B981)
                  : const Color(0xFF64748B),
            ),
          ]),
        ]),

        const SizedBox(height: 14),
        const Divider(color: Color(0xFF334155), height: 1),
        const SizedBox(height: 12),

        // Redemption progress
        Row(children: [
          const Icon(Icons.confirmation_number_outlined,
              color: Color(0xFF64748B), size: 13),
          const SizedBox(width: 6),
          Text('${o.redemptionCount} / ${o.maxRedemptions} redeemed',
              style: const TextStyle(
                  color: Color(0xFF94A3B8), fontSize: 12)),
          const Spacer(),
          Text('${(redemptionRatio * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                  color: typeMeta.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: redemptionRatio.clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: const Color(0xFF0F172A),
            valueColor: AlwaysStoppedAnimation(typeMeta.color),
          ),
        ),

        const SizedBox(height: 10),

        // Dates row
        Row(children: [
          const Icon(Icons.calendar_today_outlined,
              color: Color(0xFF64748B), size: 12),
          const SizedBox(width: 4),
          Text('Created ${_formatDate(o.createdAt)}',
              style:
                  const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          const Spacer(),
          Icon(
            isExpired ? Icons.timer_off_outlined : Icons.timer_outlined,
            color: expiryColor,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            isExpired
                ? 'Expired ${_formatDate(o.expiresAt)}'
                : 'Expires ${_formatDate(o.expiresAt)}',
            style: TextStyle(color: expiryColor, fontSize: 11),
          ),
        ]),
      ]),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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

  _TypeMeta _typeMeta(String type) {
    switch (type) {
      case 'discount':
        return _TypeMeta(
            icon: Icons.percent, color: const Color(0xFF3B82F6));
      case '2-for-1':
        return _TypeMeta(
            icon: Icons.filter_2, color: const Color(0xFF8B5CF6));
      case 'freebie':
        return _TypeMeta(
            icon: Icons.card_giftcard, color: const Color(0xFF10B981));
      case 'guestlist':
        return _TypeMeta(
            icon: Icons.list_alt, color: const Color(0xFFF59E0B));
      default:
        return _TypeMeta(
            icon: Icons.local_offer_outlined,
            color: const Color(0xFF2DD4BF));
    }
  }

  Widget _paginationBar(AdminOffersPage page) {
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

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';
}

class _TypeMeta {
  final IconData icon;
  final Color color;
  const _TypeMeta({required this.icon, required this.color});
}
