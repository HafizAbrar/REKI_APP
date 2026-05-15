import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/venue_management_provider.dart';
import '../../../core/config/env.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/venue.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;
  int _selectedNavIndex = 0;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(venueManagementProvider.notifier).loadVenues());
  }

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(venueManagementProvider);
    final searchAsync = ref.watch(venueSearchProvider);
    final filters = ref.watch(filterProvider);
    final authService = AuthService();
    final user = authService.currentUser;
    
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
                                child: user?.profilePicture != null
                                  ? Image.network(
                                      user!.profilePicture!,
                                      fit: BoxFit.cover,
                                      width: 40,
                                      height: 40,
                                      errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(user),
                                    )
                                  : _buildInitialsAvatar(user),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Guest User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                user?.email ?? 'Not logged in',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildHeaderButton(Icons.search, onTap: _showSearchDialog),
                        const SizedBox(width: 8),
                        _buildHeaderButton(Icons.tune, filterActive: filters.isActive),
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
                                _buildTab('Club', Icons.music_note, 2),
                                const SizedBox(width: 8),
                                _buildTab('Restaurant', Icons.restaurant, 3),
                                const SizedBox(width: 8),
                                _buildTab('Lounge', Icons.weekend, 4),
                                const SizedBox(width: 8),
                                _buildTab('Live Music', Icons.queue_music, 5),
                                const SizedBox(width: 8),
                                _buildTab('Pub', Icons.sports_bar, 6),
                                const SizedBox(width: 8),
                                _buildTab('Rooftop', Icons.roofing, 7),
                                const SizedBox(width: 8),
                                _buildTab('Cocktail', Icons.local_drink, 8),
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
                child: _isSearching
                    ? _buildSearchResults(searchAsync)
                    : venuesAsync.when(
                  data: (venues) {
                    var filteredVenues = _selectedTab == 0
                      ? venues
                      : venues.where((v) {
                          final cat = v.type.toLowerCase();
                          if (_selectedTab == 1) return cat == 'bar';
                          if (_selectedTab == 2) return cat == 'club';
                          if (_selectedTab == 3) return cat == 'restaurant';
                          if (_selectedTab == 4) return cat == 'lounge';
                          if (_selectedTab == 5) return cat == 'live_music_venue';
                          if (_selectedTab == 6) return cat == 'pub';
                          if (_selectedTab == 7) return cat == 'rooftop_bar';
                          if (_selectedTab == 8) return cat == 'cocktail_bar';
                          return true;
                        }).toList();

                    // Apply filter panel selections
                    if (filters.busyness.isNotEmpty) {
                      filteredVenues = filteredVenues
                          .where((v) => v.busyness.toLowerCase() == filters.busyness.toLowerCase())
                          .toList();
                    }
                    if (filters.vibes.isNotEmpty) {
                      filteredVenues = filteredVenues.where((v) {
                        final vibe = v.currentVibe.toLowerCase();
                        return filters.vibes.any((s) => vibe.contains(s.toLowerCase()));
                      }).toList();
                    }
                    if (filters.offersOnly) {
                      filteredVenues = filteredVenues.where((v) => v.offers.isNotEmpty).toList();
                    }

                    if (_searchQuery.isNotEmpty) {
                      filteredVenues = filteredVenues.where((v) =>
                        v.name.toLowerCase().contains(_searchQuery) ||
                        v.type.toLowerCase().contains(_searchQuery)
                      ).toList();
                    }

                    if (filteredVenues.isEmpty) {
                      return _buildNoResults(filters.isActive);
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

  Widget _buildInitialsAvatar(user) {
    final initials = user?.name.isNotEmpty == true
        ? user!.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';
    return Container(
      width: 40,
      height: 40,
      color: const Color(0xFF2DD4BF),
      child: Center(
        child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, {VoidCallback? onTap, bool filterActive = false}) {
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
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(child: Icon(icon, color: Colors.white, size: 20)),
              if (filterActive)
                Positioned(
                  top: 6, right: 6,
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2DD4BF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog() {
    final controller = TextEditingController(text: _searchQuery);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Search Venues', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search by name, area or tags...',
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Color(0xFF64748B)),
              onPressed: () => controller.clear(),
            ),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() { _searchQuery = ''; _isSearching = false; });
              ref.read(venueSearchProvider.notifier).clear();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2DD4BF),
              foregroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final q = controller.text.trim();
              if (q.isNotEmpty) {
                setState(() { _searchQuery = q; _isSearching = true; });
                ref.read(venueSearchProvider.notifier).search(q);
              }
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<Venue>> searchAsync) {
    return searchAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2DD4BF))),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
      data: (venues) {
        if (venues.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, color: Color(0xFF64748B), size: 64),
                const SizedBox(height: 16),
                Text('No results for "$_searchQuery"',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16)),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() { _searchQuery = ''; _isSearching = false; });
                    ref.read(venueSearchProvider.notifier).clear();
                  },
                  child: const Text('Clear search', style: TextStyle(color: Color(0xFF2DD4BF))),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            // Search result header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Text('${venues.length} results for "$_searchQuery"',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() { _searchQuery = ''; _isSearching = false; });
                      ref.read(venueSearchProvider.notifier).clear();
                    },
                    child: const Text('Clear', style: TextStyle(color: Color(0xFF2DD4BF), fontSize: 13)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: venues.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildVenueCard(venue: venues[i], isBookmarked: false),
                ),
              ),
            ),
          ],
        );
      },
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
                        venue.coverImageUrl!.startsWith('http')
                            ? venue.coverImageUrl!
                            : '${Env.apiBaseUrl}${venue.coverImageUrl}',
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

  Widget _buildNoResults(bool hasFilters) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2DD4BF).withOpacity(0.3), width: 1.5),
              ),
              child: const Icon(Icons.search_off_rounded, color: Color(0xFF2DD4BF), size: 36),
            ),
            const SizedBox(height: 24),
            const Text(
              'No venues found',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              hasFilters
                  ? 'No venues match your current filters.\nTry adjusting or resetting them.'
                  : 'There are no venues available\nin this category right now.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15, height: 1.5),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => ref.read(filterProvider.notifier).reset(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2DD4BF),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF2DD4BF).withOpacity(0.3), blurRadius: 16),
                    ],
                  ),
                  child: const Text(
                    'Clear Filters',
                    style: TextStyle(color: Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, {bool hasNotification = false}) {
    bool isActive = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          context.push('/map').then((_) => setState(() => _selectedNavIndex = 0));
        } else if (index == 2) {
          context.push('/offers').then((_) => setState(() => _selectedNavIndex = 0));
        } else if (index == 3) {
          context.push('/profile').then((_) => setState(() => _selectedNavIndex = 0));
        } else {
          setState(() => _selectedNavIndex = index);
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