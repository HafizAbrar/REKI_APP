import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/user_repository.dart';

class UserPreferencesScreen extends ConsumerStatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  ConsumerState<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends ConsumerState<UserPreferencesScreen> {
  String selectedVibe = 'Party';
  String selectedBusyness = 'Moderate';
  Set<String> selectedCategories = {'BAR', 'RESTAURANT'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text('Preferences', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Preferred Vibe', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['Chill', 'Party', 'Romantic', 'Business', 'Energetic'].map((vibe) => 
                ChoiceChip(
                  label: Text(vibe),
                  selected: selectedVibe == vibe,
                  onSelected: (selected) => setState(() => selectedVibe = vibe),
                  selectedColor: const Color(0xFF2DD4BF),
                  labelStyle: TextStyle(color: selectedVibe == vibe ? Colors.black : Colors.white),
                )
              ).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Preferred Busyness', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['Quiet', 'Moderate', 'Busy'].map((level) => 
                ChoiceChip(
                  label: Text(level),
                  selected: selectedBusyness == level,
                  onSelected: (selected) => setState(() => selectedBusyness = level),
                  selectedColor: const Color(0xFF2DD4BF),
                  labelStyle: TextStyle(color: selectedBusyness == level ? Colors.black : Colors.white),
                )
              ).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Venue Categories', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['BAR', 'RESTAURANT', 'CLUB', 'CASINO'].map((cat) => 
                FilterChip(
                  label: Text(cat),
                  selected: selectedCategories.contains(cat),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) selectedCategories.add(cat); else selectedCategories.remove(cat);
                    });
                  },
                  selectedColor: const Color(0xFF2DD4BF),
                  labelStyle: TextStyle(color: selectedCategories.contains(cat) ? Colors.black : Colors.white),
                )
              ).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DD4BF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: const Text('Save Preferences', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePreferences() async {
    final repository = ref.read(userRepositoryProvider);
    try {
      final result = await repository.updatePreferences({
        'preferredVibe': selectedVibe.toUpperCase(),
        'preferredBusyness': selectedBusyness.toUpperCase(),
        'preferredCategories': selectedCategories.toList(),
      });

      if (mounted) {
        result.when(
          success: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Preferences saved'), backgroundColor: Colors.green),
            );
            context.go('/home');
          },
          failure: (error) {
            if (error.contains('401') || error.contains('Unauthorized')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Session expired. Please login again.'), backgroundColor: Colors.red),
              );
              context.go('/login');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
              );
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
