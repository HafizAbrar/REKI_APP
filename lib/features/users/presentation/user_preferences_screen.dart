import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/user_preferences_provider.dart';

const _allVibes = [
  'Chill', 'Party', 'Romantic', 'Energetic', 'Rooftop',
  'Date Night', 'Live Music', 'Underground', 'Industrial', 'Intimate',
];

const _allMusic = [
  'Hip-Hop', 'House', 'R&B', 'Techno', 'Pop',
  'Jazz', 'Live Band', 'Drum & Bass', 'Afrobeats', 'Indie',
];

class UserPreferencesScreen extends ConsumerStatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  ConsumerState<UserPreferencesScreen> createState() =>
      _UserPreferencesScreenState();
}

class _UserPreferencesScreenState
    extends ConsumerState<UserPreferencesScreen> {
  Set<String> _selectedVibes = {};
  Set<String> _selectedMusic = {};
  bool _loaded = false;
  bool _hasPreferences = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadPreferences);
  }

  Future<void> _loadPreferences() async {
    final result = await ref.read(userPreferencesProvider.future);
    if (!mounted) return;
    setState(() {
      _selectedVibes = Set<String>.from(
          (result?['vibes'] as List? ?? []).map((e) => e.toString()));
      _selectedMusic = Set<String>.from(
          (result?['music'] as List? ?? []).map((e) => e.toString()));
      _hasPreferences = result?['hasPreferences'] as bool? ?? false;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifierState = ref.watch(userPreferencesNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Preferences',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: !_loaded
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2DD4BF)))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2DD4BF).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFF2DD4BF).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tune,
                            color: Color(0xFF2DD4BF), size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Personalise your feed',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(
                                'Select your vibes and music to get better recommendations',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                    height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Vibes
                  _sectionHeader(
                      Icons.local_fire_department_outlined, 'Vibes',
                      '${_selectedVibes.length} selected'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allVibes
                        .map((v) => _Chip(
                              label: v,
                              selected: _selectedVibes.contains(v),
                              onTap: () => setState(() => _selectedVibes
                                  .contains(v)
                                  ? _selectedVibes.remove(v)
                                  : _selectedVibes.add(v)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 28),

                  // Music
                  _sectionHeader(
                      Icons.music_note_outlined, 'Music',
                      '${_selectedMusic.length} selected'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allMusic
                        .map((m) => _Chip(
                              label: m,
                              selected: _selectedMusic.contains(m),
                              color: const Color(0xFF8B5CF6),
                              onTap: () => setState(() => _selectedMusic
                                  .contains(m)
                                  ? _selectedMusic.remove(m)
                                  : _selectedMusic.add(m)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 36),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2DD4BF),
                        foregroundColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                        elevation: 0,
                      ),
                      onPressed: notifierState.isLoading ? null : _save,
                      child: notifierState.isLoading
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: Color(0xFF0F172A), strokeWidth: 2))
                          : const Text('Save Preferences',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2DD4BF), size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        const Spacer(),
        Text(subtitle,
            style: const TextStyle(
                color: Color(0xFF64748B), fontSize: 12)),
      ],
    );
  }

  Future<void> _save() async {
    final payload = {
      'vibes': _selectedVibes.toList(),
      'music': _selectedMusic.toList(),
    };

    final notifier = ref.read(userPreferencesNotifierProvider.notifier);
    // POST on first save, PUT on update
    final success = _hasPreferences
        ? await notifier.updatePreferences(payload)
        : await notifier.savePreferences(payload);

    if (!mounted) return;
    if (success) setState(() => _hasPreferences = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          success ? 'Preferences saved!' : 'Failed to save preferences'),
      backgroundColor:
          success ? const Color(0xFF10B981) : Colors.red,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
    if (success) context.pop();
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = const Color(0xFF2DD4BF),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? color : const Color(0xFF334155)),
          boxShadow: selected
              ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8)]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : const Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
