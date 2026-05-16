import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'business_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/services/auth_service.dart';

class ManageOffersScreen extends ConsumerStatefulWidget {
  const ManageOffersScreen({super.key});
  
  @override
  ConsumerState<ManageOffersScreen> createState() => _ManageOffersScreenState();
}

class _ManageOffersScreenState extends ConsumerState<ManageOffersScreen> {
  String _filter = 'all'; // all | active | inactive

  String? get _venueId => AuthService().currentUser?.venueId;

  @override
  Widget build(BuildContext context) {
    if (_venueId == null || _venueId!.isEmpty) {
      return _buildNoVenue();
    }
    return _buildContent();
  }

  Widget _buildNoVenue() => Scaffold(
    backgroundColor: AppTheme.backgroundDark,
    appBar: AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
      title: const Text('Manage Offers', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
    ),
    body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.store_outlined, color: Colors.white.withOpacity(0.3), size: 64),
        const SizedBox(height: 16),
        const Text('No venue found', style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => context.push('/admin/create-venue'),
          child: const Text('Create Venue', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
        ),
      ]),
    ),
  );

  Widget _buildContent() {
    final venueId = _venueId!;
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
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor, size: 28),
            onPressed: () => context.push('/create-offer?venueId=$venueId'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(children: [
              _filterChip('All', 'all'),
              const SizedBox(width: 8),
              _filterChip('Active', 'active'),
              const SizedBox(width: 8),
              _filterChip('Inactive', 'inactive'),
            ]),
          ),
          
          // Offers list
          Expanded(
            child: offersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
              error: (e, _) => Center(child: Text(ErrorHandler.getErrorMessage(e), style: const TextStyle(color: Colors.white))),
              data: (offers) {
                final filtered = _filterOffers(offers);
                if (filtered.isEmpty) {
                  return _buildEmpty();
                }
                return RefreshIndicator(
                  color: AppTheme.primaryColor,
                  backgroundColor: AppTheme.surface,
                  onRefresh: () async => ref.read(businessVenueOffersProvider(venueId).notifier).load(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) => _OfferCard(
                      offer: filtered[i],
                      onToggle: () => _toggleOffer(filtered[i]['id'] as String, venueId),
                      onEdit: () => _editOffer(filtered[i], venueId),
                      onDelete: () => _deleteOffer(filtered[i]['id'] as String, filtered[i]['title'] as String, venueId),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterOffers(List<Map<String, dynamic>> offers) {
    if (_filter == 'all') return offers;
    final isActive = _filter == 'active';
    return offers.where((o) => (o['isActive'] ?? false) == isActive).toList();
  }

  Widget _filterChip(String label, String value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor.withOpacity(0.15) : AppTheme.backgroundDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.primaryColor : const Color(0xFF334155)),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? AppTheme.primaryColor : const Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            )),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.local_offer_outlined, color: Colors.white.withOpacity(0.3), size: 64),
      const SizedBox(height: 16),
      Text(
        _filter == 'all' ? 'No offers yet' : 'No $_filter offers',
        style: const TextStyle(color: Colors.white70, fontSize: 16),
      ),
      const SizedBox(height: 8),
      TextButton.icon(
        onPressed: () => context.push('/create-offer?venueId=${_venueId ?? ""}'),
        icon: const Icon(Icons.add, color: AppTheme.primaryColor),
        label: const Text('Create Offer', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
      ),
    ]),
  );

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _toggleOffer(String id, String venueId) async {
    final success = await ref.read(businessVenueOffersProvider(venueId).notifier).toggleOffer(id);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Failed to toggle offer'),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Future<void> _editOffer(Map<String, dynamic> offer, String venueId) async {
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditOfferSheet(offer: offer),
    );
    if (result != null) {
      final success = await ref.read(businessVenueOffersProvider(venueId).notifier)
          .updateOffer(offer['id'] as String, result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? 'Offer updated successfully' : 'Failed to update offer'),
          backgroundColor: success ? const Color(0xFF10B981) : Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  Future<void> _deleteOffer(String id, String title, String venueId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Offer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete "$title"? This action cannot be undone.',
            style: const TextStyle(color: Color(0xFF94A3B8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ref.read(businessVenueOffersProvider(venueId).notifier).deleteOffer(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? 'Offer deleted successfully' : 'Failed to delete offer'),
          backgroundColor: success ? const Color(0xFF10B981) : Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }
}

// ── Offer Card ───────────────────────────────────────────────────────────────

class _OfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OfferCard({
    required this.offer,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = offer['isActive'] ?? false;
    final title = offer['title']?.toString() ?? 'Untitled';
    final desc = offer['description']?.toString() ?? '';
    final type = offer['type']?.toString() ?? 'discount';
    final saving = offer['savingValue'] ?? 0;
    final days = (offer['validDays'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final timeStart = offer['validTimeStart']?.toString() ?? '';
    final timeEnd = offer['validTimeEnd']?.toString() ?? '';

    final typeColor = _getTypeColor(type);
    final typeIcon = _getTypeIcon(type);

    return Dismissible(
      key: Key(offer['id'].toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false; // Don't auto-dismiss, let delete handler manage it
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[700],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppTheme.primaryColor.withOpacity(0.3) : const Color(0xFF334155).withOpacity(0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeIcon, color: typeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(desc,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (saving > 0)
                  Text('£$saving',
                      style: TextStyle(color: typeColor, fontSize: 18, fontWeight: FontWeight.w900)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF10B981).withOpacity(0.15)
                        : const Color(0xFF475569).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF10B981) : const Color(0xFF475569),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isActive ? 'LIVE' : 'OFF',
                      style: TextStyle(
                        color: isActive ? const Color(0xFF10B981) : const Color(0xFF64748B),
                        fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5,
                      ),
                    ),
                  ]),
                ),
              ]),
            ]),
            const SizedBox(height: 14),
            const Divider(color: Color(0xFF334155), height: 1),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.access_time_outlined, color: Color(0xFF64748B), size: 14),
              const SizedBox(width: 6),
              Text('$timeStart – $timeEnd',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              const SizedBox(width: 16),
              const Icon(Icons.calendar_today_outlined, color: Color(0xFF64748B), size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(days.isEmpty ? 'No days' : days.join(' · '),
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onToggle,
                  icon: Icon(isActive ? Icons.pause : Icons.play_arrow, size: 16),
                  label: Text(isActive ? 'Pause' : 'Activate',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? const Color(0xFF475569) : AppTheme.primaryColor,
                    foregroundColor: isActive ? Colors.white : AppTheme.backgroundDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case '2-for-1':     return const Color(0xFF8B5CF6);
      case 'discount':    return const Color(0xFF3B82F6);
      case 'freebie':     return const Color(0xFF10B981);
      case 'guestlist':   return const Color(0xFFF59E0B);
      case 'happy-hour':  return const Color(0xFFEF4444);
      default:            return const Color(0xFF64748B);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case '2-for-1':     return Icons.local_bar;
      case 'discount':    return Icons.percent;
      case 'freebie':     return Icons.card_giftcard;
      case 'guestlist':   return Icons.star;
      case 'happy-hour':  return Icons.access_time;
      default:            return Icons.local_offer;
    }
  }
}

// ── Edit Offer Sheet ─────────────────────────────────────────────────────────

class _EditOfferSheet extends StatefulWidget {
  final Map<String, dynamic> offer;
  const _EditOfferSheet({required this.offer});

  @override
  State<_EditOfferSheet> createState() => _EditOfferSheetState();
}

class _EditOfferSheetState extends State<_EditOfferSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _savingCtrl;
  late bool _isAvailableNow;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.offer['title']?.toString() ?? '');
    _descCtrl = TextEditingController(text: widget.offer['description']?.toString() ?? '');
    _savingCtrl = TextEditingController(text: (widget.offer['savingValue'] ?? 0).toString());
    _isAvailableNow = widget.offer['isAvailableNow'] ?? widget.offer['isActive'] ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _savingCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Title is required'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    Navigator.pop(context, {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'savingValue': int.tryParse(_savingCtrl.text) ?? 0,
      'isAvailableNow': _isAvailableNow,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Edit Offer',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: _dec('Title *', Icons.title_outlined),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descCtrl,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: _dec('Description', Icons.notes_outlined),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _savingCtrl,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: _dec('Saving Value (£)', Icons.savings_outlined),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isAvailableNow
                    ? AppTheme.primaryColor.withOpacity(0.4)
                    : const Color(0xFF334155),
              ),
            ),
            child: Row(children: [
              Icon(Icons.bolt,
                  color: _isAvailableNow ? AppTheme.primaryColor : const Color(0xFF475569),
                  size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Available Now',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              Switch(
                value: _isAvailableNow,
                onChanged: (v) => setState(() => _isAvailableNow = v),
                activeColor: AppTheme.primaryColor,
              ),
            ]),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.backgroundDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
    prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
    filled: true,
    fillColor: AppTheme.backgroundDark,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155))),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
  );
}
