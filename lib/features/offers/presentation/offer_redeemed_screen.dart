import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OfferRedeemedScreen extends ConsumerWidget {
  const OfferRedeemedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background with blur effect
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuA2iDO7DrwRZYBx6o5gotXGL-veXd3iHhd7Y1xpSFMHZyAZd4jEe4rPQd4pezsahPqThD_ZSvZs_TLj8QXYZ2-736l_1_TipTJLlCQCLDGU9WKli8l7GAae_SuzuVtRhVSY5eplMdSEDKtAWvHryiLM3ap5-A5rdmB6q7D1PDLti1BMN6h-n8Y0PJDTJ-I0_dMsawrvfXSxokcMrWwm5IpGns0hLUxag8u4sFfj_BPzJ2_oFA6BAn7G1onZPO586xeV-yIKKA0MEP2_'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.matrix([
                  0.3, 0.3, 0.3, 0, 0,
                  0.3, 0.3, 0.3, 0, 0,
                  0.3, 0.3, 0.3, 0, 0,
                  0, 0, 0, 0.3, 0,
                ]),
              ),
            ),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0F172A).withOpacity(0.9),
                  const Color(0xFF0F172A).withOpacity(0.95),
                  const Color(0xFF0F172A),
                ],
              ),
            ),
          ),
          // Glow effect
          Positioned(
            top: -80,
            left: MediaQuery.of(context).size.width / 2 - 160,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2DD4BF).withOpacity(0.2),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Success icon and text
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow effect
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2DD4BF),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2DD4BF).withOpacity(0.4),
                                  blurRadius: 40,
                                ),
                              ],
                            ),
                          ),
                          // Check icon
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2DD4BF).withOpacity(0.5),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 48),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "You're in!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Show this screen to the staff at The Alchemist.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Ticket card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Top section
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Venue info
                              Row(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: const DecorationImage(
                                        image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBD13F8_qqkBgcfiZTXnjdCM4HOdaEIfsrQzWAK7auvunTd43LpB9c8EwqMkDyW8X7UvIqfZJbxe9vHxqAJYWGP8yudJbhpjp7ANNiwviNlOlFiWJX-4Fx_Hq_eOrTDFzGRZAtKuEMu9Butk5VXos7ioHyELxz2mCMo6-CiTMg32Ab3pfz9IBMyDSUip7ZIGAAxGcR7_s2mKNJeC9n4f-5FuFiOHTer4ZYM1sixnbHjLiS3VR8fJ1CKABLjhEu9peI0EK6GFBv_VeXN'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'The Alchemist',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Spinningfields, MCR',
                                          style: TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.schedule, color: Color(0xFF2DD4BF), size: 14),
                                            SizedBox(width: 4),
                                            Text(
                                              'JUST NOW',
                                              style: TextStyle(
                                                color: Color(0xFF2DD4BF),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Offer details
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2DD4BF).withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF2DD4BF).withOpacity(0.2)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF2DD4BF).withOpacity(0.2),
                                            const Color(0xFFCFFAFE).withOpacity(0.2),
                                          ],
                                        ),
                                        border: Border.all(color: const Color(0xFF2DD4BF).withOpacity(0.2)),
                                      ),
                                      child: const Icon(Icons.local_bar, color: Color(0xFF2DD4BF)),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'REDEEMED OFFER',
                                            style: TextStyle(
                                              color: Color(0xFF2DD4BF),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          Text(
                                            '2-for-1 Cocktails',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                        // Dashed line with circles
                        Stack(
                          children: [
                            Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 32),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: -12,
                              top: -12,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0F172A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              right: -12,
                              top: -12,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0F172A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // QR Code section
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Color(0xFF020617),
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  width: 128,
                                  height: 128,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.qr_code_2, color: Colors.white, size: 80),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                '#REKI-8829-VIP',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Action buttons
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D9488), Color(0xFF2DD4BF)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2DD4BF).withOpacity(0.4),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () => context.go('/map'),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Back to Vibes',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.map, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {},
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'View in Wallet',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.account_balance_wallet, color: Color(0xFF94A3B8), size: 18),
                              ],
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
    );
  }
}