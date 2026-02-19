import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/user_repository.dart';

class PersonalizeFeedScreen extends ConsumerStatefulWidget {
  const PersonalizeFeedScreen({super.key});
  
  @override
  ConsumerState<PersonalizeFeedScreen> createState() => _PersonalizeFeedScreenState();
}

class _PersonalizeFeedScreenState extends ConsumerState<PersonalizeFeedScreen> {
  Set<String> selectedVibes = {'PARTY'};
  String selectedBusyness = 'MODERATE';
  Set<String> selectedCategories = {'BAR', 'CLUB'};

  Future<void> _saveAndContinue() async {
    final repository = ref.read(userRepositoryProvider);
    await repository.updatePreferences({
      'preferredCategories': selectedCategories.toList(),
      'minBusyness': selectedBusyness,
      'preferredVibes': selectedVibes.toList(),
    });
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 16, right: 16, bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Personalize Feed',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        selectedVibes = {'PARTY'};
                        selectedBusyness = 'MODERATE';
                        selectedCategories = {'BAR', 'CLUB'};
                      }),
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.centerRight,
                        child: const Text('Reset', style: TextStyle(color: Color(0xFF2DD4BF), fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: RichText(
                          text: TextSpan(
                            text: 'Curate your\n',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1),
                            children: [
                              TextSpan(
                                text: 'Manchester night.',
                                style: TextStyle(
                                  color: const Color(0xFF2DD4BF),
                                  shadows: [Shadow(color: const Color(0xFF2DD4BF).withOpacity(0.3), blurRadius: 15)],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(
                          'Select your preferences and we\'ll handle the rest.',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'What\'s the vibe tonight?',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: ['SOCIAL', 'PARTY', 'ROMANTIC', 'CHILL'].map((vibe) => _buildChip(vibe, selectedVibes.contains(vibe), () {
                            setState(() {
                              if (selectedVibes.contains(vibe)) {
                                selectedVibes.remove(vibe);
                              } else {
                                selectedVibes.add(vibe);
                              }
                            });
                          })).toList(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Minimum Busyness',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 10,
                          children: ['QUIET', 'MODERATE', 'BUSY'].map((level) => _buildChip(level, selectedBusyness == level, () {
                            setState(() => selectedBusyness = level);
                          })).toList(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Venue Categories',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: ['BAR', 'CLUB', 'RESTAURANT', 'CASINO'].map((cat) => _buildChip(cat, selectedCategories.contains(cat), () {
                            setState(() {
                              if (selectedCategories.contains(cat)) {
                                selectedCategories.remove(cat);
                              } else {
                                selectedCategories.add(cat);
                              }
                            });
                          })).toList(),
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0F172A).withOpacity(0),
                    const Color(0xFF0F172A),
                    const Color(0xFF0F172A),
                  ],
                ),
              ),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF2DD4BF),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2DD4BF).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: _saveAndContinue,
                    child: const Center(
                      child: Text(
                        'Save & Continue',
                        style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2DD4BF) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(25),
          border: isSelected ? Border.all(color: const Color(0xFF2DD4BF)) : Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}