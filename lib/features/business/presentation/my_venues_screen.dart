import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'business_provider.dart';

class MyVenuesScreen extends ConsumerWidget {
  const MyVenuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venuesAsync = ref.watch(myVenuesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('My Venues', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
            onPressed: () => ref.read(myVenuesProvider.notifier).load(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.darkBg,
        icon: const Icon(Icons.add),
        label: const Text('Add Venue', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => context.push('/admin/create-venue'),
      ),
      body: venuesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (e, _) => _buildError(context, ref, e.toString()),
        data: (venues) => venues.isEmpty
            ? _buildEmpty(context)
            : RefreshIndicator(
                color: AppTheme.primaryColor,
                backgroundColor: const Color(0xFF1E293B),
                onRefresh: () => ref.read(myVenuesProvider.notifier).load(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: venues.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _VenueCard(venue: venues[i]),
                ),
              ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.store_outlined, color: AppTheme.primaryColor, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('No venues yet', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Create your first venue to get started', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.darkBg,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Create Venue', style: TextStyle(fontWeight: FontWeight.w700)),
              onPressed: () => context.push('/admin/create-venue'),
            ),
          ],
        ),
      );

  Widget _buildError(BuildContext context, WidgetRef ref, String message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(color: Color(0xFF94A3B8)), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: AppTheme.darkBg),
              onPressed: () => ref.read(myVenuesProvider.notifier).load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
}

class _VenueCard extends ConsumerWidget {
  final Map<String, dynamic> venue;
  const _VenueCard({required this.venue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = venue['id']?.toString() ?? '';
    final name = venue['name']?.toString() ?? 'Unnamed Venue';
    final address = venue['address']?.toString() ?? '';
    final category = venue['category']?.toString() ?? '';
    final busynessRaw = venue['busyness'];
    final busyness = busynessRaw is Map
        ? busynessRaw['level']?.toString() ?? ''
        : busynessRaw?.toString() ?? '';
    final vibeRaw = venue['vibe'];
    final vibeTags = vibeRaw is Map ? (vibeRaw['tags'] as List?)?.join(', ') ?? '' : vibeRaw?.toString() ?? '';
    final activeOffers = venue['activeOffersCount'] ?? 0;
    final images = venue['images'] as List?;
    final coverImage = (images != null && images.isNotEmpty)
        ? images.first?.toString()
        : venue['coverImageUrl']?.toString();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image / header
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              color: const Color(0xFF0F172A),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: coverImage != null
                  ? Image.network(
                      coverImage,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Container(
                              color: const Color(0xFF0F172A),
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: AppTheme.primaryColor, strokeWidth: 2),
                              ),
                            ),
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF0F172A),
                        child: Center(
                          child: Icon(Icons.broken_image,
                              color: AppTheme.primaryColor.withOpacity(0.4), size: 40),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(Icons.store,
                          color: AppTheme.primaryColor.withOpacity(0.4), size: 48)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(name,
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                    ),
                    _statusBadge(busyness),
                  ],
                ),
                const SizedBox(height: 6),
                if (address.isNotEmpty)
                  Row(children: [
                    const Icon(Icons.location_on, color: Color(0xFF64748B), size: 13),
                    const SizedBox(width: 4),
                    Expanded(child: Text(address,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        overflow: TextOverflow.ellipsis)),
                  ]),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _chip(category.toUpperCase(), Icons.category),
                    const SizedBox(width: 8),
                    if (vibeTags.isNotEmpty) _chip(vibeTags, Icons.mood),
                    const Spacer(),
                    _chip('$activeOffers offers', Icons.local_offer, color: AppTheme.primaryColor),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: Color(0xFF334155), height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        icon: Icons.dashboard,
                        label: 'Dashboard',
                        onTap: () => context.push('/business-dashboard'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionButton(
                        icon: Icons.edit,
                        label: 'Edit',
                        onTap: () => _showEditSheet(context, ref, id, venue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _actionButton(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      color: const Color(0xFFEF4444),
                      onTap: () => _confirmDelete(context, ref, id, name),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String busyness) {
    Color color;
    switch (busyness.toUpperCase()) {
      case 'BUSY':
      case 'PACKED':
        color = Colors.orange;
        break;
      case 'MODERATE':
      case 'STEADY':
        color = Colors.yellow;
        break;
      default:
        color = Colors.green;
    }
    if (busyness.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(busyness.toUpperCase(),
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
      ]),
    );
  }

  Widget _chip(String label, IconData icon, {Color? color}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (color ?? const Color(0xFF64748B)).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: color ?? const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color ?? const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _actionButton({required IconData icon, required String label, required VoidCallback onTap, Color? color}) {
    final c = color ?? AppTheme.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.withOpacity(0.2)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: c, size: 15),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Venue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to remove "$name"? This cannot be undone.',
            style: const TextStyle(color: Color(0xFF94A3B8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              Navigator.pop(context);
              final ok = await ref.read(myVenuesProvider.notifier).deleteVenue(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'Venue removed' : 'Failed to remove venue'),
                  backgroundColor: ok ? Colors.green[700] : Colors.red[700],
                ));
              }
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, String id, Map<String, dynamic> venue) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditVenueSheet(venueId: id, venue: venue),
    );
  }
}

