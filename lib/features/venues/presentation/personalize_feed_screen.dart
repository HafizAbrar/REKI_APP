import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PersonalizeFeedScreen extends StatefulWidget {
  const PersonalizeFeedScreen({super.key});
  
  @override
  State<PersonalizeFeedScreen> createState() => _PersonalizeFeedScreenState();
}

class _PersonalizeFeedScreenState extends State<PersonalizeFeedScreen> {
  String selectedVibe = 'Party';
  String selectedLocation = 'Northern Quarter';
  double busynessLevel = 0.75;
  Set<String> selectedInterests = {'Cocktails', 'Rooftop'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Column(
            children: [
              // Custom App Bar
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
                      onTap: () => _resetPreferences(),
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
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
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
                          'Select your vibe and we\'ll handle the rest.',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Vibe Selection
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
                        child: Row(
                          children: [
                            _buildVibeCard('Chill', Icons.nightlight_round, selectedVibe == 'Chill'),
                            const SizedBox(width: 12),
                            _buildVibeCard('Party', Icons.celebration, selectedVibe == 'Party'),
                            const SizedBox(width: 12),
                            _buildVibeCard('Romantic', Icons.favorite, selectedVibe == 'Romantic'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Location Selection
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Where in MCR?',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _buildLocationChip('Northern Quarter', selectedLocation == 'Northern Quarter'),
                            const SizedBox(width: 12),
                            _buildLocationChip('Ancoats', selectedLocation == 'Ancoats'),
                            const SizedBox(width: 12),
                            _buildLocationChip('Spinningfields', selectedLocation == 'Spinningfields'),
                            const SizedBox(width: 12),
                            _buildLocationChip('Deansgate', selectedLocation == 'Deansgate'),
                            const SizedBox(width: 12),
                            _buildLocationChip('Oxford Rd', selectedLocation == 'Oxford Rd'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Busyness Level
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'How busy?',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _getBusynessLabel(),
                              style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          height: 48,
                          child: Stack(
                            children: [
                              Positioned(
                                top: 23,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF334155),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: busynessLevel,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF64748B), Color(0xFF2DD4BF)],
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: (MediaQuery.of(context).size.width - 32) * busynessLevel - 16,
                                top: 15,
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    final RenderBox box = context.findRenderObject() as RenderBox;
                                    final localPosition = box.globalToLocal(details.globalPosition);
                                    final newValue = (localPosition.dx - 16) / (MediaQuery.of(context).size.width - 64);
                                    setState(() {
                                      busynessLevel = newValue.clamp(0.0, 1.0);
                                    });
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF2DD4BF), width: 4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF2DD4BF).withOpacity(0.6),
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF2DD4BF),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Quiet', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
                            Text('Lively', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
                            Text('Buzzing', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Interests
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'What are you into?',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildInterestChip('Cocktails', Icons.local_bar, selectedInterests.contains('Cocktails')),
                            _buildInterestChip('Live Jazz', null, selectedInterests.contains('Live Jazz')),
                            _buildInterestChip('Rooftop', Icons.deck, selectedInterests.contains('Rooftop')),
                            _buildInterestChip('Speakeasy', null, selectedInterests.contains('Speakeasy')),
                            _buildInterestChip('Craft Beer', null, selectedInterests.contains('Craft Beer')),
                            _buildInterestChip('Late Night Food', null, selectedInterests.contains('Late Night Food')),
                            _buildInterestChip('Dive Bar', null, selectedInterests.contains('Dive Bar')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120), // Space for fixed button
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Fixed Bottom Button
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
                    onTap: () => context.go('/home'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Find My Vibe',
                            style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              '12 Venues',
                              style: TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
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

  String _getBusynessLabel() {
    if (busynessLevel < 0.33) return 'Quiet';
    if (busynessLevel < 0.66) return 'Lively';
    return 'Buzzing';
  }

  void _resetPreferences() {
    setState(() {
      selectedVibe = 'Party';
      selectedLocation = 'Northern Quarter';
      busynessLevel = 0.75;
      selectedInterests = {'Cocktails', 'Rooftop'};
    });
  }

  Widget _buildVibeCard(String label, IconData icon, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedVibe = label),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: const Color(0xFF2DD4BF), width: 4) : Border.all(color: Colors.transparent, width: 2),
            boxShadow: isSelected ? [
              BoxShadow(
                color: const Color(0xFF2DD4BF).withOpacity(0.4),
                blurRadius: 20,
              ),
            ] : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isSelected
                          ? [Colors.transparent, const Color(0xFF2DD4BF).withOpacity(0.85)]
                          : [Colors.transparent, const Color(0xFF0F172A).withOpacity(0.9)],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2DD4BF).withOpacity(0.2) : Colors.black.withOpacity(0.2),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2DD4BF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'SELECTED',
                        style: TextStyle(color: Color(0xFF0F172A), fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Icon(icon, color: Colors.white, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedLocation = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2DD4BF) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(25),
          border: isSelected ? Border.all(color: const Color(0xFF2DD4BF)) : Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF2DD4BF).withOpacity(0.2),
              blurRadius: 12,
            ),
          ] : [],
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

  Widget _buildInterestChip(String label, IconData? icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedInterests.remove(label);
          } else {
            selectedInterests.add(label);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2DD4BF).withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFF2DD4BF).withOpacity(0.5) : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? const Color(0xFF14B8A6) : const Color(0xFF64748B),
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF14B8A6) : const Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}