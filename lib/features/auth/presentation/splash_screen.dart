import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.75).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF021218),
      body: Stack(
        children: [
          // Background image with overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBzborjAAdzPy8cboHGNn3vzCWGkdUZRSrVYM9692EDdSjJq3vDM0JjjzVv9I5f-vKl2tc3DMSbxe1b9IzsFl9zqjpRCkImdV8wNWbvPlYyFPQ0sFXba-ZauTeINFolzYVnqV7g3HaxopKAoTHS0GfsorznNvYR817DeueCVXm6nPeiWw_z0XnJh2ELFEwZuOVrpy_HQxUrgNJJiTkYDroXCzL6xtVt-_mwTyMMwJ-zJL7DFrF_Nbq664wqJd4ydpDZ3_kydKWqtVBL'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Radial gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.4),
                  radius: 1.2,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.25),
                    Color(0xFF021218).withOpacity(0.8),
                    Color(0xFF021218),
                  ],
                  stops: [0, 0.6, 1],
                ),
              ),
            ),
          ),
          // Linear gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF021218).withOpacity(0.3),
                    Colors.transparent,
                    Color(0xFF021218),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Spacer(flex: 1),
                  // Logo and tagline section
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Glow effect container
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.6),
                                blurRadius: 80,
                                spreadRadius: 40,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.equalizer,
                                size: 64,
                                color: AppTheme.primaryColor,
                                shadows: [
                                  Shadow(
                                    color: AppTheme.primaryColor.withOpacity(0.8),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'REKI',
                                style: TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 12.8,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.8),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32),
                        Container(
                          constraints: BoxConstraints(maxWidth: 260),
                          child: Text(
                            'Discover the vibe before you go out.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.iceBlue.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom section
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Loading vibes...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.iceBlue.withOpacity(0.7),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, child) {
                                return Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: AppTheme.iceBlue.withOpacity(0.1),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _progressAnimation.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: AppTheme.primaryColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryColor.withOpacity(0.8),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      // Get Started button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.25),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => context.go('/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF0f766e),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Location indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppTheme.iceBlue.withOpacity(0.4),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'MANCHESTER, UK',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3.2,
                              color: AppTheme.iceBlue.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
