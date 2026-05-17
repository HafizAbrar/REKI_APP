import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'business_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_handler.dart';

class ManageOffersScreen extends ConsumerStatefulWidget {
  const ManageOffersScreen({super.key});

  @override
  ConsumerState<ManageOffersScreen> createState() => _ManageOffersScreenState();
}

class _ManageOffersScreenState extends ConsumerState<ManageOffersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String? get _venueId {
    final fromProvider = ref.read(selectedVenueIdProvider);
    if (fromProvider != null && fromProvider.isNotEmpty) return fromProvider;
    return ref.read(myVenuesProvider).valueOrNull?.firstOrNull?['id']?.toString();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final venueId = _venueId;
    if (venueId == null || venueId.isEmpty) return _buildNoVenue();

    final offersAsync = ref.watch(businessVenueOffersProvider(venueId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Manage Offers',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
            onPressed: () =>
                ref.read(businessVenueOffersProvider(venueId).notifier).load(),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppTheme.primaryColor, size: 26),
            onPressed: () => context.push('/create-offer?venueId=$venueId'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 2.5,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Active Deals'),
            Tab(text: 'Upcoming & Past'),
          ],
        ),
      ),
      body: offersAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (e, _) => _buildError(ErrorHandler.getErrorMessage(e), venueId),
        data: (data) {
          final activeDeals =
              (data['activeDeals'] as List? ?? []).cast<Map<String, dynamic>>();
          final upcomingAndPast =
              (data['upcomingAndPast'] as List? ?? []).cast<Map<String, dynamic>>();
          final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
          final total = pagination['total'] ?? (activeDeals.length + upcomingAndPast.length);

          return Column(
            children: [
              // Summary bar
              _SummaryBar(
                total: total,
                activeCount: activeDeals.length,
                pastCount: upcomingAndPast.length,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _OffersList(
                      offers: activeDeals,
                      emptyMessage: 'No active deals',
                      emptyIcon: Icons.local_offer_outlined,
                      venueId: venueId,
                      onRefresh: () async => ref
                          .read(businessVenueOffersProvider(venueId).notifier)
                          .load(),
                      onToggle: (id, isActive) => _toggleOffer(id, venueId, isActive),
                      onDelete: (id, title) => _deleteOffer(id, title, venueId),
                      onEdit: (id) => _editOffer(id, activeDeals, venueId),
                    ),
                    _OffersList(
                      offers: upcomingAndPast,
                      emptyMessage: 'No upcoming or past deals',
                      emptyIcon: Icons.history_outlined,
                      venueId: venueId,
                      onRefresh: () async => ref
                          .read(businessVenueOffersProvider(venueId).notifier)
                          .load(),
                      onToggle: (id, isActive) => _toggleOffer(id, venueId, isActive),
                      onDelete: (id, title) => _deleteOffer(id, title, venueId),
                      onEdit: (id) => _editOffer(id, upcomingAndPast, venueId),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-offer?venueId=${_venueId ?? ''}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.backgroundDark,
        icon: const Icon(Icons.add),
        label: const Text('New Offer', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildNoVenue() => Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop()),
          title: const Text('Manage Offers',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.store_outlined,
                color: Colors.white.withValues(alpha: 0.3), size: 64),
            const SizedBox(height: 16),
            const Text('No venue found',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.push('/admin/create-venue'),
              child: const Text('Create Venue',
                  style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      );

  Widget _buildError(String message, String venueId) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                ref.read(businessVenueOffersProvider(venueId).notifier).load(),
            child: const Text('Retry',
                style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ]),
      );

  Future<void> _editOffer(String id, List<Map<String, dynamic>> offers, String venueId) async {
    final offer = offers.firstWhere((o) => o['id'].toString() == id, orElse: () => {});
    if (offer.isEmpty) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditOfferSheet(
        offer: offer,
        onSave: (data) async {
          final success = await ref
              .read(businessVenueOffersProvider(venueId).notifier)
              .updateOffer(id, data);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(success ? 'Offer updated' : 'Failed to update offer'),
              backgroundColor: success ? const Color(0xFF10B981) : Colors.red[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ));
          }
        },
      ),
    );
  }

  Future<void> _toggleOffer(String id, String venueId, bool currentIsActive) async {
    final success = await ref
        .read(businessVenueOffersProvider(venueId).notifier)
        .toggleOffer(id, isActive: !currentIsActive);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Failed to toggle offer'),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Future<void> _deleteOffer(String id, String title, String venueId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Offer',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
            'Are you sure you want to delete "$title"? This cannot be undone.',
            style: const TextStyle(color: Color(0xFF94A3B8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ref
          .read(businessVenueOffersProvider(venueId).notifier)
          .deleteOffer(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              success ? 'Offer deleted' : 'Failed to delete offer'),
          backgroundColor:
              success ? const Color(0xFF10B981) : Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }
}

// ── Summary Bar ──────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final int total;
  final int activeCount;
  final int pastCount;

  const _SummaryBar({
    required this.total,
    required this.activeCount,
    required this.pastCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
            bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Row(children: [
        _stat('Total', total.toString(), const Color(0xFF94A3B8)),
        const SizedBox(width: 24),
        _stat('Active', activeCount.toString(), AppTheme.primaryColor),
        const SizedBox(width: 24),
        _stat('Past', pastCount.toString(), const Color(0xFF64748B)),
      ]),
    );
  }

  Widget _stat(String label, String value, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF64748B), fontSize: 12)),
        ],
      );
}

