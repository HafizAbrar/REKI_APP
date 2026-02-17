import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MapViewScreen extends ConsumerStatefulWidget {
  const MapViewScreen({Key? key}) : super(key: key);
  
  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Map Background with exact styling
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF334155),
                image: DecorationImage(
                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuADhzm8lWPGb7TipwGJX4Ls1SLwHuj6L8RtO3u72yLx2v9vV38ulG_1454dOG8lUuYxKNdgEBz0RiCq0Zqb_rEC-wyBzFs1HsnrM7V8BQh__9ZBQbg-IgkUPB-qKhXwSkgjlYSp20fSAvJYjoLs4ORpNf8wKExp4GuxT0lz-PStkyKnVoYU0sxgw4paMzbViNDwUjLjdc_P2WiEz_AKXwAKryxZw28TqR1GhQMGVxRvCA5WXwW_k4neVoeq8cHuYi_fmYAjywTOGxQF'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Top gradient
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F172A), Colors.transparent],
                ),
              ),
            ),
            // Bottom gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 256,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFF0F172A), Colors.transparent],
                  ),
                ),
              ),
            ),
            // Map Pins
            _buildMainPin(),
            _buildSecondaryPin(
              top: MediaQuery.of(context).size.height * 0.30,
              left: MediaQuery.of(context).size.width * 0.65,
              label: 'N. Quarter',
            ),
            _buildSecondaryPin(
              top: MediaQuery.of(context).size.height * 0.55,
              left: MediaQuery.of(context).size.width * 0.25,
              label: 'Deansgate',
              icon: Icons.wine_bar,
            ),
            _buildSmallPin(
              top: MediaQuery.of(context).size.height * 0.25,
              left: MediaQuery.of(context).size.width * 0.80,
            ),
            // Top Content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar and Filter Button
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Color(0xFF1E293B).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 16),
                                Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Find vibes in MCR...',
                                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(0xFF1E293B).withOpacity(0.85),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Icon(Icons.tune, color: Color(0xFFCFFAFE), size: 20),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Filter Tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterTab('Trending', Icons.local_fire_department, 0, true),
                          SizedBox(width: 8),
                          _buildFilterTab('Nightlife', Icons.nightlife, 1, false),
                          SizedBox(width: 8),
                          _buildFilterTab('Food', Icons.restaurant, 2, false),
                          SizedBox(width: 8),
                          _buildFilterTab('Live Music', Icons.music_note, 3, false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Content
            Positioned(
              bottom: 96,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Action Buttons
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Color(0xFF1E293B).withOpacity(0.85),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Icon(Icons.my_location, color: Color(0xFF2DD4BF), size: 20),
                        ),
                      ],
                    ),
                  ),
                  // Venue Card
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E293B).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCwsmWmZdsuArJasbUfSIxFDWkYc_jJXd2bR8wCBdiNuizMaBZOzroQqdqGLuFpCt0p8Gl-g17PnKgHvdLrq90gS3b-mYFVCQhm8yJgmy-l6CC4GLXZGY4s2cQyvjYJrEK14DV-g5S0pvgVcOGwLRmDsYOv7lE-RlsX1pAbEUZxGQ8p5BYo__7zYVD8vFlS7s_hG5j2O6YKkiSDTcqKYB2KtlXq81_WsZoLstZzxM4ZkGyL-WQvZPJnnf4r78ebOixpihaNc1RGu027'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Freight Island',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.star, color: Color(0xFF2DD4BF), size: 16),
                                          SizedBox(width: 4),
                                          Text(
                                            '4.8',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.local_fire_department, color: Color(0xFF2DD4BF), size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'Very Busy Now',
                                        style: TextStyle(
                                          color: Color(0xFF2DD4BF),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '11 Baring St, Manchester',
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildTag('Industrial'),
                                      SizedBox(width: 6),
                                      _buildTag('Food Hall'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xFF2DD4BF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Check In',
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, color: Color(0xFF0F172A), size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF1E293B).withOpacity(0.85),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavItem(Icons.map, 'Map', true),
                      _buildNavItem(Icons.bolt, 'Feed', false),
                      _buildNavItem(Icons.account_circle, 'Profile', false),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainPin() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.45,
      left: MediaQuery.of(context).size.width * 0.55,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing ring
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2DD4BF).withOpacity(0.75),
                ),
              ),
              // Main pin
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(0xFF2DD4BF),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2DD4BF).withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: Color(0xFF0F172A),
                  size: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFF1E293B).withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Text(
              'Freight Island',
              style: TextStyle(
                color: Color(0xFFCFFAFE),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryPin({
    required double top,
    required double left,
    required String label,
    IconData? icon,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          Container(
            width: icon != null ? 24 : 20,
            height: icon != null ? 24 : 20,
            decoration: BoxDecoration(
              color: icon != null ? Color(0xFF1E293B) : Color(0xFF1E293B),
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFF2DD4BF), width: 2),
            ),
            child: icon != null
                ? Icon(icon, color: Color(0xFF2DD4BF), size: 14)
                : null,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallPin({required double top, required double left}) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, IconData icon, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2DD4BF) : Color(0xFF1E293B).withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Color(0xFF2DD4BF).withOpacity(0.3),
              blurRadius: 10,
            ),
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xFF0F172A) : Color(0xFFCFFAFE),
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Color(0xFF0F172A) : Color(0xFFCFFAFE),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Color(0xFFCFFAFE).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Color(0xFFCFFAFE).withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Color(0xFFCFFAFE),
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (label == 'Feed') {
          context.go('/home');
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? Color(0xFF2DD4BF).withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isActive ? Color(0xFF2DD4BF) : Color(0xFF94A3B8),
              size: 24,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}