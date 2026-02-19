import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/offer_repository.dart';

class OfferDetailScreen extends ConsumerStatefulWidget {
  final String offerId;
  
  const OfferDetailScreen({super.key, required this.offerId});
  
  @override
  ConsumerState<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends ConsumerState<OfferDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(offerRepositoryProvider).markOfferViewed(widget.offerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Hero Image Section
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAhJ9gRxclgWIAUQ-tqh4SNg9YKi8XN8XeHn5gm9-Nc_ezbcp4U7VLeVjZoJCWlaDMq-Gi8dp6s1ex3hMpOV3EwBczw7sBDNfVX3B1cdJunEKAd53MxGkW8E7OIy-2Ko2c010TkWlOqVCM8KmSmI0Gk7xGb9ABUYA_3SMqFqD2hxaQXsFxgZZcohJCsYphymmMty20LV4H8n_8tQ6Kos6KIqIMa6c9O_IBMcoinCzgY4KZhmHKk8UPBO8xOuyeKHCaTbT7mK6yQFCu4'),
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
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                              const Color(0xFF0F172A),
                            ],
                            stops: const [0.0, 0.5, 1.0],
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
                            _buildHeaderButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                            Row(
                              children: [
                                _buildHeaderButton(Icons.favorite_border, () {}),
                                const SizedBox(width: 12),
                                _buildHeaderButton(Icons.ios_share, () {}),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content Section
                Transform.translate(
                  offset: const Offset(0, -64),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 40,
                          offset: const Offset(0, -10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Handle
                        Container(
                          margin: const EdgeInsets.only(top: 16, bottom: 8),
                          width: 48,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tags
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2DD4BF).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFF2DD4BF).withOpacity(0.2)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF2DD4BF),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'LIVE NOW',
                                          style: TextStyle(
                                            color: Color(0xFF2DD4BF),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      'Beer & Cider',
                                      style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Title
                              const Text(
                                '50% Off House Lagers',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Description
                              const Text(
                                'Enjoy half-price pints of our signature house lager. Perfect for starting your night out in the Northern Quarter.',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Venue Card
                              _buildVenueCard(),
                              const SizedBox(height: 16),
                              // Validity Card
                              _buildValidityCard(),
                              const SizedBox(height: 16),
                              // Terms & Conditions
                              _buildTermsCard(),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ],
                    ),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.8),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2DD4BF),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2DD4BF).withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: _redeemOffer,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_activity, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Slide to Redeem',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Show this screen to staff to claim',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
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
          color: Colors.black.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Future<void> _redeemOffer() async {
    final repository = ref.read(offerRepositoryProvider);
    await repository.markOfferClicked(widget.offerId);
    final result = await repository.redeemOffer(widget.offerId);
    
    if (mounted) {
      result.when(
        success: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Offer redeemed successfully!')),
          );
        },
        failure: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
      );
    }
  }

  Widget _buildVenueCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAql1lPYPMrMQALe642DSTmXfCStWUWF_4ZK7DjLTNlpVn_1ToTJlIKRksASqaFmMfJnO1eoot00RtULkfMBk1_SPR9lvhMuTIWaE6EFUBFrmJyIxe9_eOQ8r3RbkhC7pYCvey7qQcwsk8DO9Ab-A-oT0GFwQhplf2D_XcRIMh-uAfIdlq6tjcs87hBcddbryEzEGY6LewHKe5zv_WTIIo0uw-8fhc110ec3_BTnOy-vE5bb_6D2A8oUOi49Hb6BeouOuAKHJ85954E'),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Color(0xFF2DD4BF), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Northern Quarter, M1',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildValidityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2DD4BF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.schedule, color: Color(0xFF2DD4BF)),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VALID UNTIL',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '10:00 PM Tonight',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: const Text(
            'Terms & Conditions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTermItem('One redemption per person per night.'),
                  _buildTermItem('Cannot be used in conjunction with other offers.'),
                  _buildTermItem('Management reserves the right to refuse service.'),
                  _buildTermItem('Must be 18+ with valid ID.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 8),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF94A3B8),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}