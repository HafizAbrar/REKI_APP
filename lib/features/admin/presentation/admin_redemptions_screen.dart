import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/admin_models.dart';
import '../data/admin_provider.dart';

class AdminRedemptionsScreen extends ConsumerStatefulWidget {
  const AdminRedemptionsScreen({super.key});

  @override
  ConsumerState<AdminRedemptionsScreen> createState() =>
      _AdminRedemptionsScreenState();
}

class _AdminRedemptionsScreenState
    extends ConsumerState<AdminRedemptionsScreen> {
  int _page = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(adminProvider.notifier).loadRedemptions(page: _page));
  }

  void _goToPage(int page) {
    setState(() => _page = page);
    ref.read(adminProvider.notifier).loadRedemptions(page: page);
  }

  @override
  Widget build(BuildContext context) {
    final redemptionsAsync = ref.watch(adminProvider).redemptions;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title:
            const Text('Redemptions', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: redemptionsAsync.when(
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
                Text('${page.total} redemption${page.total == 1 ? '' : 's'}',
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
                child: page.redemptions.isEmpty
                    ? const Center(
                        child: Text('No redemptions found',
                            style: TextStyle(color: Color(0xFF64748B))),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: page.redemptions.length,
                        itemBuilder: (_, i) =>
                            _redemptionCard(page.redemptions[i]),
                      ),
              ),
            ),
            if (page.pages > 1) _paginationBar(page),
          ],
        ),
      ),
    );
  }

  Widget _redemptionCard(AdminRedemption r) {
    final statusColor = r.status == 'redeemed'
        ? const Color(0xFF10B981)
        : r.status == 'active'
            ? const Color(0xFF3B82F6)
            : const Color(0xFF64748B);

    final hasSaving = r.savingValue > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header: offer title + status
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              r.status == 'redeemed'
                  ? Icons.check_circle_outline
                  : Icons.confirmation_number_outlined,
              color: statusColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.offerTitle,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.store_outlined,
                        color: Color(0xFF64748B), size: 12),
                    const SizedBox(width: 4),
                    Text(r.venueName,
                        style: const TextStyle(
                            color: Color(0xFF94A3B8), fontSize: 12)),
                  ]),
                ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _chip(r.status, statusColor),
            if (hasSaving) ...[
              const SizedBox(height: 4),
              Text('${r.currency} ${r.savingValue}',
                  style: const TextStyle(
                      color: Color(0xFF2DD4BF),
                      fontWeight: FontWeight.w800,
                      fontSize: 13)),
            ],
          ]),
        ]),

        const SizedBox(height: 12),
        const Divider(color: Color(0xFF334155), height: 1),
        const SizedBox(height: 10),

        // User row
        Row(children: [
          const Icon(Icons.person_outline,
              color: Color(0xFF64748B), size: 13),
          const SizedBox(width: 6),
          Text(r.userName,
              style: const TextStyle(
                  color: Color(0xFF94A3B8), fontSize: 12)),
          const Spacer(),
          // Voucher code
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(r.voucherCode,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
          ),
        ]),
        const SizedBox(height: 6),

        // Transaction ID
        Row(children: [
          const Icon(Icons.tag, color: Color(0xFF64748B), size: 13),
          const SizedBox(width: 6),
          Text(r.transactionId,
              style: const TextStyle(
                  color: Color(0xFF64748B), fontSize: 11)),
        ]),
        const SizedBox(height: 8),

        // Timestamps
        Row(children: [
          const Icon(Icons.access_time,
              color: Color(0xFF64748B), size: 12),
          const SizedBox(width: 4),
          Text('Claimed ${_formatDateTime(r.createdAt)}',
              style:
                  const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          if (r.redeemedAt != null) ...[
            const SizedBox(width: 12),
            const Icon(Icons.check_circle_outline,
                color: Color(0xFF10B981), size: 12),
            const SizedBox(width: 4),
            Text('Used ${_formatDateTime(r.redeemedAt!)}',
                style: const TextStyle(
                    color: Color(0xFF10B981), fontSize: 11)),
          ],
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
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _paginationBar(AdminRedemptionsPage page) {
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
