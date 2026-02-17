import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../venues/presentation/venue_provider.dart';

class BusinessDashboardScreen extends ConsumerStatefulWidget {
  const BusinessDashboardScreen({super.key});
  
  @override
  ConsumerState<BusinessDashboardScreen> createState() => _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends ConsumerState<BusinessDashboardScreen> {
  bool _isLiveFeedEnabled = true;
  double _busynessLevel = 88.0;
  int _selectedVibe = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                            border: Border.all(color: Color(0xFFE2E8F0)),
                          ),
                          child: Icon(Icons.dashboard, color: Color(0xFF475569), size: 24),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Color(0xFF14B8A6).withOpacity(0.2), blurRadius: 10)],
                              ),
                              child: Icon(Icons.bolt, color: Colors.white, size: 20),
                            ),
                            SizedBox(width: 8),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'REKI ',
                                    style: TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Biz',
                                    style: TextStyle(
                                      color: Color(0xFF14B8A6),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                                border: Border.all(color: Color(0xFFE2E8F0)),
                              ),
                              child: Icon(Icons.notifications, color: Color(0xFF64748B), size: 24),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Venue Card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Color(0xFFF0F9FF)],
                      ),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Color(0xFFBFDBFE)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDFxzM8e4ebOKzrczUUzDrJf6jIs5FFyhoNZQv0C9PPoZV_Q1rElKn7rRApFmpc1elyJuE-gaxJmuOYmOfnNyOvsUS-i1wNp5rMXPAn3X6J1j0WCxFsWur5iRoaYmH5djIVi02mL15iQMuDd9FS9qO_3rbmIq5-HSClyA4eUZnS2AGLnWAv3PyjffBxPfKnoMMuJzkctX1KdCEhRX1EXsG-nQ4xAumiAo_WrP_iE9qTy31eGPb2tTQCy3gU6JjgB1EjxC9YAYvmPIxl'),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [BoxShadow(color: Color(0xFF14B8A6).withOpacity(0.05), blurRadius: 20)],
                              ),
                            ),
                            Positioned(
                              bottom: -4,
                              right: -4,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Color(0xFF14B8A6),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Albert's Schloss",
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Color(0xFF14B8A6), size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'MANCHESTER, UK',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Switch(
                              value: _isLiveFeedEnabled,
                              onChanged: (value) => setState(() => _isLiveFeedEnabled = value),
                              activeColor: Color(0xFF14B8A6),
                            ),
                            Text(
                              'LIVE FEED',
                              style: TextStyle(
                                color: Color(0xFF14B8A6),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Busyness Status
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.bar_chart, color: Color(0xFF14B8A6)),
                              SizedBox(width: 8),
                              Text(
                                'BUSYNESS STATUS',
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFF14B8A6).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Color(0xFF14B8A6).withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF14B8A6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Auto-updating',
                                  style: TextStyle(
                                    color: Color(0xFF14B8A6),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          border: Border.all(color: Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'MOOD',
                                      style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'ELECTRIC',
                                      style: TextStyle(
                                        color: Color(0xFF0F766E),
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'CAPACITY',
                                      style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          '88',
                                          style: TextStyle(
                                            color: Color(0xFF1E293B),
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        Text(
                                          '%',
                                          style: TextStyle(
                                            color: Color(0xFF14B8A6),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 32),
                            Stack(
                              children: [
                                Container(
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF0F9FF),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Color(0xFFBAE6FD).withOpacity(0.3)),
                                  ),
                                ),
                                Container(
                                  height: 16,
                                  width: MediaQuery.of(context).size.width * 0.88 * 0.7,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF99F6E4), Color(0xFF14B8A6), Color(0xFF0F766E)],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                Positioned(
                                  left: MediaQuery.of(context).size.width * 0.88 * 0.7 - 20,
                                  top: -12,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Color(0xFF14B8A6), width: 2),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF14B8A6),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('CHILL', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w900)),
                                Text('STEADY', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w900)),
                                Text('BUSY', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w900)),
                                Text('PACKED', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Vibe Selection
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'SET ACTIVE VIBE',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _buildVibeButton('Party', Icons.celebration, 0, true),
                            SizedBox(width: 12),
                            _buildVibeButton('Events', Icons.theater_comedy, 1, false),
                            SizedBox(width: 12),
                            _buildVibeButton('Social', Icons.local_bar, 2, false),
                            SizedBox(width: 12),
                            _buildVibeButton('Dining', Icons.dinner_dining, 3, false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Metrics
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tonight's Impact",
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(0xFF14B8A6).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFF14B8A6).withOpacity(0.1)),
                            ),
                            child: Text(
                              'Full Report',
                              style: TextStyle(
                                color: Color(0xFF14B8A6),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildMetricCard(Icons.visibility, '1.4k', 'APP VIEWS'),
                          _buildMetricCard(Icons.directions_walk, '42', 'FOOTFALL IN'),
                          _buildMetricCard(Icons.star, '4.9', 'RATING'),
                          _buildMetricCard(Icons.trending_up, '+18%', 'VS LAST WEEK'),
                        ],
                      ),
                    ],
                  ),
                ),
                // Boost Listing
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(0xFF14B8A6).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.campaign, color: Color(0xFF14B8A6), size: 32),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Boost Listing',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Get featured in Top Picks',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Color(0xFF14B8A6),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Color(0xFF14B8A6).withOpacity(0.3), blurRadius: 10)],
                          ),
                          child: Text(
                            'ACTIVATE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 120),
              ],
            ),
          ),
          // FAB
          Positioned(
            bottom: 112,
            right: 24,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Color(0xFF14B8A6).withOpacity(0.4), blurRadius: 20)],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(32),
                  onTap: () => context.push('/business-update'),
                  child: Icon(Icons.add, color: Colors.white, size: 32),
                ),
              ),
            ),
          ),
          // Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.space_dashboard, 'DASH', true, () {}),
                    _buildNavItem(Icons.calendar_today, 'EVENTS', false, () {}),
                    _buildNavItem(Icons.leaderboard, 'STATS', false, () => context.push('/manage-offers')),
                    _buildNavItem(Icons.person, 'PROFILE', false, () {}),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVibeButton(String label, IconData icon, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedVibe = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF0F766E)]) : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: Color(0xFFE2E8F0)),
          boxShadow: isSelected ? [BoxShadow(color: Color(0xFF14B8A6).withOpacity(0.3), blurRadius: 10)] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Color(0xFF14B8A6),
              size: 22,
            ),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Color(0xFF64748B),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(IconData icon, String value, String label) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFBFDBFE)),
            ),
            child: Icon(icon, color: Color(0xFF14B8A6), size: 22),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Color(0xFF14B8A6) : Color(0xFF94A3B8),
            size: 28,
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Color(0xFF14B8A6) : Color(0xFF94A3B8),
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}