import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/offer_detail_provider.dart';

class OfferRedeemedScreen extends ConsumerStatefulWidget {
  final String offerId;
  final Map<String, dynamic>? claimData;

  const OfferRedeemedScreen({
    super.key,
    required this.offerId,
    this.claimData,
  });

  @override
  ConsumerState<OfferRedeemedScreen> createState() => _OfferRedeemedScreenState();
}

class _OfferRedeemedScreenState extends ConsumerState<OfferRedeemedScreen> {
  bool _redeemed = false;

  String get _voucherCode =>
      widget.claimData?['voucherCode'] as String? ?? '';
  String get _transactionId =>
      widget.claimData?['transactionId'] as String? ?? '';
  String get _qrCodeData =>
      widget.claimData?['qrCodeData'] as String? ?? _voucherCode;

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(offerActionProvider(widget.offerId));
    final offerAsync = ref.watch(offerDetailProvider(widget.offerId));

    final offerTitle = offerAsync.valueOrNull?.title ?? 'Offer';
    final venueName = offerAsync.valueOrNull?.venue?['name'] as String? ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Glow
          Positioned(
            top: -100,
            left: MediaQuery.of(context).size.width / 2 - 180,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _redeemed
                    ? const Color(0xFF10B981).withOpacity(0.15)
                    : const Color(0xFF2DD4BF).withOpacity(0.15),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _iconBtn(Icons.arrow_back_ios_new,
                          () => context.pop()),
                      const SizedBox(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Status icon
                  _buildStatusIcon(),
                  const SizedBox(height: 20),

                  Text(
                    _redeemed ? 'Offer Redeemed!' : "Offer Claimed!",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _redeemed
                        ? 'Enjoy your offer. See you again!'
                        : 'Show this to staff and tap Redeem to confirm.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 28),

                  // Ticket card
                  _buildTicket(offerTitle, venueName),
                  const SizedBox(height: 24),

                  // Redeem button
                  if (!_redeemed) ...[
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
                        onPressed: actionState.isLoading ? null : _onRedeem,
                        child: actionState.isLoading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    color: Color(0xFF0F172A), strokeWidth: 2))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline, size: 20),
                                  SizedBox(width: 8),
                                  Text('Confirm Redemption',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Back to home
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF334155)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                      onPressed: () => context.go('/home'),
                      child: const Text('Back to Home',
                          style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    final color = _redeemed ? const Color(0xFF10B981) : const Color(0xFF2DD4BF);
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 32),
        ],
      ),
      child: Icon(
        _redeemed ? Icons.celebration : Icons.confirmation_number_outlined,
        color: Colors.white,
        size: 44,
      ),
    );
  }

  Widget _buildTicket(String offerTitle, String venueName) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          // Offer info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (venueName.isNotEmpty) ...[
                  Row(children: [
                    const Icon(Icons.store_outlined,
                        color: Color(0xFF2DD4BF), size: 16),
                    const SizedBox(width: 6),
                    Text(venueName,
                        style: const TextStyle(
                            color: Color(0xFF2DD4BF),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 8),
                ],
                Text(offerTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                // Transaction ID
                if (_transactionId.isNotEmpty)
                  _infoRow('Transaction', _transactionId),
                _infoRow('Status',
                    _redeemed ? '✓ Redeemed' : '● Active',
                    valueColor: _redeemed
                        ? const Color(0xFF10B981)
                        : const Color(0xFF2DD4BF)),
              ],
            ),
          ),

          // Divider with notches
          _ticketDivider(),

          // QR + voucher code
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // QR placeholder (shows voucher code as visual)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.qr_code_2,
                                color: Colors.white, size: 100),
                            if (_redeemed)
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.check_circle,
                                    color: Color(0xFF10B981), size: 60),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Voucher code with copy
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _voucherCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Voucher code copied'),
                        backgroundColor: const Color(0xFF1E293B),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF2DD4BF).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _voucherCode,
                          style: const TextStyle(
                            color: Color(0xFF2DD4BF),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.copy,
                            color: Color(0xFF64748B), size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Tap to copy code',
                    style: TextStyle(
                        color: Color(0xFF475569), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketDivider() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          color: Colors.white.withOpacity(0.08),
        ),
        Positioned(
          left: -12, top: -12,
          child: Container(
            width: 24, height: 24,
            decoration: const BoxDecoration(
                color: Color(0xFF0F172A), shape: BoxShape.circle),
          ),
        ),
        Positioned(
          right: -12, top: -12,
          child: Container(
            width: 24, height: 24,
            decoration: const BoxDecoration(
                color: Color(0xFF0F172A), shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF64748B), fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Future<void> _onRedeem() async {
    final success =
        await ref.read(offerActionProvider(widget.offerId).notifier).redeem();
    if (!mounted) return;

    if (success) {
      setState(() => _redeemed = true);
    } else {
      final err = ref.read(offerActionProvider(widget.offerId)).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Failed to redeem offer'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
