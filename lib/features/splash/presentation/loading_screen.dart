import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class LoadingScreen extends StatefulWidget {
  final VoidCallback? onLoadingComplete;
  
  const LoadingScreen({super.key, this.onLoadingComplete});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _shimmerController;
  late AnimationController _spinController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _spinAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _progressController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _spinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.72).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );
    
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
    
    _spinAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.linear),
    );

    _startLoading();
  }

  void _startLoading() {
    _progressController.forward();
    
    Timer(const Duration(seconds: 4), () {
      if (widget.onLoadingComplete != null) {
        widget.onLoadingComplete!();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _shimmerController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [
          // Background gradients
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.1,
            left: -MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: MediaQuery.of(context).size.width * 1.5,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2DD4BF).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5,
            left: MediaQuery.of(context).size.width * 0.5,
            child: Transform.translate(
              offset: Offset(-MediaQuery.of(context).size.width * 0.4, -MediaQuery.of(context).size.height * 0.2),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFBAE6FD).withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Noise overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const NetworkImage('https://grainy-gradients.vercel.app/noise.svg'),
                  fit: BoxFit.cover,
                  opacity: 0.15,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(1.25),
                    BlendMode.multiply,
                  ),
                ),
              ),
            ),
          ),
          // Main content
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 384),
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo section
                  Container(
                    margin: const EdgeInsets.only(bottom: 56),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulsing background
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFF2DD4BF).withOpacity(0.15),
                                      Colors.transparent,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                        // Outer rings
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                              width: 1,
                            ),
                          ),
                        ),
                        Container(
                          width: 156,
                          height: 156,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        // Main logo container
                        Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0F172A).withOpacity(0.8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2DD4BF).withOpacity(0.3),
                                blurRadius: 50,
                                spreadRadius: -10,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF2DD4BF).withOpacity(0.2),
                                      const Color(0xFFBAE6FD).withOpacity(0.1),
                                    ],
                                  ),
                                ),
                              ),
                              // Background image
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: const NetworkImage(
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAZbgUqh_6AXrwjHT0MpvTjgKrb4UymE81OI6k-MPOr6Bcu009QqkbuK7cqSE7iwXabQpyN0Uj9IZ04R3I-8KVx55GtqQvyfjr61LdjPlumaYWQip_Uljd4Rn98l07cPAXIVwxTPkSi1NHNSmXbxwtcODVbi7zQCVqNfuBnKe-HWKniJTn5u2cTiuJqO-btJdzsbwh6ltlA_aP9_y6xm2qzkMP1XsYr8HF5kRAiLcBe3O-erSb5nEelKKr40xhg6FhQRtA2R3GwUYiV',
                                    ),
                                    fit: BoxFit.cover,
                                    opacity: 0.3,
                                    colorFilter: const ColorFilter.matrix([
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0, 0, 0, 1, 0,
                                    ]),
                                  ),
                                ),
                              ),
                              // Icon
                              Center(
                                child: Icon(
                                  Icons.location_searching,
                                  size: 48,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFF2DD4BF).withOpacity(0.6),
                                      blurRadius: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Title section
                  Container(
                    margin: const EdgeInsets.only(bottom: 48),
                    child: Column(
                      children: [
                        const Text(
                          'REKI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 4,
                          width: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFF2DD4BF),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress section
                  Container(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: Column(
                      children: [
                        // Progress bar
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, child) {
                                return Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: _progressAnimation.value,
                                      child: Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF2DD4BF),
                                              Color(0xFFBAE6FD),
                                              Color(0xFF2DD4BF),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF2DD4BF).withOpacity(0.4),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            AnimatedBuilder(
                                              animation: _shimmerAnimation,
                                              builder: (context, child) {
                                                return Transform.translate(
                                                  offset: Offset(
                                                    _shimmerAnimation.value * 260,
                                                    0,
                                                  ),
                                                  child: Container(
                                                    width: 60,
                                                    height: 4,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.transparent,
                                                          Colors.white.withOpacity(0.4),
                                                          Colors.transparent,
                                                        ],
                                                      ),
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        // Status section
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: _spinAnimation,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _spinAnimation.value,
                                      child: const Icon(
                                        Icons.refresh,
                                        color: Color(0xFF2DD4BF),
                                        size: 18,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Refreshing vibe data',
                                  style: TextStyle(
                                    color: Color(0xFFE2E8F0),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.05),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Color(0xFFBAE6FD),
                                    size: 14,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'MANCHESTER, UK',
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom text
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'INVESTOR PREVIEW BUILD V1.2',
                style: TextStyle(
                  color: const Color(0xFF64748B).withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}