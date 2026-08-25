import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import '../data/venue_management_provider.dart';
import '../../../core/network/venue_api_service.dart';
import '../../../core/models/vibe_schedule.dart';
import '../../../core/config/env.dart';
import '../../../core/services/venue_repository.dart';
import '../../../features/users/data/user_preferences_provider.dart';
import '../../../shared/widgets/guest_guard.dart';
import '../../../shared/widgets/venue_budget_tag.dart';
import '../../../core/models/venue.dart';
import '../../../core/services/social_repository.dart';
import '../../social/data/social_provider.dart';
import '../../social/presentation/venue_reviews_section.dart';

class VenueDetailScreen extends ConsumerStatefulWidget {
  final String venueId;

  const VenueDetailScreen({super.key, required this.venueId});

  @override
  ConsumerState<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends ConsumerState<VenueDetailScreen> {
  bool _savingFavorite = false;
  bool _checkingIn = false;
  bool _visitRecorded = false;
  List<VibeSchedule>? _vibeSchedules;

  @override
  void initState() {
    super.initState();
    _loadVibeSchedules();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(venueRepositoryProvider).trackVenueView(widget.venueId);
    });
  }

  Future<void> _loadVibeSchedules() async {
    try {
      final apiService = ref.read(venueApiServiceProvider);
      final schedules = await apiService.getVibeSchedules(widget.venueId);
      setState(() => _vibeSchedules =
          schedules.map((s) => VibeSchedule.fromJson(s)).toList());
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _openDirections(double destLat, double destLng) async {
    String origin = '';
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        origin = '${pos.latitude},${pos.longitude}';
      }
    } catch (_) {}

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '${origin.isNotEmpty ? '&origin=$origin' : ''}'
      '&destination=$destLat,$destLng'
      '&travelmode=walking',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  void _recordVisit(Venue venue) {
    if (_visitRecorded) return;
    _visitRecorded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(venueHistoryProvider.notifier).record(venue.id, venue.name);
      }
    });
  }

  Future<void> _shareVenue(Venue venue) async {
    final url = '${Env.appLinkBaseUrl}/venue/${venue.id}';
    final points = await ref
        .read(socialRepositoryProvider)
        .trackShare(venue.id, channel: 'other');
    if (points > 0) {
      ref.invalidate(achievementsProvider);
      ref.invalidate(leaderboardProvider);
    }
    await Share.share(
      'Check out ${venue.name} on REKI — live vibe: ${venue.currentVibe}. $url',
      subject: '${venue.name} on REKI',
    );
  }

  Future<void> _checkIn(Venue venue) async {
    if (!await guardGuestAction(context) || !mounted) return;
    setState(() => _checkingIn = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission is required to check in.');
      }
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final distance = Geolocator.distanceBetween(position.latitude,
          position.longitude, venue.latitude, venue.longitude);
      if (distance > 300) {
        throw Exception('Move within 300 metres of the venue to check in.');
      }
      final checkIn = await ref.read(socialRepositoryProvider).checkIn(
            venue.id,
            venue.name,
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
          );
      ref.invalidate(checkInsProvider);
      ref.invalidate(achievementsProvider);
      ref.invalidate(leaderboardProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(checkIn.pointsAwarded > 0
              ? 'Checked in! +${checkIn.pointsAwarded} points'
              : 'Checked in!'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _checkingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final venueAsync = ref.watch(venueDetailProvider(widget.venueId));

    return venueAsync.when(
      data: (venue) {
        _recordVisit(venue);
        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: Stack(
                        children: [
                          venue.coverImageUrl != null
                              ? Image.network(
                                  venue.coverImageUrl!.startsWith('http')
                                      ? venue.coverImageUrl!
                                      : '${Env.apiBaseUrl}${venue.coverImageUrl!.startsWith('/') ? '' : '/'}${venue.coverImageUrl}',
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: const Color(0xFF334155),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                            color: Color(0xFF2DD4BF)),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: const Color(0xFF334155),
                                    child: const Center(
                                      child: Icon(Icons.image,
                                          size: 60, color: Color(0xFF64748B)),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: const Color(0xFF334155),
                                  child: const Center(
                                    child: Icon(Icons.image,
                                        size: 60, color: Color(0xFF64748B)),
                                  ),
                                ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF0F172A).withOpacity(0.6),
                                  const Color(0xFF0F172A),
                                ],
                                stops: const [0.0, 0.7, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 16,
                            left: 16,
                            right: 16,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildHeaderButton(Icons.arrow_back,
                                    () => Navigator.pop(context)),
                                Row(children: [
                                  _buildHeaderButton(Icons.share_outlined,
                                      () => _shareVenue(venue)),
                                  const SizedBox(width: 10),
                                  Builder(builder: (context) {
                                    final isFavorite = ref
                                            .watch(savedVenuesProvider)
                                            .whenOrNull(
                                                data: (venues) => venues.any(
                                                    (v) =>
                                                        v.id ==
                                                        widget.venueId)) ??
                                        false;
                                    return _buildHeaderButton(
                                      isFavorite
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      _savingFavorite
                                          ? null
                                          : () async {
                                              if (!await guardGuestAction(
                                                  context)) return;
                                              setState(
                                                  () => _savingFavorite = true);
                                              final notifier = ref.read(
                                                  savedVenuesProvider.notifier);
                                              final success = isFavorite
                                                  ? await notifier.unsaveVenue(
                                                      widget.venueId)
                                                  : await notifier.saveVenue(
                                                      widget.venueId);
                                              if (mounted) {
                                                setState(() =>
                                                    _savingFavorite = false);
                                                if (!success) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(isFavorite
                                                          ? 'Failed to unsave venue'
                                                          : 'Failed to save venue'),
                                                      backgroundColor:
                                                          Colors.red,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                      isFavorite: isFavorite,
                                      isLoading: _savingFavorite,
                                    );
                                  }),
                                ]),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: -24,
                            left: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.05)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          venue.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          color: Color(0xFF94A3B8), size: 16),
                                      const SizedBox(width: 4),
                                      Text(venue.address,
                                          style: const TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 14)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildTag(venue.type),
                                      if (venue.priceLevel != null)
                                        VenueBudgetTag(venue: venue),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildVibeSection(venue),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed:
                                  _checkingIn ? null : () => _checkIn(venue),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2DD4BF),
                                side:
                                    const BorderSide(color: Color(0xFF2DD4BF)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: _checkingIn
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Icon(Icons.location_on_outlined),
                              label: const Text('Check in here',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Vibe Check
                          _VibeCheckCard(
                              venueId: venue.id, venueName: venue.name),
                          const SizedBox(height: 16),
                          _VibeAccuracyCard(
                            venueId: venue.id,
                            observedVibe: venue.currentVibe,
                          ),
                          const SizedBox(height: 32),
                          if (_vibeSchedules != null)
                            _buildVibeScheduleSection(),
                          if (_vibeSchedules != null)
                            const SizedBox(height: 32),
                          _buildAboutSection(venue),
                          const SizedBox(height: 32),
                          VenueReviewsSection(venueId: venue.id),
                          const SizedBox(height: 32),
                          _buildLocationSection(context, venue),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFF2DD4BF))),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
            child: Text('Error: $error',
                style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback? onTap,
      {bool isFavorite = false, bool isLoading = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isFavorite
              ? const Color(0xFF2DD4BF)
              : Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: isLoading
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isFavorite ? const Color(0xFF0F172A) : Colors.white,
                ),
              )
            : Icon(
                icon,
                color: isFavorite ? const Color(0xFF0F172A) : Colors.white,
                size: 22,
              ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFCFFAFE),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildVibeSection(venue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Vibe Check',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2DD4BF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      venue.currentVibe,
                      style: const TextStyle(
                          color: Color(0xFF2DD4BF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              venue.busyness,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection(venue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          venue.description ?? 'No description available',
          style: const TextStyle(
              color: Color(0xFF94A3B8), fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildVibeScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Vibe Schedule',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._vibeSchedules!.map((schedule) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      schedule.dayName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    '${schedule.startTime.substring(0, 5)} - ${schedule.endTime.substring(0, 5)}',
                    style:
                        const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2DD4BF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      schedule.vibe,
                      style: const TextStyle(
                          color: Color(0xFF2DD4BF),
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context, venue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => context.push('/map?venueId=${venue.id}'),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              color: const Color(0xFF1E293B),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuADhzm8lWPGb7TipwGJX4Ls1SLwHuj6L8RtO3u72yLx2v9vV38ulG_1454dOG8lUuYxKNdgEBz0RiCq0Zqb_rEC-wyBzFs1HsnrM7V8BQh__9ZBQbg-IgkUPB-qKhXwSkgjlYSp20fSAvJYjoLs4ORpNf8wKExp4GuxT0lz-PStkyKnVoYU0sxgw4paMzbViNDwUjLjdc_P2WiEz_AKXwAKryxZw28TqR1GhQMGVxRvCA5WXwW_k4neVoeq8cHuYi_fmYAjywTOGxQF'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2DD4BF),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2DD4BF).withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.location_on,
                          color: Colors.white, size: 24),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF0F172A).withOpacity(0.9),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  venue.address,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  venue.postcode ?? '',
                                  style: const TextStyle(
                                      color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openDirections(
                                venue.latitude, venue.longitude),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2DD4BF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.directions,
                                      color: Color(0xFF0F172A), size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Directions',
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VibeAccuracyCard extends ConsumerStatefulWidget {
  final String venueId;
  final String observedVibe;

  const _VibeAccuracyCard({
    required this.venueId,
    required this.observedVibe,
  });

  @override
  ConsumerState<_VibeAccuracyCard> createState() => _VibeAccuracyCardState();
}

class _VibeAccuracyCardState extends ConsumerState<_VibeAccuracyCard> {
  bool _submitting = false;
  bool? _vote;

  Future<void> _submit(bool accurate) async {
    if (!await guardGuestAction(context) || !mounted) return;
    setState(() => _submitting = true);
    try {
      await ref.read(socialRepositoryProvider).voteVibeAccuracy(
            widget.venueId,
            accurate,
            observedVibe: widget.observedVibe,
          );
      if (!mounted) return;
      setState(() => _vote = accurate);
      ref.invalidate(achievementsProvider);
      ref.invalidate(leaderboardProvider);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Thanks — your vibe accuracy vote was recorded.'),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: .07)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Is the listed vibe accurate?',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text(
          _vote == null
              ? 'Help other people know what to expect right now.'
              : 'Vote recorded. You can change it at any time.',
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _submitting ? null : () => _submit(true),
              icon: const Icon(Icons.thumb_up_alt_outlined),
              label: const Text('Accurate'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _vote == true
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF2DD4BF),
                backgroundColor: _vote == true ? const Color(0xFF2DD4BF) : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _submitting ? null : () => _submit(false),
              icon: const Icon(Icons.thumb_down_alt_outlined),
              label: const Text('Not quite'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    _vote == false ? Colors.white : const Color(0xFFF87171),
                backgroundColor:
                    _vote == false ? const Color(0xFFB91C1C) : null,
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ── Vibe Check Card ────────────────────────────────────────────────────────
class _VibeCheckCard extends ConsumerStatefulWidget {
  final String venueId;
  final String venueName;
  const _VibeCheckCard({required this.venueId, required this.venueName});

  @override
  ConsumerState<_VibeCheckCard> createState() => _VibeCheckCardState();
}

class _VibeCheckCardState extends ConsumerState<_VibeCheckCard> {
  int? _submittedScore;

  void _showSheet() {
    guardGuestAction(context).then((allowed) {
      if (!allowed || !mounted) return;
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => _VibeCheckSheet(
          venueId: widget.venueId,
          venueName: widget.venueName,
          onSubmitted: (score) => setState(() => _submittedScore = score),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showSheet,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2DD4BF).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.star, color: Color(0xFFF59E0B), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vibe Check',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  Text(
                    _submittedScore != null
                        ? 'You rated this $_submittedScore/5 ⭐'
                        : 'Rate the vibe right now (1–5)',
                    style:
                        const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              _submittedScore != null
                  ? Icons.check_circle
                  : Icons.arrow_forward_ios,
              color: _submittedScore != null
                  ? const Color(0xFF2DD4BF)
                  : const Color(0xFF94A3B8),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Vibe Check Bottom Sheet ────────────────────────────────────────────────
class _VibeCheckSheet extends ConsumerStatefulWidget {
  final String venueId;
  final String venueName;
  final void Function(int score) onSubmitted;
  const _VibeCheckSheet(
      {required this.venueId,
      required this.venueName,
      required this.onSubmitted});

  @override
  ConsumerState<_VibeCheckSheet> createState() => _VibeCheckSheetState();
}

class _VibeCheckSheetState extends ConsumerState<_VibeCheckSheet> {
  int? _selectedScore;
  bool _isLoading = false;
  bool _done = false;

  static const _labels = ['Terrible', 'Bad', 'Okay', 'Good', 'Amazing'];
  static const _emojis = ['😞', '😕', '😐', '😊', '🔥'];

  Future<void> _submit() async {
    if (_selectedScore == null) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(venueApiServiceProvider)
          .submitVibeCheck(widget.venueId, _selectedScore!);
      setState(() {
        _done = true;
        _isLoading = false;
      });
      widget.onSubmitted(_selectedScore!);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: Colors.red[700]),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          if (_done) ...[
            const Icon(Icons.check_circle, color: Color(0xFF2DD4BF), size: 56),
            const SizedBox(height: 12),
            const Text('Vibe check submitted!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Thanks for keeping it real 🔥',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
          ] else ...[
            const Text("How's the vibe at",
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
            const SizedBox(height: 4),
            Text(widget.venueName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (i) {
                final score = i + 1;
                final selected =
                    _selectedScore != null && score <= _selectedScore!;
                return GestureDetector(
                  onTap: () => setState(() => _selectedScore = score),
                  child: Column(
                    children: [
                      Text(_emojis[i], style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 6),
                      Icon(
                        selected ? Icons.star : Icons.star_border,
                        color: selected
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF475569),
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text('$score',
                          style: TextStyle(
                              color: selected
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              }),
            ),
            if (_selectedScore != null) ...[
              const SizedBox(height: 12),
              Text(_labels[_selectedScore! - 1],
                  style: const TextStyle(
                      color: Color(0xFF2DD4BF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedScore != null
                      ? const Color(0xFF2DD4BF)
                      : const Color(0xFF334155),
                  foregroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed:
                    _selectedScore == null || _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF0F172A)))
                    : const Text('Submit Vibe Check',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
