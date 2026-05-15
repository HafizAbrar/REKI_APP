import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/offer_detail_provider.dart';
import '../../../core/services/offer_repository.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user.dart';

class OfferDetailScreen extends ConsumerStatefulWidget {
  final String offerId;
  const OfferDetailScreen({super.key, required this.offerId});

  @override
  ConsumerState<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends ConsumerState<OfferDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(offerRepositoryProvider).markOfferViewed(widget.offerId));
  }

  @override
  Widget build(BuildContext context) {
    final offerAsync = ref.watch(offerDetailProvider(widget.offerId));
    final actionState = ref.watch(offerActionProvider(widget.offerId));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: offerAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Color(0xFF2DD4BF))),
        error: (e, _) => _buildError(e),
        data: (offer) => Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(offer),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusRow(offer),
                        const SizedBox(height: 16),
                        Text(offer.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1.2)),
                        const SizedBox(height: 10),
                        Text(offer.description,
                            style: const TextStyle(
                                color: Color(0xFF94A3B8), fontSize: 15, height: 1.5)),
                        const SizedBox(height: 24),
                        _buildVenueCard(offer),
                        const SizedBox(height: 16),
                        _buildDetailsCard(offer),
                        const SizedBox(height: 16),
                        _buildValidityCard(offer),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              child: _iconBtn(Icons.arrow_back_ios_new, () => context.pop()),
            ),
            // Bottom CTA
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _buildBottomBar(offer, actionState),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────

  Widget _buildHero(offer) {
    final color = _typeColor(offer.type);
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.3), const Color(0xFF1E293B)],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(_typeIcon(offer.type), size: 80,
                color: color.withOpacity(0.4)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, const Color(0xFF0F172A)],
                stops: const [0.4, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Status row ────────────────────────────────────────────────────────────

  Widget _buildStatusRow(offer) {
    final status = offer.status as String;
    final isAvailableNow = offer.isAvailableNow as bool;
    final statusColor = _statusColor(status, isAvailableNow);
    final statusLabel = isAvailableNow ? 'Live Now' : _capitalize(status);

    return Row(
      children: [
        _badge(statusLabel, statusColor, dot: true),
        const SizedBox(width: 8),
        _badge(offer.type.replaceAll('-', ' ').toUpperCase(),
            const Color(0xFF64748B)),
        if ((offer.savingValue ?? 0) > 0) ...[
          const SizedBox(width: 8),
          _badge('Save £${offer.savingValue}', const Color(0xFF10B981)),
        ],
      ],
    );
  }

  // ── Venue card ────────────────────────────────────────────────────────────

  Widget _buildVenueCard(offer) {
    final name = offer.venue?['name'] as String? ?? '';
    final address = offer.venue?['address'] as String? ?? '';
    if (name.isEmpty) return const SizedBox.shrink();

    return _card(
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2DD4BF).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.store_outlined, color: Color(0xFF2DD4BF), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                if (address.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        color: Color(0xFF64748B), size: 13),
                    const SizedBox(width: 3),
                    Text(address,
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 13)),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Details card ──────────────────────────────────────────────────────────

  Widget _buildDetailsCard(offer) {
    final days = (offer.validDays as List<String>);
    final daysLabel = days.length == 7
        ? 'Every day'
        : days.length <= 3
            ? days.join(', ')
            : '${days.first} – ${days.last}';

    return _card(
      child: Column(
        children: [
          _detailRow(Icons.access_time_outlined, 'Valid Hours',
              '${offer.validTimeStart ?? ''} – ${offer.validTimeEnd ?? ''}'),
          const _Divider(),
          _detailRow(Icons.calendar_today_outlined, 'Valid Days', daysLabel),
          const _Divider(),
          _detailRow(Icons.savings_outlined, 'Saving',
              offer.savingValue != null && offer.savingValue! > 0
                  ? '£${offer.savingValue} GBP'
                  : 'Varies'),
        ],
      ),
    );
  }

  // ── Validity card ─────────────────────────────────────────────────────────

  Widget _buildValidityCard(offer) {
    final expires = offer.validUntil;
    final formatted =
        '${expires.day.toString().padLeft(2, '0')}/${expires.month.toString().padLeft(2, '0')}/${expires.year}';

    return _card(
      child: _detailRow(
          Icons.event_outlined, 'Expires', formatted),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar(offer, OfferActionState actionState) {
    final isAvailableNow = offer.isAvailableNow as bool;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isAvailableNow)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFFF59E0B), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      offer.status == 'upcoming'
                          ? 'Available from ${offer.validTimeStart}'
                          : 'Not available right now',
                      style: const TextStyle(
                          color: Color(0xFFF59E0B), fontSize: 12),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAvailableNow
                      ? const Color(0xFF2DD4BF)
                      : const Color(0xFF334155),
                  foregroundColor: isAvailableNow
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF64748B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                onPressed: actionState.isLoading ? null : _onRedeem,
                child: actionState.isLoading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_activity,
                              size: 20,
                              color: isAvailableNow
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF64748B)),
                          const SizedBox(width: 8),
                          Text(
                            isAvailableNow ? 'Redeem Offer' : 'Not Available Now',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Show this screen to staff to claim',
                style: TextStyle(color: Color(0xFF475569), fontSize: 12)),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  // ── Redeem flow ───────────────────────────────────────────────────────────

  Future<void> _onRedeem() async {
    final user = AuthService().currentUser;
    if (user == null || user.isGuest) {
      _showGuestSheet();
      return;
    }

    final notifier = ref.read(offerActionProvider(widget.offerId).notifier);
    final claimed = await notifier.claim();
    if (!mounted) return;

    if (!claimed) {
      final err = ref.read(offerActionProvider(widget.offerId)).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Failed to claim offer'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Navigate to redeemed screen with claim data — user redeems from there
    final claimData = ref.read(offerActionProvider(widget.offerId)).claimData;
    context.push('/offer-redeemed?offerId=${widget.offerId}', extra: claimData);
  }

  void _showGuestSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Icon(Icons.lock_outline, color: Color(0xFF2DD4BF), size: 36),
            const SizedBox(height: 16),
            const Text('Sign in to redeem offers',
                style: TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Create a free account to claim exclusive offers.',
                style: TextStyle(
                    color: Color(0xFF94A3B8), fontSize: 14, height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF334155)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/login');
                  },
                  child: const Text('Log In',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DD4BF),
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/signup');
                  },
                  child: const Text('Sign Up',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError(Object e) {
    return Center(
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
            onPressed: () =>
                ref.invalidate(offerDetailProvider(widget.offerId)),
            child: const Text('Retry',
                style: TextStyle(color: Color(0xFF2DD4BF))),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: child,
      );

  Widget _detailRow(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, color: const Color(0xFF2DD4BF), size: 18),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      );

  Widget _badge(String label, Color color, {bool dot = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot) ...[
              Container(
                  width: 6, height: 6,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 5),
            ],
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      );

  Color _typeColor(String type) {
    switch (type) {
      case '2-for-1': return const Color(0xFF2DD4BF);
      case 'discount': return const Color(0xFFF59E0B);
      case 'freebie': return const Color(0xFF10B981);
      case 'guestlist': return const Color(0xFF8B5CF6);
      case 'happy-hour': return const Color(0xFFEF4444);
      default: return const Color(0xFF2DD4BF);
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case '2-for-1': return Icons.people_outline;
      case 'discount': return Icons.percent;
      case 'freebie': return Icons.card_giftcard_outlined;
      case 'guestlist': return Icons.playlist_add_check;
      case 'happy-hour': return Icons.local_bar_outlined;
      default: return Icons.local_activity_outlined;
    }
  }

  Color _statusColor(String status, bool isAvailableNow) {
    if (isAvailableNow) return const Color(0xFF10B981);
    switch (status) {
      case 'upcoming': return const Color(0xFFF59E0B);
      default: return const Color(0xFF64748B);
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white.withOpacity(0.06));
}
