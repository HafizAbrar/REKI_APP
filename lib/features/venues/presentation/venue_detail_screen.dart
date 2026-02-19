import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/venue_management_provider.dart';
import '../../../core/network/vibe_schedule_api_service.dart';
import '../../../core/models/vibe_schedule.dart';
import '../../../core/config/env.dart';

class VenueDetailScreen extends ConsumerStatefulWidget {
  final String venueId;
  
  const VenueDetailScreen({super.key, required this.venueId});

  @override
  ConsumerState<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends ConsumerState<VenueDetailScreen> {
  bool _isFavorite = false;
  List<VibeSchedule>? _vibeSchedules;
  final _vibeScheduleService = VibeScheduleApiService();

  @override
  void initState() {
    super.initState();
    _loadVibeSchedules();
  }

  Future<void> _loadVibeSchedules() async {
    try {
      final schedules = await _vibeScheduleService.getVibeSchedules(widget.venueId);
      setState(() => _vibeSchedules = schedules);
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final venueAsync = ref.watch(venueDetailProvider(widget.venueId));
    
    return venueAsync.when(
      data: (venue) => Scaffold(
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
                            '${Env.apiBaseUrl}${venue.coverImageUrl}',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xFF334155),
                                child: const Center(
                                  child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFF334155),
                              child: const Center(
                                child: Icon(Icons.image, size: 60, color: Color(0xFF64748B)),
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFF334155),
                            child: const Center(
                              child: Icon(Icons.image, size: 60, color: Color(0xFF64748B)),
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
                            _buildHeaderButton(Icons.arrow_back, () => Navigator.pop(context)),
                            _buildHeaderButton(
                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                              () => setState(() => _isFavorite = !_isFavorite),
                              isFavorite: _isFavorite,
                            ),
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
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  const Icon(Icons.location_on, color: Color(0xFF94A3B8), size: 16),
                                  const SizedBox(width: 4),
                                  Text(venue.address, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                children: [
                                  _buildTag(venue.type),
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
                      const SizedBox(height: 32),
                      if (_vibeSchedules != null) _buildVibeScheduleSection(),
                      if (_vibeSchedules != null) const SizedBox(height: 32),
                      _buildAboutSection(venue),
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
    ),
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2DD4BF))),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(child: Text('Error: $error', style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap, {bool isFavorite = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isFavorite ? const Color(0xFF2DD4BF) : Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(
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
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                      style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 14, fontWeight: FontWeight.w500),
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
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          venue.description ?? 'No description available',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.5),
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
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '${schedule.startTime.substring(0, 5)} - ${schedule.endTime.substring(0, 5)}',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2DD4BF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  schedule.vibe,
                  style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 12, fontWeight: FontWeight.bold),
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
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => GoRouter.of(context).push('/map'),
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
                        image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuADhzm8lWPGb7TipwGJX4Ls1SLwHuj6L8RtO3u72yLx2v9vV38ulG_1454dOG8lUuYxKNdgEBz0RiCq0Zqb_rEC-wyBzFs1HsnrM7V8BQh__9ZBQbg-IgkUPB-qKhXwSkgjlYSp20fSAvJYjoLs4ORpNf8wKExp4GuxT0lz-PStkyKnVoYU0sxgw4paMzbViNDwUjLjdc_P2WiEz_AKXwAKryxZw28TqR1GhQMGVxRvCA5WXwW_k4neVoeq8cHuYi_fmYAjywTOGxQF'),
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
                      child: const Icon(Icons.location_on, color: Colors.white, size: 24),
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
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  venue.postcode ?? '',
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2DD4BF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.directions, color: Color(0xFF0F172A), size: 16),
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