class _EditVenueSheet extends ConsumerStatefulWidget {
  final String venueId;
  final Map<String, dynamic> venue;
  const _EditVenueSheet({required this.venueId, required this.venue});

  @override
  ConsumerState<_EditVenueSheet> createState() => _EditVenueSheetState();
}

class _EditVenueSheetState extends ConsumerState<_EditVenueSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _areaController;
  late final TextEditingController _openingController;
  late final TextEditingController _closingController;
  late String _category;
  late int _priceLevel;
  bool _isLoading = false;

  static const _categories = [
    'bar', 'club', 'restaurant', 'lounge',
    'live_music_venue', 'pub', 'rooftop_bar', 'cocktail_bar'
  ];

  static const _categoryLabels = {
    'bar': 'Bar', 'club': 'Club', 'restaurant': 'Restaurant',
    'lounge': 'Lounge', 'live_music_venue': 'Live Music Venue',
    'pub': 'Pub', 'rooftop_bar': 'Rooftop Bar', 'cocktail_bar': 'Cocktail Bar',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.venue['name']?.toString() ?? '');
    _addressController = TextEditingController(text: widget.venue['address']?.toString() ?? '');
    _areaController = TextEditingController(text: widget.venue['area']?.toString() ?? '');
    _openingController = TextEditingController(text: widget.venue['openingHours']?.toString() ?? '');
    _closingController = TextEditingController(text: widget.venue['closingTime']?.toString() ?? '');
    _category = widget.venue['category']?.toString().toLowerCase() ?? 'bar';
    if (!_categories.contains(_category)) _category = 'bar';
    _priceLevel = (widget.venue['priceLevel'] as num?)?.toInt() ?? 2;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _openingController.dispose();
    _closingController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    final ok = await ref.read(myVenuesProvider.notifier).updateVenue(widget.venueId, {
      'name': _nameController.text.trim(),
      'address': _addressController.text.trim(),
      'area': _areaController.text.trim(),
      'category': _category,
      'priceLevel': _priceLevel,
      'openingHours': _openingController.text.trim(),
      'closingTime': _closingController.text.trim(),
    });
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Venue updated!' : 'Failed to update venue'),
        backgroundColor: ok ? Colors.green[700] : Colors.red[700],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text('Edit Venue', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  TextButton(onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B)))),
                ],
              ),
            ),
            const Divider(color: Color(0xFF334155)),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  _field(_nameController, 'Venue Name', Icons.store),
                  const SizedBox(height: 14),
                  _field(_addressController, 'Address', Icons.location_on),
                  const SizedBox(height: 14),
                  _field(_areaController, 'Area', Icons.map_outlined),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: _field(_openingController, 'Opening Time', Icons.access_time)),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_closingController, 'Closing Time', Icons.access_time_filled)),
                  ]),
                  const SizedBox(height: 16),
                  _label('CATEGORY'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _category,
                        dropdownColor: const Color(0xFF1E293B),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white),
                        items: _categories.map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(_categoryLabels[c] ?? c, style: const TextStyle(color: Colors.white)),
                        )).toList(),
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('PRICE LEVEL'),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(4, (i) {
                      final level = i + 1;
                      final selected = _priceLevel == level;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _priceLevel = level),
                          child: Container(
                            margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.primaryColor : const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: selected ? AppTheme.primaryColor : const Color(0xFF334155)),
                            ),
                            child: Text('£' * level,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: selected ? AppTheme.darkBg : const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w800,
                                )),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: AppTheme.darkBg,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.darkBg))
                          : const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
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

  Widget _label(String text) => Text(text,
      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5));

  Widget _field(TextEditingController controller, String hint, IconData icon) => TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF64748B)),
          prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
          filled: true,
          fillColor: const Color(0xFF0F172A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}
