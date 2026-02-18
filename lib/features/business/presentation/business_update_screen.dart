import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../venues/data/venue_management_provider.dart';
import '../../../core/services/venue_repository.dart';

class BusinessUpdateScreen extends ConsumerStatefulWidget {
  const BusinessUpdateScreen({super.key});
  
  @override
  ConsumerState<BusinessUpdateScreen> createState() => _BusinessUpdateScreenState();
}

class _BusinessUpdateScreenState extends ConsumerState<BusinessUpdateScreen> {
  String _busynessLevel = 'Busy';
  final List<String> _selectedVibes = ['Cocktails', 'Good Music', 'Energetic'];
  String _venueId = '1';

  final List<String> _vibes = [
    'Cocktails',
    'Good Music',
    'Energetic',
    'Date Night',
    'Crowded',
    'Loud',
    'Dance Floor',
    'Chill',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1414),
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: 0,
            left: MediaQuery.of(context).size.width / 2 - 200,
            child: Container(
              width: 400,
              height: 320,
              decoration: BoxDecoration(
                color: const Color(0xFF008080).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              // Handle
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7FA).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF008080).withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: const DecorationImage(
                                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCiJuYyd3juLJnztwe07Z1qTPCtswFvj5KM8ZKj2v55uOEr_YCd33aXD67pL72XBloOPqrhGIWyHLA32noeZWBh6rhppSXPHt6VD7jATQIHuUGCKZHqvKPGqbnPMb6yffL6wUwXeWZtaB1aVvRz7Ex9_CXT5VyooFckJu1TWOXgqyLClaqz58UNeKGRNs60gs1qb2B7JOIYlkqicyUIsbBbMM5tZ1EYEDFjtx6MSZVXx23gSwIHq5N9buKrKBf9IKzRkBv383I2PqDw'),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(color: const Color(0xFF008080).withOpacity(0.2)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'OWNER DASHBOARD',
                            style: TextStyle(
                              color: Color(0xFF008080),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'The Alchemist',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF94A3B8), size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'Spinningfields, Manchester',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Color(0xFF94A3B8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '10:42 PM',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: Colors.white.withOpacity(0.05),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Occupancy Section
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Current Occupancy',
                                style: TextStyle(
                                  color: Color(0xFFE2E8F0),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF008080).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF008080).withOpacity(0.2)),
                                ),
                                child: Text(
                                  _busynessLevel.toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF008080),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF122020),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('QUIET', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                                    Text('MODERATE', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                                    Text('PEAK', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Stack(
                                  children: [
                                    Container(
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    Container(
                                      height: 12,
                                      width: MediaQuery.of(context).size.width * 0.72 * 0.7,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [const Color(0xFF008080).withOpacity(0.6), const Color(0xFF008080)],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF008080).withOpacity(0.2),
                                            blurRadius: 15,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      left: MediaQuery.of(context).size.width * 0.72 * 0.7 - 16,
                                      top: -10,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFF008080), width: 4),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF008080),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'STATUS UPDATE',
                                          style: TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '~ 140 Guests in venue',
                                          style: TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '72%',
                                      style: TextStyle(
                                        color: Color(0xFF008080),
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Vibe Section
                      Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Describe the Vibe',
                                style: TextStyle(
                                  color: Color(0xFFE2E8F0),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Select multiple',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _vibes.asMap().entries.map((entry) {
                              int index = entry.key;
                              String vibe = entry.value;
                              bool isSelected = _selectedVibes.contains(vibe);
                              
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedVibes.remove(vibe);
                                    } else {
                                      _selectedVibes.add(vibe);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF008080) : const Color(0xFF122020),
                                    borderRadius: BorderRadius.circular(20),
                                    border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.1)),
                                    boxShadow: isSelected ? [
                                      BoxShadow(
                                        color: const Color(0xFF008080).withOpacity(0.2),
                                        blurRadius: 10,
                                      ),
                                    ] : [],
                                  ),
                                  child: Text(
                                    vibe,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Sync info
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_user, color: Color(0xFF008080), size: 16),
                          SizedBox(width: 8),
                          Text(
                            'LIVE SYNC TO DISCOVERY FEED',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bottom Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A1414).withOpacity(0),
                    const Color(0xFF0A1414).withOpacity(0.95),
                    const Color(0xFF0A1414),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF008080),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF008080).withOpacity(0.3),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: _broadcastUpdate,
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(6),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: const Icon(Icons.refresh, color: Colors.white),
                              ),
                              const Expanded(
                                child: Text(
                                  'Broadcast Update',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 50),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'LAST UPDATED 2 MINS AGO',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
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

  Future<void> _broadcastUpdate() async {
    final success = await ref.read(venueManagementProvider.notifier).updateLiveState(
      _venueId,
      busyness: _busynessLevel,
      currentVibe: _selectedVibes.isNotEmpty ? _selectedVibes.first : null,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Update broadcasted' : 'Failed to update')),
      );
    }
  }
}