// ── Offers List ──────────────────────────────────────────────────────────────

class _OffersList extends StatelessWidget {
  final List<Map<String, dynamic>> offers;
  final String emptyMessage;
  final IconData emptyIcon;
  final String venueId;
  final Future<void> Function() onRefresh;
  final void Function(String id, bool isActive) onToggle;
  final void Function(String id, String title) onDelete;
  final void Function(String id) onEdit;

  const _OffersList({
    required this.offers,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.venueId,
    required this.onRefresh,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(emptyIcon,
              color: Colors.white.withValues(alpha: 0.2), size: 56),
          const SizedBox(height: 14),
          Text(emptyMessage,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 15)),
        ]),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      backgroundColor: AppTheme.surface,
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: offers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _OfferCard(
          offer: offers[i],
          onToggle: (isActive) => onToggle(offers[i]['id'].toString(), isActive),
          onDelete: () => onDelete(
              offers[i]['id'].toString(),
              offers[i]['title']?.toString() ?? 'Offer'),
          onEdit: () => onEdit(offers[i]['id'].toString()),
        ),
      ),
    );
  }
}

// ── Offer Card ───────────────────────────────────────────────────────────────

class _OfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  final void Function(bool isActive) onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _OfferCard({
    required this.offer,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = offer['isActive'] as bool? ?? false;
    final title = offer['title']?.toString() ?? 'Untitled';
    final schedule = offer['schedule']?.toString() ?? '';
    final redemptions = offer['redemptionCount'] ?? 0;
    final id = offer['id']?.toString() ?? '';

    final statusColor =
        isActive ? const Color(0xFF10B981) : const Color(0xFF475569);

    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[700],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryColor.withValues(alpha: 0.25)
                : const Color(0xFF334155),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 10),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: statusColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isActive ? 'LIVE' : 'OFF',
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5),
                  ),
                ]),
              ),
            ]),

            if (schedule.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.schedule_outlined,
                    color: Color(0xFF64748B), size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(schedule,
                      style: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
            ],

            const SizedBox(height: 12),
            const Divider(color: Color(0xFF334155), height: 1),
            const SizedBox(height: 12),

            // Footer row
            Row(children: [
              // Redemptions
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.confirmation_number_outlined,
                      color: Color(0xFF64748B), size: 14),
                  const SizedBox(width: 6),
                  Text('$redemptions redeemed',
                      style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ]),
              ),
              const Spacer(),
              // Edit button
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: AppTheme.primaryColor, size: 16),
                ),
              ),
              const SizedBox(width: 8),
              // Toggle button
              GestureDetector(
                onTap: () => onToggle(isActive),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF475569).withValues(alpha: 0.2)
                        : AppTheme.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF475569)
                          : AppTheme.primaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: isActive
                          ? const Color(0xFF94A3B8)
                          : AppTheme.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isActive ? 'Pause' : 'Activate',
                      style: TextStyle(
                          color: isActive
                              ? const Color(0xFF94A3B8)
                              : AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
              // Delete button
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 16),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Edit Offer Sheet ─────────────────────────────────────────────────────────

const _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const _offerTypes = [
  ('2-for-1', '2 for 1', Icons.local_bar, Color(0xFF8B5CF6)),
  ('discount', 'Discount', Icons.percent, Color(0xFF3B82F6)),
  ('freebie', 'Freebie', Icons.card_giftcard, Color(0xFF10B981)),
  ('guestlist', 'Guestlist', Icons.star, Color(0xFFF59E0B)),
  ('happy-hour', 'Happy Hour', Icons.access_time, Color(0xFFEF4444)),
];

