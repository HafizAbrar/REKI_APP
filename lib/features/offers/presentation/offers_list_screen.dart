import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../venues/data/venue_management_provider.dart';
import '../../../core/config/env.dart';

class OffersListScreen extends ConsumerWidget {
  const OffersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venuesAsync = ref.watch(venueManagementProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text('Active Offers', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: venuesAsync.when(
        data: (venues) {
          final venuesWithOffers = venues.where((v) => v.offers.isNotEmpty).toList();
          
          if (venuesWithOffers.isEmpty) {
            return const Center(
              child: Text('No active offers', style: TextStyle(color: Color(0xFF94A3B8))),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: venuesWithOffers.length,
            itemBuilder: (context, index) {
              final venue = venuesWithOffers[index];
              return Column(
                children: venue.offers.map((offer) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => context.push('/offer-detail?id=${offer.id}'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          if (venue.coverImageUrl != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                '${Env.apiBaseUrl}${venue.coverImageUrl}',
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 120,
                                  color: const Color(0xFF334155),
                                  child: const Icon(Icons.image, color: Color(0xFF64748B)),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2DD4BF).withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.local_activity, color: Color(0xFF2DD4BF), size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            offer.title,
                                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            venue.name,
                                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  offer.description,
                                  style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )).toList(),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2DD4BF))),
        error: (error, _) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}
