import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VenueFilterScreen extends ConsumerStatefulWidget {
  const VenueFilterScreen({Key? key}) : super(key: key);
  
  @override
  ConsumerState<VenueFilterScreen> createState() => _VenueFilterScreenState();
}

class _VenueFilterScreenState extends ConsumerState<VenueFilterScreen> {
  String selectedBusyness = 'Moderate';
  Set<String> selectedVibes = {'Cocktails 🍸', 'Rooftop 🌇'};
  bool offersOnly = false;
  String selectedSort = 'Distance (Nearest)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Column(
        children: [
          // Handle
          Container(
            padding: EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              height: 6,
              width: 48,
              decoration: BoxDecoration(
                color: Color(0xFF334155),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  'Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF1E293B),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Busyness Section
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How busy is it?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              _buildBusynessOption('Quiet'),
                              _buildBusynessOption('Moderate'),
                              _buildBusynessOption('Busy'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    color: Color(0xFF1E293B),
                  ),
                  // Vibe Section
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What\'s the vibe?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildVibeChip('Cocktails 🍸'),
                            _buildVibeChip('Date Night ❤️'),
                            _buildVibeChip('Pub 🍺'),
                            _buildVibeChip('Rooftop 🌇'),
                            _buildVibeChip('Live Music 🎸'),
                            _buildVibeChip('Chill ☕'),
                            _buildVibeChip('Industrial 🏭'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    color: Color(0xFF1E293B),
                  ),
                  // Offers Section
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Offers Available',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Show only venues with active deals',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: offersOnly,
                          onChanged: (value) => setState(() => offersOnly = value),
                          activeColor: Color(0xFF14B8A6),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Color(0xFF1E293B),
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    color: Color(0xFF1E293B),
                  ),
                  // Sort Section
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sort by',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Column(
                          children: [
                            _buildSortOption('Distance (Nearest)', Icons.location_on),
                            SizedBox(height: 8),
                            _buildSortOption('Trending', Icons.trending_up),
                            SizedBox(height: 8),
                            _buildSortOption('Top Rated', Icons.star),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A).withOpacity(0),
              Color(0xFF0F172A),
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Color(0xFF14B8A6),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF14B8A6).withOpacity(0.3),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => context.go('/venues'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Apply Filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '12',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBusynessOption(String option) {
    bool isSelected = selectedBusyness == option;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedBusyness = option),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF14B8A6) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            option,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVibeChip(String vibe) {
    bool isSelected = selectedVibes.contains(vibe);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedVibes.remove(vibe);
          } else {
            selectedVibes.add(vibe);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF14B8A6) : Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Color(0xFF14B8A6)) : null,
          boxShadow: isSelected ? [
            BoxShadow(
              color: Color(0xFF14B8A6).withOpacity(0.2),
              blurRadius: 8,
            ),
          ] : [],
        ),
        child: Text(
          vibe,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String option, IconData icon) {
    bool isSelected = selectedSort == option;
    return GestureDetector(
      onTap: () => setState(() => selectedSort = option),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFF1E293B).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF14B8A6) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xFF14B8A6) : Color(0xFF94A3B8),
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Color(0xFF14B8A6) : Color(0xFF64748B),
                  width: 2,
                ),
                color: isSelected ? Color(0xFF14B8A6) : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      selectedBusyness = 'Moderate';
      selectedVibes = {'Cocktails 🍸', 'Rooftop 🌇'};
      offersOnly = false;
      selectedSort = 'Distance (Nearest)';
    });
  }
}