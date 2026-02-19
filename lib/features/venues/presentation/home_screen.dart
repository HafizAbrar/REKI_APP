import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/venue_management_provider.dart';
import '../../../core/config/env.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;
  int _selectedNavIndex = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(venueManagementProvider.notifier).loadVenues());
  }

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(venueManagementProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, left: 16, right: 16, bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.75),
                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08), width: 1)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF2DD4BF).withOpacity(0.5), width: 2),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  'https://i.pravatar.cc/150?img=1',
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 40,
                                    height: 40,
                                    color: const Color(0xFF2DD4BF),
                                    child: const Icon(Icons.person, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2DD4BF),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF0F172A), width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LOCATION',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Manchester, UK',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Icon(Icons.expand_more, color: Colors.white, size: 18),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildHeaderButton(Icons.search, onTap: _showSearchDialog),
                        const SizedBox(width: 8),
                        _buildHeaderButton(Icons.tune),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Filter Tabs
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildTab('All', Icons.grid_view, 0),
                                const SizedBox(width: 8),
                                _buildTab('Bar', Icons.local_bar, 1),
                                const SizedBox(width: 8),
                                _buildTab('Restaurant', Icons.restaurant, 2),
                                const SizedBox(width: 8),
                                _buildTab('Club', Icons.music_note, 3),
                                const SizedBox(width: 8),
                                _buildTab('Casino', Icons.casino, 4),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: venuesAsync.when(
                  data: (venues) {
                    var filteredVenues = _selectedTab == 0 
                      ? venues 
                      : venues.where((v) {
                          final category = v.type.toUpperCase();
                          if (_selectedTab == 1) return category == 'BAR';
                          if (_selectedTab == 2) return category == 'RESTAURANT';
                          if (_selectedTab == 3) return category == 'CLUB';
                          if (_selectedTab == 4) return category == 'CASINO';
                          return true;
                        }).toList();
                    
                    if (_searchQuery.isNotEmpty) {
                      filteredVenues = filteredVenues.where((v) => 
                        v.name.toLowerCase().contains(_searchQuery) ||
                        v.type.toLowerCase().contains(_searchQuery)
                      ).toList();
                    }
                    
                    return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ...filteredVenues.map((venue) => Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _buildVenueCard(
                            venue: venue,
                            isBookmarked: false,
                          ),
                        )),
                        const SizedBox(height: 32),
                        Container(
                          height: 4,
                          width: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text('Error: $error', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          // Bottom Navigation
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.75),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(Icons.home, 0),
                    _buildNavItem(Icons.map, 1),
                    _buildNavItem(Icons.local_activity, 2),
                    _buildNavItem(Icons.person, 3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, {VoidCallback? onTap}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap ?? () {
            if (icon == Icons.tune) {
              context.push('/filters');
            }
          },
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Search Venues', style: TextStyle(color: Colors.white)),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search by name or category',
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value.toLowerCase());
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF2DD4BF))),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, IconData icon, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2DD4BF) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF2DD4BF).withOpacity(0.25),
              blurRadius: 16,
            ),
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueCard({
    required venue,
    required bool isBookmarked,
  }) {
    final name = venue.name;
    final subtitle = '${venue.type} • ${venue.address}';
    final statusLabel = venue.busyness;
    final vibeLabel = venue.currentVibe;
    final offerDescription = venue.offers.isNotEmpty ? venue.offers.first.description : null;
    
    Color statusColor = Colors.green;
    if (statusLabel == 'Busy') statusColor = Colors.orange;
    if (statusLabel == 'Packed') statusColor = Colors.red;
    
    IconData? statusIcon;
    IconData? vibeIcon;
    String? waitTime;
    String? vibeScore;
    String? noiseLevel;
    List<String>? vibeTags;
    Color? offerColor;
    IconData? offerIcon;
    String? offerTitle;
    
    return GestureDetector(
      onTap: () => context.push('/venue-detail?id=${venue.id}'),
      child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image Section
          Stack(
            children: [
              Container(
                height: 280,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: venue.coverImageUrl != null
                    ? Image.network(
                        '${Env.apiBaseUrl}${venue.coverImageUrl}',
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 280,
                            color: const Color(0xFF334155),
                            child: const Center(
                              child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 280,
                          color: const Color(0xFF334155),
                          child: const Center(
                            child: Icon(Icons.image, size: 60, color: Color(0xFF64748B)),
                          ),
                        ),
                      )
                    : Container(
                        height: 280,
                        color: const Color(0xFF334155),
                        child: const Center(
                          child: Icon(Icons.image, size: 60, color: Color(0xFF64748B)),
                        ),
                      ),
                ),
              ),
              Container(
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF0F172A).withOpacity(0.9),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
              // Status and Vibe Tags
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (statusLabel != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (statusColor ?? Colors.red).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.75),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    statusLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (vibeLabel != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    vibeLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isBookmarked
                            ? const Color(0xFF2DD4BF).withOpacity(0.9)
                            : Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border: isBookmarked
                            ? null
                            : Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        boxShadow: isBookmarked ? [
                          BoxShadow(
                            color: const Color(0xFF2DD4BF).withOpacity(0.2),
                            blurRadius: 16,
                          ),
                        ] : [],
                      ),
                      child: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? const Color(0xFF0F172A) : Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.75),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (vibeTags != null && vibeTags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: vibeTags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                  if (offerDescription != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: (offerColor ?? const Color(0xFF2DD4BF)).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              offerIcon ?? Icons.local_activity,
                              color: offerColor ?? const Color(0xFF2DD4BF),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offerTitle ?? 'ACTIVE OFFER',
                                  style: TextStyle(
                                    color: offerColor ?? const Color(0xFF2DD4BF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  offerDescription,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, {bool hasNotification = false}) {
    bool isActive = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedNavIndex = index);
        if (index == 1) {
          context.push('/map');
        } else if (index == 2) {
          context.push('/offers');
        } else if (index == 3) {
          context.push('/profile');
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? const Color(0xFF2DD4BF) : const Color(0xFF94A3B8),
                size: 24,
              ),
              if (isActive)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2DD4BF),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          if (hasNotification)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0F172A), width: 2),
                ),
                child: const Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}