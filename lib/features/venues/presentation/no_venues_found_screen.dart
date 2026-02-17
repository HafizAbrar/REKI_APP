import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoVenuesFoundScreen extends StatelessWidget {
  const NoVenuesFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1618),
      body: Container(
        constraints: const BoxConstraints(maxWidth: 384),
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1618),
          border: Border.symmetric(
            vertical: BorderSide(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1618).withOpacity(0.8),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(right: 40),
                      child: const Text(
                        'Search Results',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: Stack(
                children: [
                  // Background gradients
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.5,
                    left: MediaQuery.of(context).size.width * 0.5,
                    child: Transform.translate(
                      offset: Offset(-144, -144),
                      child: Container(
                        width: 288,
                        height: 288,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF008080).withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.33,
                    left: MediaQuery.of(context).size.width * 0.33,
                    child: Transform.translate(
                      offset: Offset(-96, -96),
                      child: Container(
                        width: 192,
                        height: 192,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF00FFFF).withOpacity(0.05),
                              Colors.transparent,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 320),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon section
                          Container(
                            margin: const EdgeInsets.only(bottom: 40),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer ring
                                Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF008080).withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                // Main container
                                Container(
                                  width: 144,
                                  height: 144,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.05),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 20,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.location_off,
                                    color: Color(0xFF008080),
                                    size: 68,
                                  ),
                                ),
                                // Small explore icon
                                Positioned(
                                  bottom: 16,
                                  right: 16,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 10,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.explore,
                                      color: Color(0xFF00FFFF),
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Text section
                          Container(
                            margin: const EdgeInsets.only(bottom: 40),
                            child: const Column(
                              children: [
                                Text(
                                  'No venues nearby',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'It\'s quiet in Manchester right now. Try adjusting your filters or checking a different area for better vibes.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Buttons section
                          Column(
                            children: [
                              // Clear filters button
                              Container(
                                width: double.infinity,
                                height: 56,
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Clear filters logic
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF008080),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shadowColor: const Color(0xFF14B8A6).withOpacity(0.2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Clear All Filters',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.filter_list_off,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Explore button
                              Container(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.go('/home');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.05),
                                    foregroundColor: const Color(0xFF00FFFF),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Explore Manchester',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom navigation
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0C1A1C).withOpacity(0.95),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNavItem(Icons.explore, 'Discover', false, () => context.go('/home')),
                        _buildNavItem(Icons.map, 'Map', false, () => context.go('/map')),
                        _buildNavItem(Icons.confirmation_number, 'Offers', false, () {}),
                        _buildNavItem(Icons.person_2, 'Profile', false, () {}),
                      ],
                    ),
                  ),
                  Container(
                    height: 4,
                    color: const Color(0xFF0C1A1C),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        child: Column(
          children: [
            Container(
              height: 28,
              child: Icon(
                icon,
                size: 26,
                color: isActive 
                  ? const Color(0xFF00FFFF)
                  : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: isActive 
                  ? const Color(0xFF00FFFF)
                  : const Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}