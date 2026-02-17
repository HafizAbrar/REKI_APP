import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);
  
  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF0F172A).withOpacity(0.8),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Title and Mark all read
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Notifications',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Mark all read',
                            style: TextStyle(
                              color: Color(0xFF0D9488),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Filter tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        _buildFilterTab('All', 0, true),
                        SizedBox(width: 12),
                        _buildFilterTab('Vibes', 1, false),
                        SizedBox(width: 12),
                        _buildFilterTab('Offers', 2, false),
                        SizedBox(width: 12),
                        _buildFilterTab('Social', 3, false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Notifications list
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // New section
                  _buildSectionHeader('NEW'),
                  _buildNotificationItem(
                    icon: Icons.local_fire_department,
                    iconColor: Color(0xFF0D9488),
                    iconBg: Color(0xFF0D9488).withOpacity(0.1),
                    title: "Albert's Schloss",
                    description: 'Heating up! 🔥 Current vibe: Energetic.',
                    time: '2m',
                    hasIndicator: true,
                    badge: 'Busy',
                    hasStatusIcon: true,
                  ),
                  _buildNotificationItem(
                    icon: Icons.local_offer,
                    iconColor: Color(0xFF06B6D4),
                    iconBg: Color(0xFF06B6D4).withOpacity(0.1),
                    title: '20 Stories',
                    description: 'New 2-for-1 cocktail offer live for the next hour.',
                    time: '15m',
                    hasIndicator: true,
                  ),
                  // Today section
                  _buildSectionHeader('TODAY'),
                  _buildNotificationItem(
                    icon: Icons.trending_up,
                    iconColor: Color(0xFFE11D48),
                    iconBg: Color(0xFFE11D48).withOpacity(0.1),
                    title: 'Warehouse Project',
                    description: 'Venue is at 90% capacity. Get there soon!',
                    time: '1h',
                    opacity: 0.9,
                  ),
                  _buildNotificationItem(
                    icon: Icons.face,
                    iconColor: Color(0xFF0EA5E9),
                    iconBg: Color(0xFF0EA5E9).withOpacity(0.1),
                    title: 'Impossible',
                    description: 'Your friend Sarah just checked in here.',
                    time: '3h',
                    hasStatusIcon: true,
                    statusIconColor: Color(0xFF0EA5E9),
                    opacity: 0.9,
                  ),
                  // Yesterday section
                  _buildSectionHeader('YESTERDAY'),
                  _buildNotificationItem(
                    icon: Icons.music_note,
                    iconColor: Color(0xFF6B7280),
                    iconBg: Color(0xFF374151),
                    title: 'Blues Kitchen',
                    description: 'Live jazz night starting in 30 mins.',
                    time: '1d',
                    opacity: 0.7,
                  ),
                  // End message
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Color(0xFF6B7280),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "YOU'RE ALL CAUGHT UP",
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Color(0xFF6B7280),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildFilterTab(String label, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF0D9488) : Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(18),
          border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Color(0xFF0D9488).withOpacity(0.25),
              blurRadius: 10,
            ),
          ] : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Color(0xFF0F172A).withOpacity(0.95),
      child: Text(
        title,
        style: TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String description,
    required String time,
    bool hasIndicator = false,
    bool hasStatusIcon = false,
    Color? statusIconColor,
    String? badge,
    double opacity = 1.0,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Row(
          children: [
            // Icon with status indicator
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                if (hasStatusIcon)
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Color(0xFF0F172A),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: statusIconColor ?? Color(0xFFEA580C),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(0xFF0D9488).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: Color(0xFF0D9488),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            // Time and indicator
            Column(
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                if (hasIndicator)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(0xFF0D9488),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF0D9488).withOpacity(0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: Color(0xFF0F172A).withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.explore, 'Explore', false, () => context.go('/home')),
              _buildNavItem(Icons.map, 'Map', false, () => context.go('/map')),
              _buildNavItem(Icons.notifications, 'Activity', true, () {}, hasNotification: true),
              _buildNavItem(Icons.person, 'Profile', false, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap, {bool hasNotification = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Icon(
                icon,
                color: isActive ? Color(0xFF0D9488) : Color(0xFF6B7280),
                size: 28,
              ),
              if (hasNotification)
                Positioned(
                  top: -2,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(0xFF0D9488),
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF0F172A), width: 2),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Color(0xFF0D9488) : Color(0xFF6B7280),
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}