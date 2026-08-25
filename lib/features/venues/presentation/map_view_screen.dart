import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../data/venue_management_provider.dart';
import '../../../core/config/env.dart';
import '../../../core/models/venue.dart';
import '../../../shared/widgets/app_cached_image.dart';
import '../../../shared/widgets/venue_budget_tag.dart';

const _ragGreen = Color(0xFF22C55E);
const _ragAmber = Color(0xFFF59E0B);
const _ragRed = Color(0xFFEF4444);

Color _ragColor(String busyness) {
  switch (busyness.toLowerCase()) {
    case 'busy':
    case 'packed':
      return _ragRed;
    case 'moderate':
    case 'steady':
      return _ragAmber;
    default:
      return _ragGreen;
  }
}

BitmapDescriptor _markerHue(String busyness) {
  switch (busyness.toLowerCase()) {
    case 'busy':
    case 'packed':
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    case 'moderate':
    case 'steady':
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    default:
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  }
}

class MapViewScreen extends ConsumerStatefulWidget {
  final String? venueId;
  const MapViewScreen({super.key, this.venueId});

  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  GoogleMapController? _mapController;
  String _selectedCategory = 'ALL';
  String? _selectedVenueId;
  Position? _userPosition;
  bool _locationLoading = false;
  String? _mapError;

  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _searchQuery = '';
  bool _showSuggestions = false;
  Timer? _debounce;

  // Manchester city centre default
  static const _manchesterCenter = LatLng(53.4808, -2.2426);

