import '../../../core/models/user.dart';
import '../../../core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import 'business_provider.dart';
import 'whats_on_editor.dart';

class VenueStatusScreen extends ConsumerStatefulWidget {
  final String venueId;
  final String venueName;

  const VenueStatusScreen({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  ConsumerState<VenueStatusScreen> createState() => _VenueStatusScreenState();
}

class _VenueStatusScreenState extends ConsumerState<VenueStatusScreen> {
  // Busyness
  String _busyness = 'quiet';
  // All vibes (vibe tags + music tags combined for the /status vibes field)
  final Set<String> _vibeTags = {};
  final Set<String> _musicGenres = {};

  bool _saving = false;
  bool _initialised = false;

  static const _busynessLevels = [
    ('quiet', 'Quiet', Color(0xFF22C55E)),
    ('moderate', 'Moderate', Color(0xFFF59E0B)),
    ('busy', 'Busy', Color(0xFFEF4444)),
  ];

  @override
  void dispose() {
    super.dispose();
  }

  void _applyStatus(Map<String, dynamic> data) {
    if (_initialised) return;
    final rawBusyness = data['busyness'] ?? data['currentBusyness'];
    final busyness = rawBusyness is Map ? rawBusyness['level'] : rawBusyness;
    final vibe = data['vibe'] as Map<String, dynamic>?;
    final vibesList =
        (vibe?['tags'] as List? ?? []).map((e) => e.toString()).toList();
    {
      _busyness = busyness?.toString().toLowerCase() ?? 'quiet';
      if (!_busynessLevels.any((b) => b.$1 == _busyness)) _busyness = 'quiet';
      // Split vibes back into vibe tags vs music tags after API tags load
      _vibeTags
        ..clear()
        ..addAll(vibesList);
      _initialised = true;
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final allVibes = [..._vibeTags, ..._musicGenres];
    final error =
        await ref.read(venueStatusProvider(widget.venueId).notifier).update(
              busyness: _busyness,
              vibes: allVibes,
            );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error == null
          ? 'Venue status updated successfully'
          : 'Failed: $error'),
      backgroundColor: error == null ? const Color(0xFF10B981) : Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final statusState = ref.watch(venueStatusProvider(widget.venueId));

    // Pre-fill once data loads
    statusState.whenData(_applyStatus);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Live Status',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            Text(widget.venueName,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
            onPressed: () {
              setState(() => _initialised = false);
              ref.read(venueStatusProvider(widget.venueId).notifier).load();
            },
          ),
        ],
      ),
      body: statusState.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (e, _) => _buildError(e.toString()),
        data: (_) => _buildForm(),
      ),
    );
  }

  Widget _buildError(String message) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, color: Color(0xFF334155), size: 56),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(color: Color(0xFF64748B)),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.darkBg),
              onPressed: () {
                setState(() => _initialised = false);
                ref.read(venueStatusProvider(widget.venueId).notifier).load();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );

  Widget _buildForm() {
    final vibeTagsAsync = ref.watch(vibeTagsProvider);
    final musicTagsAsync = ref.watch(musicTagsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WhatsOnEditor(venueId: widget.venueId),
          const SizedBox(height: 24),
          _statusSummaryCard(),
          const SizedBox(height: 24),
          _sectionLabel('BUSYNESS LEVEL'),
          const SizedBox(height: 12),
          _busynessSelector(),
          const SizedBox(height: 24),
          if (AuthService().currentUser?.role != UserRole.WORKER) ...[
            // Phase 6 — one-tap "What's On" broadcast presets
            _sectionLabel("WHAT'S ON — QUICK VIBE TAGS"),
            const SizedBox(height: 12),
            _whatsOnPresets(
              vibeTagsAsync.valueOrNull ?? const [],
              musicTagsAsync.valueOrNull ?? const [],
            ),
            const SizedBox(height: 24),

            _sectionLabel('VIBE TAGS'),
            const SizedBox(height: 12),
            vibeTagsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.primaryColor, strokeWidth: 2)),
              error: (_, __) => const SizedBox.shrink(),
              data: (tags) => _chipGrid(tags, _vibeTags, AppTheme.primaryColor),
            ),
            const SizedBox(height: 24),

            _sectionLabel('MUSIC GENRES'),
            const SizedBox(height: 12),
            musicTagsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF8B5CF6), strokeWidth: 2)),
              error: (_, __) => const SizedBox.shrink(),
              data: (tags) =>
                  _chipGrid(tags, _musicGenres, const Color(0xFF8B5CF6)),
            ),
            const SizedBox(height: 32),
          ],
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.darkBg,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.darkBg))
                  : const Icon(Icons.broadcast_on_personal, size: 20),
              label: Text(
                _saving ? 'Broadcasting...' : 'Broadcast Update',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_outlined,
                    color: Color(0xFF64748B), size: 13),
                SizedBox(width: 6),
                Text('LIVE SYNC TO DISCOVERY FEED',
                    style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusSummaryCard() {
    final busynessData = _busynessLevels.firstWhere((b) => b.$1 == _busyness,
        orElse: () => _busynessLevels[0]);
    final color = busynessData.$3;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.sensors, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Status',
                    style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8)),
                const SizedBox(height: 4),
                Text(
                  busynessData.$2.toUpperCase(),
                  style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1),
                ),
                if (_vibeTags.isNotEmpty)
                  Text(
                    _vibeTags.take(3).join(' · '),
                    style:
                        const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── What's On quick broadcasts ────────────────────────────────────────────
  // Preset label → keywords that are matched (case-insensitive) against the
  // venue/agent tag lists loaded from GET /tags. Only real tags are sent to
  // PUT /business/venues/{id}/status so the backend never receives unknown
  // vibe values.
  static const _presets = <(String, IconData, List<String>)>[
    (
      'Live Music Tonight',
      Icons.music_note,
      ['live music', 'live band', 'acoustic']
    ),
    ('DJ On The Decks', Icons.headphones, ['dj', 'dj set', 'house', 'techno']),
    (
      'Great Deals On',
      Icons.local_offer,
      ['happy hour', 'deals', 'cheap eats', 'cocktails']
    ),
    (
      'Sports On Screens',
      Icons.sports_soccer,
      ['live sports', 'big screen', 'sports']
    ),
    ('Quiz Night', Icons.quiz, ['quiz', 'games', 'events']),
  ];

  Widget _whatsOnPresets(List<String> vibeTags, List<String> musicTags) {
    final allTags = [...vibeTags, ...musicTags];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _presets.map((preset) {
        final label = preset.$1;
        final icon = preset.$2;
        final keywords = preset.$3;
        // Is this preset currently active? (all matched tags are selected)
        final matched = allTags
            .where((t) =>
                keywords.any((k) => t.toLowerCase().contains(k.toLowerCase())))
            .toList();
        final active = matched.isNotEmpty &&
            matched.every(
                (t) => _vibeTags.contains(t) || _musicGenres.contains(t));
        return GestureDetector(
          onTap: _saving ? null : () => _applyPreset(matched),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: active
                  ? AppTheme.primaryColor.withValues(alpha: 0.15)
                  : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? AppTheme.primaryColor : const Color(0xFF334155),
                width: active ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: 16,
                    color: active
                        ? AppTheme.primaryColor
                        : const Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        color: active
                            ? AppTheme.primaryColor
                            : const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.w500)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Toggles the preset's matched tags then immediately broadcasts so the
  /// discovery feed reflects "What's On" in real time.
  Future<void> _applyPreset(List<String> matchedTags) async {
    if (matchedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
            'No matching tags for this venue — customise below instead.',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF334155),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    final currentlyActive = matchedTags
        .every((t) => _vibeTags.contains(t) || _musicGenres.contains(t));
    setState(() {
      for (final tag in matchedTags) {
        final inVibes = _vibeTags.contains(tag);
        final inMusic = _musicGenres.contains(tag);
        if (currentlyActive) {
          _vibeTags.remove(tag);
          _musicGenres.remove(tag);
        } else if (!inVibes && !inMusic) {
          _vibeTags.add(tag);
        }
      }
    });
    await _save(); // immediate broadcast
  }

  Widget _busynessSelector() {
    return Row(
      children: _busynessLevels.map((b) {
        final selected = _busyness == b.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _busyness = b.$1),
            child: Container(
              margin: EdgeInsets.only(
                  right: b.$1 != _busynessLevels.last.$1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? b.$3.withValues(alpha: 0.15)
                    : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: selected ? b.$3 : const Color(0xFF334155),
                    width: selected ? 1.5 : 1),
              ),
              child: Column(
                children: [
                  Icon(
                    _busynessIcon(b.$1),
                    color: selected ? b.$3 : const Color(0xFF64748B),
                    size: 20,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    b.$2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? b.$3 : const Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _busynessIcon(String level) {
    switch (level) {
      case 'quiet':
        return Icons.self_improvement;
      case 'moderate':
        return Icons.people_outline;
      case 'busy':
        return Icons.people;
      case 'packed':
        return Icons.groups;
      default:
        return Icons.people_outline;
    }
  }

  Widget _chipGrid(List<String> all, Set<String> selected, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: all.map((tag) {
        final isSelected = selected.contains(tag);
        return GestureDetector(
          onTap: () => setState(
              () => isSelected ? selected.remove(tag) : selected.add(tag)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.15)
                  : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isSelected ? color : const Color(0xFF334155)),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: isSelected ? color : const Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionLabel(String label) => Text(label,
      style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5));
}
