import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'business_provider.dart';

class BusinessVenueDetailScreen extends ConsumerStatefulWidget {
  final String venueId;
  final String venueName;
  final String venueAddress;

  const BusinessVenueDetailScreen({
    super.key,
    required this.venueId,
    required this.venueName,
    required this.venueAddress,
  });

  @override
  ConsumerState<BusinessVenueDetailScreen> createState() =>
      _BusinessVenueDetailScreenState();
}

class _BusinessVenueDetailScreenState
    extends ConsumerState<BusinessVenueDetailScreen> {
  // Edit form controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _openingCtrl;
  late final TextEditingController _closingCtrl;
  late String _category;
  late int _priceLevel;

  bool _editMode = false;
  bool _saving = false;

  static const _categories = [
    'bar', 'club', 'restaurant', 'lounge',
    'live_music_venue', 'pub', 'rooftop_bar', 'cocktail_bar',
  ];
  static const _categoryLabels = {
    'bar': 'Bar', 'club': 'Club', 'restaurant': 'Restaurant',
    'lounge': 'Lounge', 'live_music_venue': 'Live Music Venue',
    'pub': 'Pub', 'rooftop_bar': 'Rooftop Bar', 'cocktail_bar': 'Cocktail Bar',
  };

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.venueName);
    _addressCtrl = TextEditingController(text: widget.venueAddress);
    _areaCtrl = TextEditingController();
    _openingCtrl = TextEditingController();
    _closingCtrl = TextEditingController();
    _category = 'bar';
    _priceLevel = 2;
    Future.microtask(_loadVenueDetails);
  }

  void _loadVenueDetails() {
    // Pull full venue data from myVenuesProvider if already loaded
    final venues = ref.read(myVenuesProvider).valueOrNull ?? [];
    final match = venues.where((v) => v['id'] == widget.venueId);
    if (match.isNotEmpty) _applyVenue(match.first);
  }

  void _applyVenue(Map<String, dynamic> v) {
    final cat = v['category']?.toString().toLowerCase() ?? 'bar';
    setState(() {
      _nameCtrl.text = v['name']?.toString() ?? widget.venueName;
      _addressCtrl.text = v['address']?.toString() ?? widget.venueAddress;
      _areaCtrl.text = v['area']?.toString() ?? '';
      _openingCtrl.text = v['openingHours']?.toString() ?? '';
      _closingCtrl.text = v['closingTime']?.toString() ?? '';
      _category = _categories.contains(cat) ? cat : 'bar';
      _priceLevel = (v['priceLevel'] as num?)?.toInt() ?? 2;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _areaCtrl.dispose();
    _openingCtrl.dispose();
    _closingCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final ok = await ref.read(myVenuesProvider.notifier).updateVenue(
      widget.venueId,
      {
        'name': _nameCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'area': _areaCtrl.text.trim(),
        'category': _category,
        'priceLevel': _priceLevel,
        'openingHours': _openingCtrl.text.trim(),
        'closingTime': _closingCtrl.text.trim(),
      },
    );
    if (!mounted) return;
    setState(() { _saving = false; if (ok) _editMode = false; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Venue updated successfully' : 'Failed to update venue'),
      backgroundColor: ok ? const Color(0xFF10B981) : Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Keep form in sync if venues reload
    ref.listen(myVenuesProvider, (_, next) {
      next.whenData((venues) {
        final match = venues.where((v) => v['id'] == widget.venueId);
        if (match.isNotEmpty && !_editMode) _applyVenue(match.first);
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _editMode ? 'Edit Venue' : 'Venue Details',
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (!_editMode) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
              tooltip: 'Edit',
              onPressed: () => setState(() => _editMode = true),
            ),
            IconButton(
              icon: const Icon(Icons.dashboard_outlined, color: AppTheme.primaryColor),
              tooltip: 'Dashboard',
              onPressed: () => context.push('/business-dashboard'),
            ),
          ] else ...[
            TextButton(
              onPressed: () => setState(() => _editMode = false),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF64748B))),
            ),
            TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.primaryColor))
                  : const Text('Save',
                      style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
      body: _editMode ? _buildEditForm() : _buildViewMode(),
    );
  }

  // ── View mode ──────────────────────────────────────────────────────────────

  Widget _buildViewMode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.store_outlined,
                          color: AppTheme.primaryColor, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_nameCtrl.text,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 3),
                          Row(children: [
                            const Icon(Icons.location_on_outlined,
                                color: Color(0xFF64748B), size: 13),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(_addressCtrl.text,
                                  style: const TextStyle(
                                      color: Color(0xFF64748B), fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_areaCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Divider(color: Color(0xFF334155), height: 1),
                  const SizedBox(height: 14),
                  _infoRow(Icons.map_outlined, 'Area', _areaCtrl.text),
                ],
                if (_category.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _infoRow(Icons.category_outlined, 'Category',
                      _categoryLabels[_category] ?? _category),
                ],
                if (_openingCtrl.text.isNotEmpty ||
                    _closingCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _infoRow(Icons.access_time_outlined, 'Hours',
                      '${_openingCtrl.text} – ${_closingCtrl.text}'),
                ],
                if (_priceLevel > 0) ...[
                  const SizedBox(height: 10),
                  _infoRow(Icons.attach_money, 'Price Level',
                      '£' * _priceLevel),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick actions
          _sectionLabel('Quick Actions'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _actionCard(
                  icon: Icons.sensors,
                  label: 'Live Status',
                  color: const Color(0xFF22C55E),
                  onTap: () => context.push(
                    '/venue-status/${widget.venueId}?name=${Uri.encodeComponent(widget.venueName)}',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionCard(
                  icon: Icons.local_offer_outlined,
                  label: 'Manage Offers',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => context.push('/manage-offers'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _actionCard(
                  icon: Icons.bar_chart_outlined,
                  label: 'Analytics',
                  color: const Color(0xFF3B82F6),
                  onTap: () => context.push(
                    '/venue-analytics/${widget.venueId}?name=${Uri.encodeComponent(widget.venueName)}',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionCard(
                  icon: Icons.add_circle_outline,
                  label: 'Create Offer',
                  color: AppTheme.primaryColor,
                  onTap: () => context.push(
                      '/create-offer?venueId=${widget.venueId}'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Danger zone
          _sectionLabel('Danger Zone'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: ListTile(
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
              ),
              title: const Text('Remove Venue',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              subtitle: const Text('Permanently remove this venue',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.red, size: 20),
              onTap: () => _confirmDelete(context),
            ),
          ),
        ],
      ),
    );
  }

  // ── Edit mode ──────────────────────────────────────────────────────────────

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('BASIC INFO'),
          const SizedBox(height: 12),
          _field(_nameCtrl, 'Venue Name *', Icons.store_outlined),
          const SizedBox(height: 14),
          _field(_addressCtrl, 'Address', Icons.location_on_outlined),
          const SizedBox(height: 14),
          _field(_areaCtrl, 'Area / Neighbourhood', Icons.map_outlined),
          const SizedBox(height: 24),

          _sectionLabel('HOURS'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _field(_openingCtrl, 'Opening Time', Icons.access_time)),
            const SizedBox(width: 12),
            Expanded(
                child: _field(
                    _closingCtrl, 'Closing Time', Icons.access_time_filled)),
          ]),
          const SizedBox(height: 24),

          _sectionLabel('CATEGORY'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _category,
                dropdownColor: const Color(0xFF1E293B),
                isExpanded: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: _categories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(_categoryLabels[c] ?? c,
                              style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _sectionLabel('PRICE LEVEL'),
          const SizedBox(height: 12),
          Row(
            children: List.generate(4, (i) {
              final level = i + 1;
              final selected = _priceLevel == level;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _priceLevel = level),
                  child: Container(
                    margin: EdgeInsets.only(right: i < 3 ? 10 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primaryColor
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: selected
                              ? AppTheme.primaryColor
                              : const Color(0xFF334155)),
                    ),
                    child: Text(
                      '£' * level,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected ? AppTheme.darkBg : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 36),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.darkBg,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.darkBg))
                  : const Text('Save Changes',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Venue',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
            'Are you sure you want to remove "${_nameCtrl.text}"? This cannot be undone.',
            style: const TextStyle(color: Color(0xFF94A3B8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              Navigator.pop(context);
              final ok = await ref
                  .read(myVenuesProvider.notifier)
                  .deleteVenue(widget.venueId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok
                      ? 'Venue removed'
                      : 'Failed to remove venue'),
                  backgroundColor: ok ? Colors.green[700] : Colors.red[700],
                ));
                if (ok) context.pop();
              }
            },
            child: const Text('Remove',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(label,
      style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5));

  Widget _infoRow(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 16),
          const SizedBox(width: 10),
          Text('$label: ',
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      );

  Widget _actionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
            Icon(Icons.chevron_right, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController controller, String hint, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 18),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
      ),
    );
  }
}