  @override
  void initState() {
    super.initState();
    _selectedVenueId = widget.venueId;
    Future.microtask(() {
      ref.read(venueManagementProvider.notifier).loadVenues();
      _getUserLocation();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    setState(() => _locationLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() => _userPosition = pos);
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(pos.latitude, pos.longitude),
            14,
          ),
        );
      }
    } catch (_) {
      // permission denied or GPS unavailable — stay on Manchester centre
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  List<Venue> _filteredVenues(List<Venue> venues) {
    var list = _selectedCategory == 'ALL'
        ? venues
        : venues
            .where((v) => v.type.toLowerCase() == _selectedCategory)
            .toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((v) =>
              v.name.toLowerCase().contains(q) ||
              v.address.toLowerCase().contains(q) ||
              v.type.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  void _onSearchChanged(String value, List<Venue> venues) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = value.trim();
        _showSuggestions = _searchQuery.isNotEmpty;
      });
    });
  }

  void _selectSuggestion(Venue venue) {
    _searchController.text = venue.name;
    _searchFocus.unfocus();
    setState(() {
      _searchQuery = venue.name;
      _showSuggestions = false;
      _selectedVenueId = venue.id;
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(venue.latitude, venue.longitude), 16),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() {
      _searchQuery = '';
      _showSuggestions = false;
    });
  }

  Set<Marker> _buildMarkers(List<Venue> venues) {
    final filtered = _filteredVenues(venues);

    return filtered.map((venue) {
      final isSelected = _selectedVenueId == venue.id;
      return Marker(
        markerId: MarkerId(venue.id),
        position: LatLng(venue.latitude, venue.longitude),
        icon: _markerHue(venue.busyness),
        infoWindow: InfoWindow(
          title: venue.name,
          snippet: [
            venue.busyness.toUpperCase(),
            venue.type,
            if (venue.budgetSymbol != null) venue.budgetSymbol!,
          ].join(' • '),
          onTap: () => context.push('/venue-detail?id=${venue.id}'),
        ),
        zIndex: isSelected ? 2 : 1,
        onTap: () {
          setState(() => _selectedVenueId = venue.id);
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(venue.latitude, venue.longitude),
              15,
            ),
          );
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(venueManagementProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // ── Google Map ────────────────────────────────────────────────
          if (_mapError != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_outlined,
                      color: Color(0xFF64748B), size: 64),
                  const SizedBox(height: 16),
                  const Text('Map unavailable',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(_mapError!,
                      style: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 13),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14B8A6)),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            )
          else
            venuesAsync.when(
              data: (venues) {
                try {
                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: widget.venueId != null
                          ? _venueLatLng(venues, widget.venueId!) ??
                              _manchesterCenter
                          : _manchesterCenter,
                      zoom: 14,
                    ),
                    onMapCreated: (c) {
                      _mapController = c;
                      // If specific venue, zoom to it
                      if (widget.venueId != null) {
                        final ll = _venueLatLng(venues, widget.venueId!);
                        if (ll != null) {
                          c.animateCamera(CameraUpdate.newLatLngZoom(ll, 16));
                        }
                      }
                    },
                    markers: _buildMarkers(venues),
                    myLocationEnabled: _userPosition != null,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    mapType: MapType.normal,
                    onTap: (_) => setState(() {
                      _selectedVenueId = null;
                      _showSuggestions = false;
                      _searchFocus.unfocus();
                    }),
                  );
                } catch (e) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _mapError = e.toString());
                  });
                  return const SizedBox.shrink();
                }
              },
              loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2DD4BF))),
              error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(color: Colors.white))),
            ),

          // ── Top bar ───────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: venuesAsync.maybeWhen(
                data: (venues) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _circleButton(Icons.arrow_back, () => context.pop()),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withOpacity(0.95),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocus,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              onChanged: (v) => _onSearchChanged(v, venues),
                              onTap: () {
                                if (_searchQuery.isNotEmpty) {
                                  setState(() => _showSuggestions = true);
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Search venues or areas...',
                                hintStyle: const TextStyle(
                                    color: Color(0xFF64748B), fontSize: 14),
                                prefixIcon: const Icon(Icons.search,
                                    color: Color(0xFF94A3B8), size: 20),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Color(0xFF94A3B8), size: 18),
                                        onPressed: _clearSearch,
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Suggestions dropdown
                    if (_showSuggestions) ...[
                      const SizedBox(height: 6),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 220),
                        margin: const EdgeInsets.only(left: 56),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 12)
                          ],
                        ),
                        child: Builder(builder: (_) {
                          final suggestions = _filteredVenues(venues);
                          if (suggestions.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No venues found',
                                  style: TextStyle(
                                      color: Color(0xFF64748B), fontSize: 13)),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            itemCount:
                                suggestions.length > 6 ? 6 : suggestions.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                color: Color(0xFF334155),
                                indent: 16,
                                endIndent: 16),
                            itemBuilder: (_, i) {
                              final v = suggestions[i];
                              return ListTile(
                                dense: true,
                                leading: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color:
                                        _ragColor(v.busyness).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.store_outlined,
                                      color: _ragColor(v.busyness), size: 16),
                                ),
                                title: Text(v.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(v.address,
                                    style: const TextStyle(
                                        color: Color(0xFF64748B), fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        _ragColor(v.busyness).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(v.busyness.toUpperCase(),
                                      style: TextStyle(
                                          color: _ragColor(v.busyness),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700)),
                                ),
                                onTap: () => _selectSuggestion(v),
                              );
                            },
                          );
                        }),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Category filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip('All', Icons.grid_view, 'ALL'),
                          const SizedBox(width: 8),
                          _filterChip('Bar', Icons.local_bar, 'bar'),
                          const SizedBox(width: 8),
                          _filterChip('Club', Icons.music_note, 'club'),
                          const SizedBox(width: 8),
                          _filterChip(
                              'Restaurant', Icons.restaurant, 'restaurant'),
                          const SizedBox(width: 8),
                          _filterChip('Lounge', Icons.weekend, 'lounge'),
                          const SizedBox(width: 8),
                          _filterChip('Live Music', Icons.queue_music,
                              'live_music_venue'),
                          const SizedBox(width: 8),
                          _filterChip('Pub', Icons.sports_bar, 'pub'),
                          const SizedBox(width: 8),
                          _filterChip('Rooftop', Icons.roofing, 'rooftop_bar'),
                          const SizedBox(width: 8),
                          _filterChip(
                              'Cocktail', Icons.local_drink, 'cocktail_bar'),
                        ],
                      ),
                    ),
                  ],
                ),
                orElse: () => Row(
                  children: [
                    _circleButton(Icons.arrow_back, () => context.pop()),
                  ],
                ),
              ),
            ),
          ),

          // ── RAG legend ────────────────────────────────────────────────
          Positioned(
            top: 160,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.92),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legendRow(_ragGreen, 'Quiet'),
                  const SizedBox(height: 6),
                  _legendRow(_ragAmber, 'Moderate'),
                  const SizedBox(height: 6),
                  _legendRow(_ragRed, 'Busy'),
                ],
              ),
            ),
          ),

          // ── My location button ────────────────────────────────────────
          Positioned(
            bottom: _selectedVenueId != null ? 160 : 40,
            right: 16,
            child: GestureDetector(
              onTap: _getUserLocation,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.92),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.3), blurRadius: 8)
                  ],
                ),
                child: _locationLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF2DD4BF)),
                      )
                    : Icon(
                        _userPosition != null
                            ? Icons.my_location
                            : Icons.location_searching,
                        color: _userPosition != null
                            ? const Color(0xFF2DD4BF)
                            : const Color(0xFF94A3B8),
                        size: 22,
                      ),
              ),
            ),
          ),

          // ── Selected venue card ───────────────────────────────────────
          if (_selectedVenueId != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: venuesAsync.maybeWhen(
                data: (venues) {
                  final matches = venues.where((v) => v.id == _selectedVenueId);
                  if (matches.isEmpty) return const SizedBox.shrink();
                  final venue = matches.first;
                  return GestureDetector(
                    onTap: () => context.push('/venue-detail?id=${venue.id}'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withOpacity(0.96),
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 20)
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AppCachedImage(
                              url: venue.coverImageUrl != null &&
                                      venue.coverImageUrl!.isNotEmpty
                                  ? (venue.coverImageUrl!.startsWith('http')
                                      ? venue.coverImageUrl!
                                      : '${Env.apiBaseUrl}${venue.coverImageUrl!.startsWith('/') ? '' : '/'}${venue.coverImageUrl}')
                                  : null,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              placeholder: _imagePlaceholder(),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(venue.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(children: [
                                  Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                          color: _ragColor(venue.busyness),
                                          shape: BoxShape.circle)),
                                  const SizedBox(width: 6),
                                  Text(venue.busyness.toUpperCase(),
                                      style: TextStyle(
                                          color: _ragColor(venue.busyness),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ]),
                                if (venue.priceLevel != null) ...[
                                  const SizedBox(height: 4),
                                  VenueBudgetTag(
                                    venue: venue,
                                    compact: true,
                                  ),
                                ],
                                const SizedBox(height: 2),
                                Text(venue.address,
                                    style: const TextStyle(
                                        color: Color(0xFF94A3B8), fontSize: 11),
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
            ),
        ],
      ),
    );
  }

  LatLng? _venueLatLng(List<Venue> venues, String id) {
    final matches = venues.where((v) => v.id == id);
    if (matches.isEmpty) return null;
    return LatLng(matches.first.latitude, matches.first.longitude);
  }

  Widget _imagePlaceholder() => Container(
      width: 72,
      height: 72,
      color: const Color(0xFF334155),
      child: const Icon(Icons.image, color: Color(0xFF64748B)));

  Widget _circleButton(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.92),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );

  Widget _filterChip(String label, IconData icon, String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2DD4BF)
              : const Color(0xFF1E293B).withOpacity(0.92),
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

  Widget _legendRow(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      );
}
