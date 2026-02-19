import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/venue_management_provider.dart';
import '../../../core/config/env.dart';

class MapViewScreen extends ConsumerStatefulWidget {
  const MapViewScreen({super.key});
  
  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  int _selectedTab = 0;
  String? _selectedVenueId;
  double _scale = 8000.0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(venueManagementProvider.notifier).loadVenues());
  }

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(venueManagementProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Map Background with exact styling
            GestureDetector(
              onScaleUpdate: (details) {
                setState(() {
                  _scale = (_scale * details.scale).clamp(4000.0, 16000.0);
                });
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF334155),
                  image: DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuADhzm8lWPGb7TipwGJX4Ls1SLwHuj6L8RtO3u72yLx2v9vV38ulG_1454dOG8lUuYxKNdgEBz0RiCq0Zqb_rEC-wyBzFs1HsnrM7V8BQh__9ZBQbg-IgkUPB-qKhXwSkgjlYSp20fSAvJYjoLs4ORpNf8wKExp4GuxT0lz-PStkyKnVoYU0sxgw4paMzbViNDwUjLjdc_P2WiEz_AKXwAKryxZw28TqR1GhQMGVxRvCA5WXwW_k4neVoeq8cHuYi_fmYAjywTOGxQF'),
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
              bottom: 0,
              left: 0,
              right: 0,
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
            // Map Pins - Real venues with actual coordinates
            ...venuesAsync.maybeWhen(
              data: (venues) => venues.map((venue) {
                final isSelected = _selectedVenueId == venue.id;
                // Convert lat/lng to screen coordinates
                const centerLat = 53.4808;
                const centerLng = -2.2426;
                final screenWidth = MediaQuery.of(context).size.width;
                final screenHeight = MediaQuery.of(context).size.height;
                
                final x = screenWidth / 2 + (venue.longitude - centerLng) * _scale;
                final y = screenHeight / 2 - (venue.latitude - centerLat) * _scale;
                
                return _buildVenuePin(
                  venue: venue,
                  top: y,
                  left: x,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedVenueId = venue.id),
                );
              }).toList(),
              orElse: () => [],
            ),
            // Top Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar and Filter Button
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withOpacity(0.85),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            onPressed: () => context.pop(),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 16),
                                Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Find vibes in MCR...',
                                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withOpacity(0.85),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Icon(Icons.tune, color: Color(0xFFCFFAFE), size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Filter Tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterTab('Trending', Icons.local_fire_department, 0, true),
                          const SizedBox(width: 8),
                          _buildFilterTab('Nightlife', Icons.nightlife, 1, false),
                          const SizedBox(width: 8),
                          _buildFilterTab('Food', Icons.restaurant, 2, false),
                          const SizedBox(width: 8),
                          _buildFilterTab('Live Music', Icons.music_note, 3, false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Content
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withOpacity(0.85),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Icon(Icons.my_location, color: Color(0xFF2DD4BF), size: 20),
                        ),
                      ],
                    ),
                  ),
                  // Venue Card - Real data
                  if (_selectedVenueId != null)
                    venuesAsync.maybeWhen(
                      data: (venues) {
                        final venue = venues.firstWhere((v) => v.id == _selectedVenueId);
                        return GestureDetector(
                          onTap: () => context.push('/venue-detail?id=${venue.id}'),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        venue.coverImageUrl != null ? '${Env.apiBaseUrl}${venue.coverImageUrl}' : 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=200',
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 96,
                                          height: 96,
                                          color: const Color(0xFF334155),
                                          child: const Icon(Icons.image, color: Color(0xFF64748B)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            venue.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                _getBusynessIcon(venue.busyness),
                                                color: const Color(0xFF2DD4BF),
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                venue.busyness,
                                                style: const TextStyle(
                                                  color: Color(0xFF2DD4BF),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            venue.address,
                                            style: const TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              _buildTag(venue.type),
                                              const SizedBox(width: 6),
                                              _buildTag(venue.currentVibe),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2DD4BF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () => context.push('/venue-detail?id=${venue.id}'),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'View Details',
                                            style: TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward, color: Color(0xFF0F172A), size: 18),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
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

  Widget _buildVenuePin({
    required venue,
    required double top,
    required double left,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (isSelected)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2DD4BF).withOpacity(0.3),
                    ),
                  ),
                Container(
                  width: isSelected ? 32 : 24,
                  height: isSelected ? 32 : 24,
                  decoration: BoxDecoration(
                    color: _getVenueTypeColor(venue.type),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
                    boxShadow: [
                      BoxShadow(
                        color: _getVenueTypeColor(venue.type).withOpacity(0.5),
                        blurRadius: isSelected ? 20 : 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    _getVenueTypeIcon(venue.type),
                    color: Colors.white,
                    size: isSelected ? 16 : 12,
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  venue.name,
                  style: const TextStyle(
                    color: Color(0xFFCFFAFE),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBusynessColor(String busyness) {
    switch (busyness.toUpperCase()) {
      case 'QUIET': return Colors.green;
      case 'MODERATE': return Colors.orange;
      case 'BUSY': return Colors.red;
      default: return const Color(0xFF2DD4BF);
    }
  }

  Color _getVenueTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'BAR': return const Color(0xFFFF6B6B);
      case 'RESTAURANT': return const Color(0xFF4ECDC4);
      case 'CLUB': return const Color(0xFFFFBE0B);
      case 'CASINO': return const Color(0xFF9B59B6);
      default: return const Color(0xFF2DD4BF);
    }
  }

  IconData _getBusynessIcon(String busyness) {
    switch (busyness.toUpperCase()) {
      case 'QUIET': return Icons.check_circle;
      case 'MODERATE': return Icons.people;
      case 'BUSY': return Icons.local_fire_department;
      default: return Icons.location_on;
    }
  }

  IconData _getVenueTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'BAR': return Icons.local_bar;
      case 'RESTAURANT': return Icons.restaurant;
      case 'CLUB': return Icons.music_note;
      case 'CASINO': return Icons.casino;
      default: return Icons.location_on;
    }
  }

  Widget _buildFilterTab(String label, IconData icon, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2DD4BF) : const Color(0xFF1E293B).withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF2DD4BF).withOpacity(0.3),
              blurRadius: 10,
            ),
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCFFAFE),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCFFAFE),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFCFFAFE).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCFFAFE).withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFCFFAFE),
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (label == 'Feed') {
          context.go('/home');
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF2DD4BF).withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFF2DD4BF) : const Color(0xFF94A3B8),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}