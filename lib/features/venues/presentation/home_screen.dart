import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, left: 16, right: 16, bottom: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF1E293B).withOpacity(0.75),
                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08), width: 1)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Color(0xFF2DD4BF).withOpacity(0.5), width: 2),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  'https://i.pravatar.cc/150?img=1',
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 40,
                                    height: 40,
                                    color: Color(0xFF2DD4BF),
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Color(0xFF2DD4BF),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Color(0xFF0F172A), width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LOCATION',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Manchester, UK',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Icon(Icons.expand_more, color: Colors.white, size: 18),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildHeaderButton(Icons.search),
                        SizedBox(width: 8),
                        _buildHeaderButton(Icons.tune),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Filter Tabs
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildTab('Trending', Icons.local_fire_department, 0),
                                SizedBox(width: 8),
                                _buildTab('Bars', Icons.local_bar, 1),
                                SizedBox(width: 8),
                                _buildTab('Food', Icons.restaurant, 2),
                                SizedBox(width: 8),
                                _buildTab('Clubs', Icons.music_note, 3),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildVenueCard(
                        name: 'The Alchemist',
                        subtitle: 'Molecular Mixology • Spinningfields',
                        statusLabel: '90% Full',
                        statusColor: Colors.red,
                        vibeLabel: 'Glamorous',
                        waitTime: '~25m',
                        offerTitle: 'ACTIVE OFFER',
                        offerDescription: '2-for-1 Cocktails until 7pm',
                        isBookmarked: true,
                      ),
                      SizedBox(height: 24),
                      _buildVenueCard(
                        name: 'Albert\'s Schloss',
                        subtitle: 'Bier Halle • Peter Street',
                        statusLabel: 'Line at Door',
                        statusColor: Colors.orange,
                        statusIcon: Icons.groups,
                        vibeLabel: 'Live Music',
                        vibeIcon: Icons.music_note,
                        vibeScore: '9.8/10',
                        vibeTags: ['Loud', 'Energetic', 'Table Dancing'],
                        isBookmarked: false,
                      ),
                      SizedBox(height: 24),
                      _buildVenueCard(
                        name: 'Northern Monk',
                        subtitle: 'Taproom • Northern Quarter',
                        statusLabel: 'Plenty of Space',
                        statusColor: Colors.green,
                        statusIcon: Icons.chair,
                        vibeLabel: 'Chill',
                        noiseLevel: 'Low',
                        offerTitle: 'UPCOMING',
                        offerDescription: 'Quiz Night starts at 8pm',
                        offerIcon: Icons.calendar_month,
                        offerColor: Color(0xFFBAE6FD),
                        isBookmarked: false,
                      ),
                      SizedBox(height: 32),
                      Container(
                        height: 4,
                        width: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bottom Navigation
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(maxWidth: 360),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF1E293B).withOpacity(0.75),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(Icons.home, 0),
                    _buildNavItem(Icons.map, 1),
                    _buildNavItem(Icons.favorite, 2, hasNotification: true),
                    _buildNavItem(Icons.person, 3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (icon == Icons.tune) {
              context.push('/filters');
            }
          },
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildTab(String label, IconData icon, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2DD4BF) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Color(0xFF2DD4BF).withOpacity(0.25),
              blurRadius: 16,
            ),
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xFF0F172A) : Color(0xFFCBD5E1),
              size: 18,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Color(0xFF0F172A) : Color(0xFFCBD5E1),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueCard({
    required String name,
    required String subtitle,
    String? statusLabel,
    Color? statusColor,
    IconData? statusIcon,
    String? vibeLabel,
    IconData? vibeIcon,
    String? waitTime,
    String? vibeScore,
    String? noiseLevel,
    List<String>? vibeTags,
    String? offerTitle,
    String? offerDescription,
    IconData? offerIcon,
    Color? offerColor,
    required bool isBookmarked,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image Section
          Stack(
            children: [
              Container(
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  child: Image.network(
                    name == 'The Alchemist' 
                        ? 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=800'
                        : name == 'Albert\'s Schloss'
                            ? 'https://images.unsplash.com/photo-1470337458703-46ad1756a187?w=800'
                            : 'https://images.unsplash.com/photo-1572116469696-31de0f17cc34?w=800',
                    width: double.infinity,
                    height: 280,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 280,
                      color: Color(0xFF334155),
                      child: Center(
                        child: Icon(Icons.image, size: 60, color: Color(0xFF64748B)),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xFF0F172A).withOpacity(0.9),
                    ],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
              // Status and Vibe Tags
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (statusLabel != null) ...[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (statusColor ?? Colors.red).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (statusIcon != null)
                                    Icon(statusIcon, color: Colors.white, size: 14)
                                  else
                                    Stack(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.75),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  SizedBox(width: 6),
                                  Text(
                                    statusLabel,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                          ],
                          if (vibeLabel != null)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (vibeIcon != null) ...[ 
                                    Icon(vibeIcon, color: Colors.white, size: 14),
                                    SizedBox(width: 6),
                                  ],
                                  Text(
                                    vibeLabel,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isBookmarked
                            ? Color(0xFF2DD4BF).withOpacity(0.9)
                            : Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border: isBookmarked
                            ? null
                            : Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        boxShadow: isBookmarked ? [
                          BoxShadow(
                            color: Color(0xFF2DD4BF).withOpacity(0.2),
                            blurRadius: 16,
                          ),
                        ] : [],
                      ),
                      child: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? Color(0xFF0F172A) : Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Content Section
          Padding(
            padding: EdgeInsets.all(20),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1E293B).withOpacity(0.75),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (waitTime != null || vibeScore != null || noiseLevel != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              waitTime != null
                                  ? 'Wait Time'
                                  : vibeScore != null
                                      ? 'Vibe Score'
                                      : 'Noise Level',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              waitTime ?? vibeScore ?? noiseLevel ?? '',
                              style: TextStyle(
                                color: vibeScore != null ? Color(0xFF4ADE80) : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (vibeTags != null && vibeTags.isNotEmpty) ...[
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: vibeTags.map((tag) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                  if (offerDescription != null) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: (offerColor ?? Color(0xFF2DD4BF)).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              offerIcon ?? Icons.local_activity,
                              color: offerColor ?? Color(0xFF2DD4BF),
                              size: 18,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offerTitle ?? 'ACTIVE OFFER',
                                  style: TextStyle(
                                    color: offerColor ?? Color(0xFF2DD4BF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  offerDescription,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, {bool hasNotification = false}) {
    bool isActive = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedNavIndex = index);
        if (index == 1) { // Map icon
          context.push('/map');
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Color(0xFF2DD4BF) : Color(0xFF94A3B8),
                size: 24,
              ),
              if (isActive)
                Container(
                  margin: EdgeInsets.only(top: 4),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Color(0xFF2DD4BF),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          if (hasNotification)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFF0F172A), width: 2),
                ),
                child: Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}