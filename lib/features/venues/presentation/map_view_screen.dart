import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/venue_management_provider.dart';
import '../data/location_provider.dart';
import '../../../core/config/env.dart';

// RAG colour constants — strict spec from client brief
const _ragGreen = Color(0xFF22C55E);  // QUIET
const _ragAmber = Color(0xFFF59E0B);  // MODERATE
const _ragRed   = Color(0xFFEF4444);  // BUSY

Color _ragColor(String busyness) {
  switch (busyness.toUpperCase()) {
    case 'QUIET':    return _ragGreen;
    case 'MODERATE': return _ragAmber;
    case 'BUSY':     return _ragRed;
    default:         return const Color(0xFF94A3B8);
  }
}

class MapViewScreen extends ConsumerStatefulWidget {
  final String? venueId;
  const MapViewScreen({super.key, this.venueId});

  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  String _selectedCategory = 'ALL';
  String? _selectedVenueId;
  double _scale = 8000.0;

  @override
  void initState() {
    super.initState();
    _selectedVenueId = widget.venueId;
    Future.microtask(() {
      ref.read(venueManagementProvider.notifier).loadVenues();
      ref.read(locationProvider.notifier).startTracking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(venueManagementProvider);
    final locState = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // Map background
            GestureDetector(
              onScaleUpdate: (d) => setState(
                  () => _scale = (_scale * d.scale).clamp(4000.0, 16000.0)),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF334155),
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuADhzm8lWPGb7TipwGJX4Ls1SLwHuj6L8RtO3u72yLx2v9vV38ulG_1454dOG8lUuYxKNdgEBz0RiCq0Zqb_rEC-wyBzFs1HsnrM7V8BQh__9ZBQbg-IgkUPB-qKhXwSkgjlYSp20fSAvJYjoLs4ORpNf8wKExp4GuxT0lz-PStkyKnVoYU0sxgw4paMzbViNDwUjLjdc_P2WiEz_AKXwAKryxZw28TqR1GhQMGVxRvCA5WXwW_k4neVoeq8cHuYi_fmYAjywTOGxQF'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Top gradient
            Container(
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F172A), Colors.transparent],
                ),
              ),
            ),

            // Bottom gradient
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 256,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFF0F172A), Colors.transparent],
                  ),
                ),
              ),
            ),

            // Venue pins with RAG colours
            ...venuesAsync.maybeWhen(
              data: (venues) {
                final filtered = widget.venueId != null
                    ? venues.where((v) => v.id == widget.venueId).toList()
                    : _selectedCategory == 'ALL'
                        ? venues
                        : venues
                            .where((v) =>
                                v.type.toUpperCase() == _selectedCategory)
                            .toList();

                return filtered.map((venue) {
                  const centerLat = 53.4808;
                  const centerLng = -2.2426;
                  final size = MediaQuery.of(context).size;
                  final x = size.width / 2 +
                      (venue.longitude - centerLng) * _scale;
                  final y = size.height / 2 -
                      (venue.latitude - centerLat) * _scale;
                  final isSelected = _selectedVenueId == venue.id;

                  return Positioned(
                    top: y,
                    left: x,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedVenueId = venue.id),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              if (isSelected)
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _ragColor(venue.busyness)
                                        .withOpacity(0.25),
                                  ),
                                ),
                              Container(
                                width: isSelected ? 34 : 26,
                                height: isSelected ? 34 : 26,
                                decoration: BoxDecoration(
                                  // RAG colour = busyness level
                                  color: _ragColor(venue.busyness),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white,
                                      width: isSelected ? 3 : 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _ragColor(venue.busyness)
                                          .withOpacity(0.6),
                                      blurRadius: isSelected ? 20 : 10,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _venueIcon(venue.type),
                                  color: Colors.white,
                                  size: isSelected ? 16 : 12,
                                ),
                              ),
                            ],
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Text(
                                venue.name,
                                style: const TextStyle(
                                    color: Color(0xFFCFFAFE),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList();
              },
              orElse: () => [],
            ),

            // Top UI: back + search + filters
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _circleButton(
                            Icons.arrow_back, () => context.pop()),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 16),
                                Icon(Icons.search,
                                    color: Color(0xFF94A3B8), size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Find vibes in MCR...',
                                      hintStyle: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 14),
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _circleButton(Icons.tune, () {}),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Category filter tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterTab('All', Icons.grid_view, 'ALL'),
                          const SizedBox(width: 8),
                          _filterTab('Bars', Icons.local_bar, 'BAR'),
                          const SizedBox(width: 8),
                          _filterTab('Clubs', Icons.music_note, 'CLUB'),
                          const SizedBox(width: 8),
                          _filterTab('Restaurants', Icons.restaurant,
                              'RESTAURANT'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // RAG legend (Week 8 client requirement)
            Positioned(
              top: 160,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.92),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ragLegendRow(_ragGreen, 'Quiet'),
                    const SizedBox(height: 6),
                    _ragLegendRow(_ragAmber, 'Moderate'),
                    const SizedBox(height: 6),
                    _ragLegendRow(_ragRed, 'Busy'),
                  ],
                ),
              ),
            ),

            // Bottom: GPS button + selected venue card
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // GPS / Near Me button
                  Padding(
                    padding: const EdgeInsets.only(right: 16, bottom: 12),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () =>
                            ref.read(locationProvider.notifier).startTracking(),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withOpacity(0.85),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                locState.isTracking
                                    ? Icons.my_location
                                    : Icons.location_disabled,
                                color: locState.isTracking
                                    ? const Color(0xFF2DD4BF)
                                    : const Color(0xFF94A3B8),
                                size: 22,
                              ),
                              if (locState.nearbyVenues.isNotEmpty)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2DD4BF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${locState.nearbyVenues.length}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Selected venue card
                  if (_selectedVenueId != null)
                    venuesAsync.maybeWhen(
                      data: (venues) {
                        final matches =
                            venues.where((v) => v.id == _selectedVenueId);
                        if (matches.isEmpty) return const SizedBox.shrink();
                        final venue = matches.first;
                        return GestureDetector(
                          onTap: () =>
                              context.push('/venue-detail?id=${venue.id}'),
                          child: Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF1E293B).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    venue.coverImageUrl != null
                                        ? '${Env.apiBaseUrl}${venue.coverImageUrl}'
                                        : 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=200',
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 72,
                                      height: 72,
                                      color: const Color(0xFF334155),
                                      child: const Icon(Icons.image,
                                          color: Color(0xFF64748B)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(venue.name,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: _ragColor(venue.busyness),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            venue.busyness,
                                            style: TextStyle(
                                              color: _ragColor(venue.busyness),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(venue.address,
                                          style: const TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 11),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios,
                                    color: Color(0xFF94A3B8), size: 14),
                              ],
                            ),
                          ),
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.85),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );

  Widget _filterTab(String label, IconData icon, String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2DD4BF)
              : const Color(0xFF1E293B).withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          border: isSelected
              ? null
              : Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFCFFAFE),
                size: 15),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFCFFAFE),
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _ragLegendRow(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      );

  IconData _venueIcon(String type) {
    switch (type.toUpperCase()) {
      case 'BAR':        return Icons.local_bar;
      case 'RESTAURANT': return Icons.restaurant;
      case 'CLUB':       return Icons.music_note;
      case 'CASINO':     return Icons.casino;
      default:           return Icons.location_on;
    }
  }
}