class _EditOfferSheet extends StatefulWidget {
  final Map<String, dynamic> offer;
  final Future<void> Function(Map<String, dynamic> data) onSave;

  const _EditOfferSheet({required this.offer, required this.onSave});

  @override
  State<_EditOfferSheet> createState() => _EditOfferSheetState();
}

class _EditOfferSheetState extends State<_EditOfferSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _maxRedCtrl;
  late final TextEditingController _savingCtrl;

  late String _offerType;
  late Set<String> _validDays;
  late TimeOfDay _timeStart;
  late TimeOfDay _timeEnd;
  late DateTime _expiresAt;
  late bool _isAvailableNow;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final o = widget.offer;

    _titleCtrl = TextEditingController(text: o['title']?.toString() ?? '');
    _descCtrl = TextEditingController(text: o['description']?.toString() ?? '');
    _maxRedCtrl = TextEditingController(
        text: (o['maxRedemptions'] ?? 100).toString());
    _savingCtrl = TextEditingController(
        text: (o['savingValue'] ?? 0).toString());

    _offerType = o['type']?.toString() ?? '2-for-1';

    // Parse validDays from offer or schedule string
    final rawDays = o['validDays'];
    if (rawDays is List && rawDays.isNotEmpty) {
      _validDays = rawDays.map((e) => e.toString()).toSet();
    } else {
      _validDays = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri'};
    }

    // Parse times
    _timeStart = _parseTime(o['validTimeStart']?.toString()) ??
        const TimeOfDay(hour: 17, minute: 0);
    _timeEnd = _parseTime(o['validTimeEnd']?.toString()) ??
        const TimeOfDay(hour: 19, minute: 0);

    // Parse expiry
    final exp = o['expiresAt']?.toString();
    _expiresAt = exp != null
        ? DateTime.tryParse(exp) ?? DateTime.now().add(const Duration(days: 365))
        : DateTime.now().add(const Duration(days: 365));

    _isAvailableNow = o['isAvailableNow'] as bool? ?? o['isActive'] as bool? ?? true;
  }

  TimeOfDay? _parseTime(String? s) {
    if (s == null) return null;
    final parts = s.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1].split(' ').first);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _timeStart : _timeEnd,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => isStart ? _timeStart = picked : _timeEnd = picked);
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiresAt.isAfter(DateTime.now())
          ? _expiresAt
          : DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _expiresAt = date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_validDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Select at least one valid day'),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    setState(() => _isLoading = true);
    await widget.onSave({
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'type': _offerType,
      'validDays': _validDays.toList(),
      'validTimeStart': _fmt(_timeStart),
      'validTimeEnd': _fmt(_timeEnd),
      'maxRedemptions': int.tryParse(_maxRedCtrl.text) ?? 100,
      'savingValue': int.tryParse(_savingCtrl.text) ?? 0,
      'expiresAt': _expiresAt.toUtc().toIso8601String(),
      'isAvailableNow': _isAvailableNow,
    });
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _maxRedCtrl.dispose();
    _savingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // Handle + header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  const Text('Edit Offer',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const Spacer(),
                  TextButton(
                    onPressed: _isLoading ? null : _save,
                    child: _isLoading
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryColor))
                        : const Text('SAVE',
                            style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1)),
                  ),
                ]),
                const Divider(color: Color(0xFF334155)),
              ]),
            ),

            // Scrollable content
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(
                    16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 32),
                children: [
                  // Details
                  _section('OFFER DETAILS', [
                    _field(_titleCtrl, 'Title *', Icons.title_outlined,
                        validator: (v) =>
                            v?.trim().isEmpty ?? true ? 'Required' : null),
                    const SizedBox(height: 12),
                    _field(_descCtrl, 'Description', Icons.notes_outlined,
                        maxLines: 3),
                  ]),
                  const SizedBox(height: 14),

                  // Offer type
                  _section('OFFER TYPE', [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _offerTypes.map((t) {
                        final sel = _offerType == t.$1;
                        return GestureDetector(
                          onTap: () => setState(() => _offerType = t.$1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel
                                  ? t.$4.withValues(alpha: 0.15)
                                  : const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: sel ? t.$4 : const Color(0xFF334155),
                                  width: sel ? 1.5 : 1),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(t.$3,
                                  color: sel ? t.$4 : const Color(0xFF64748B),
                                  size: 15),
                              const SizedBox(width: 6),
                              Text(t.$2,
                                  style: TextStyle(
                                      color: sel
                                          ? t.$4
                                          : const Color(0xFF94A3B8),
                                      fontSize: 12,
                                      fontWeight: sel
                                          ? FontWeight.w700
                                          : FontWeight.normal)),
                            ]),
                          ),
                        );
                      }).toList(),
                    ),
                  ]),
                  const SizedBox(height: 14),

                  // Valid days
                  _section('VALID DAYS', [
                    Row(
                      children: _allDays.map((day) {
                        final sel = _validDays.contains(day);
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() =>
                                sel ? _validDays.remove(day) : _validDays.add(day)),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              margin: EdgeInsets.only(
                                  right: day != _allDays.last ? 5 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppTheme.primaryColor.withValues(alpha: 0.15)
                                    : const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: sel
                                        ? AppTheme.primaryColor
                                        : const Color(0xFF334155),
                                    width: sel ? 1.5 : 1),
                              ),
                              child: Text(day,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: sel
                                          ? AppTheme.primaryColor
                                          : const Color(0xFF64748B),
                                      fontSize: 10,
                                      fontWeight: sel
                                          ? FontWeight.w800
                                          : FontWeight.normal)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ]),
                  const SizedBox(height: 14),

                  // Time window
                  _section('TIME WINDOW', [
                    Row(children: [
                      Expanded(child: _timeTile('Start', _fmt(_timeStart),
                          () => _pickTime(true))),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.arrow_forward,
                            color: Color(0xFF475569), size: 16),
                      ),
                      Expanded(child: _timeTile('End', _fmt(_timeEnd),
                          () => _pickTime(false))),
                    ]),
                  ]),
                  const SizedBox(height: 14),

                  // Limits & value
                  _section('LIMITS & VALUE', [
                    Row(children: [
                      Expanded(
                        child: _field(
                          _maxRedCtrl, 'Max Redemptions',
                          Icons.confirmation_number_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              int.tryParse(v ?? '') == null ? 'Number required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          _savingCtrl, 'Saving Value (£)',
                          Icons.savings_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              int.tryParse(v ?? '') == null ? 'Number required' : null,
                        ),
                      ),
                    ]),
                  ]),
                  const SizedBox(height: 14),

                  // Expiry & availability
                  _section('EXPIRY & AVAILABILITY', [
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.event_outlined,
                              color: AppTheme.primaryColor, size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Expires At',
                                      style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 11)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_expiresAt.day.toString().padLeft(2, '0')}/'
                                    '${_expiresAt.month.toString().padLeft(2, '0')}/'
                                    '${_expiresAt.year}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ]),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Color(0xFF475569), size: 18),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _isAvailableNow
                                ? AppTheme.primaryColor.withValues(alpha: 0.4)
                                : const Color(0xFF334155)),
                      ),
                      child: Row(children: [
                        Icon(Icons.bolt,
                            color: _isAvailableNow
                                ? AppTheme.primaryColor
                                : const Color(0xFF475569),
                            size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Available Now',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                Text(
                                  _isAvailableNow
                                      ? 'Offer is live and claimable'
                                      : 'Offer is hidden from customers',
                                  style: const TextStyle(
                                      color: Color(0xFF64748B), fontSize: 11),
                                ),
                              ]),
                        ),
                        Switch(
                          value: _isAvailableNow,
                          onChanged: (v) => setState(() => _isAvailableNow = v),
                          activeColor: AppTheme.primaryColor,
                          inactiveThumbColor: const Color(0xFF475569),
                          inactiveTrackColor: const Color(0xFF1E293B),
                        ),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: AppTheme.backgroundDark,
                        disabledBackgroundColor:
                            AppTheme.primaryColor.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.backgroundDark))
                          : const Icon(Icons.check_rounded, size: 20),
                      label: Text(
                        _isLoading ? 'Saving...' : 'Save Changes',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _section(String label, List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5)),
          const SizedBox(height: 12),
          ...children,
        ]),
      );

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 18),
          filled: true,
          fillColor: const Color(0xFF0F172A),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF334155))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        ),
      );

  Widget _timeTile(String label, String value, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 10)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.access_time_outlined,
                  color: AppTheme.primaryColor, size: 14),
              const SizedBox(width: 5),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ]),
          ]),
        ),
      );
}
