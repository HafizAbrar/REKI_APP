import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/offers_provider.dart';
import '../../../core/services/offer_repository.dart';
import '../../../core/services/venue_repository.dart';

final allVenuesProvider = FutureProvider((ref) async {
  final result = await ref.read(venueRepositoryProvider).getAllVenues();
  return result.when(success: (v) => v, failure: (_) => []);
});

class OffersListScreen extends ConsumerStatefulWidget {
  const OffersListScreen({super.key});

  @override
  ConsumerState<OffersListScreen> createState() => _OffersListScreenState();
}

class _OffersListScreenState extends ConsumerState<OffersListScreen> {
  final Set<String> _viewedOffers = {};
  String? _selectedCategory;
  String? _selectedVenueId;

  void _markAsViewed(String offerId) {
    if (!_viewedOffers.contains(offerId)) {
      _viewedOffers.add(offerId);
      ref.read(offerRepositoryProvider).markOfferViewed(offerId);
    }
  }

  void _markAsClicked(String offerId) {
    ref.read(offerRepositoryProvider).markOfferClicked(offerId);
  }

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(allVenuesProvider);
    final offersAsync = ref.watch(venueOffersFilterProvider(_selectedVenueId));
    
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.invalidate(allVenuesProvider);
              ref.invalidate(venueOffersFilterProvider(_selectedVenueId));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E293B),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.category, color: Color(0xFF2DD4BF)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: ['Bar', 'Restaurant', 'Club', 'Cafe', 'Lounge']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _selectedCategory = v;
                    _selectedVenueId = null;
                  }),
                ),
                const SizedBox(height: 12),
                venuesAsync.when(
                  data: (venues) {
                    final filteredVenues = _selectedCategory == null
                        ? venues
                        : venues.where((v) => v.type == _selectedCategory).toList();
                    
                    return DropdownButtonFormField<String>(
                      value: _selectedVenueId,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Venue',
                        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.store, color: Color(0xFF2DD4BF)),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Venues')),
                        ...filteredVenues.map((v) => DropdownMenuItem(value: v.id, child: Text(v.name))),
                      ],
                      onChanged: (v) => setState(() => _selectedVenueId = v),
                    );
                  },
                  loading: () => const CircularProgressIndicator(color: Color(0xFF2DD4BF)),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ),
          Expanded(
            child: offersAsync.when(
              data: (offers) {
                if (offers.isEmpty) {
                  return const Center(
                    child: Text('No active offers', style: TextStyle(color: Color(0xFF94A3B8))),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    WidgetsBinding.instance.addPostFrameCallback((_) => _markAsViewed(offer.id));
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () {
                          _markAsClicked(offer.id);
                          context.push('/offer-detail?id=${offer.id}');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Padding(
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
                                      child: Text(
                                        offer.title,
                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2DD4BF))),
              error: (error, _) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.white))),
            ),
          ),
        ],
      ),
    );
  }
}
