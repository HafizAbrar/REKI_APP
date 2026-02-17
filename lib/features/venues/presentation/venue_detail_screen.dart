import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VenueDetailScreen extends ConsumerWidget {
  final String venueId;
  
  const VenueDetailScreen({Key? key, required this.venueId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Hero Image Section
                Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAWj1sMQoPVSfhXnEG7OuqB4CEK3bZlgZUAwXRW13Rn672FDOro_nODneU4TxUfPemTMqdhSJch8zEox7Lt8MVnP9UqbNMJFgHO5VuZnBHUUCWe2Sjw44Z4rsKunVu43eXj4-1uxw2aSeAF3bbydv8xbWBbISdVfrb4kXRK_eo6ownuzNoGroY4BujjrgJifoqoqxf9g9wVF1oyVMLQo0J9u_K7aAe3rTZmtzZpJb3-d75uoHJuixKkZ8ItKl9_XQqcOhePuRRau5Y-'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0xFF0F172A).withOpacity(0.6),
                              Color(0xFF0F172A),
                            ],
                            stops: [0.0, 0.7, 1.0],
                          ),
                        ),
                      ),
                      // Header Buttons
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildHeaderButton(Icons.arrow_back, () => Navigator.pop(context)),
                            Row(
                              children: [
                                _buildHeaderButton(Icons.ios_share, () {}),
                                SizedBox(width: 12),
                                _buildHeaderButton(Icons.favorite_border, () {}),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Venue Info Card
                      Positioned(
                        bottom: -24,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          margin: EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Color(0xFF1E293B).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'The Alchemist',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF2DD4BF).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Color(0xFF2DD4BF).withOpacity(0.2)),
                                    ),
                                    child: Text(
                                      '£££',
                                      style: TextStyle(
                                        color: Color(0xFF2DD4BF),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Color(0xFF2DD4BF), size: 16),
                                  SizedBox(width: 4),
                                  Text('4.5', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 4),
                                  Text('(128)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                                  SizedBox(width: 8),
                                  Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle)),
                                  SizedBox(width: 8),
                                  Text('Spinningfields', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                                  SizedBox(width: 8),
                                  Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle)),
                                  SizedBox(width: 8),
                                  Text('0.2 mi', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                                ],
                              ),
                              SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                children: [
                                  _buildTag('Cocktails'),
                                  _buildTag('Chemistry'),
                                  _buildTag('Molecular'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 48),
                // Content Sections
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Live Vibe Check
                      _buildVibeSection(),
                      SizedBox(height: 32),
                      // Exclusive Offer
                      _buildOfferSection(),
                      SizedBox(height: 32),
                      // About Section
                      _buildAboutSection(),
                      SizedBox(height: 32),
                      // Location Section
                      _buildLocationSection(context),
                      SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Fixed Bottom Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F172A).withOpacity(0),
                    Color(0xFF0F172A).withOpacity(0.95),
                    Color(0xFF0F172A),
                  ],
                ),
              ),
              child: SafeArea(
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(0xFF2DD4BF),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF2DD4BF).withOpacity(0.3),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.redeem, color: Color(0xFF0F172A)),
                          SizedBox(width: 8),
                          Text(
                            'Redeem Offer Now',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Color(0xFFCFFAFE),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildVibeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Vibe Check',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color(0xFF2DD4BF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'High Energy',
                      style: TextStyle(color: Color(0xFF2DD4BF), fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              '85% Capacity',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.85,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D9488), Color(0xFF2DD4BF)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF2DD4BF).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Updated 5m ago by REKI users',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildOfferSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2DD4BF), Color(0xFF0EA5E9)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(1),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1E293B).withOpacity(0.95),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2DD4BF).withOpacity(0.2), Color(0xFF0EA5E9).withOpacity(0.2)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Icon(Icons.local_bar, color: Color(0xFF2DD4BF), size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(0xFF2DD4BF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'EXCLUSIVE',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Free "Colour Changing One"',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Get a complimentary distinct appetizer cocktail with your first round of drinks.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Color(0xFFCFFAFE), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Valid until 10 PM tonight',
                        style: TextStyle(color: Color(0xFFCFFAFE), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Masters in the dark arts of molecular mixology and demons in the kitchen. The Alchemist Spinningfields is a cocktail bar & restaurant that celebrates the unconventional, dark, and controversial. Prepare for a theatrical experience.',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            color: Color(0xFF1E293B),
          ),
          child: Column(
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuADhzm8lWPGb7TipwGJX4Ls1SLwHuj6L8RtO3u72yLx2v9vV38ulG_1454dOG8lUuYxKNdgEBz0RiCq0Zqb_rEC-wyBzFs1HsnrM7V8BQh__9ZBQbg-IgkUPB-qKhXwSkgjlYSp20fSAvJYjoLs4ORpNf8wKExp4GuxT0lz-PStkyKnVoYU0sxgw4paMzbViNDwUjLjdc_P2WiEz_AKXwAKryxZw28TqR1GhQMGVxRvCA5WXwW_k4neVoeq8cHuYi_fmYAjywTOGxQF'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xFF1E293B).withOpacity(0.6)],
                        ),
                      ),
                    ),
                    Center(
                      child: TweenAnimationBuilder(
                        duration: Duration(seconds: 2),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, -10 * (1 - value).abs()),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Color(0xFF2DD4BF),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF2DD4BF).withOpacity(0.6),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                              child: Icon(Icons.location_on, color: Colors.black, size: 16),
                            ),
                          );
                        },
                        onEnd: () {},
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3 Hardman Street',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Spinningfields, Manchester, M3 3HF',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        ),
                      ],
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => GoRouter.of(context).push('/map'),
                          child: Icon(Icons.directions, color: Color(0xFF2DD4BF)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}