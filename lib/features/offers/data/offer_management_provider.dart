import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/offer.dart';
import '../../../core/services/offer_repository.dart';

final offerManagementProvider = StateNotifierProvider<OfferManagementNotifier, AsyncValue<List<Offer>>>((ref) {
  return OfferManagementNotifier(ref.read(offerRepositoryProvider));
});

class OfferManagementNotifier extends StateNotifier<AsyncValue<List<Offer>>> {
  final OfferRepository _repository;

  OfferManagementNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadOffers() async {
    state = const AsyncValue.loading();
    final result = await _repository.getAllOffers();
    state = result.when(
      success: (offers) => AsyncValue.data(offers),
      failure: (error) => AsyncValue.error(error, StackTrace.current),
    );
  }

  Future<bool> createOffer(Map<String, dynamic> offerData) async {
    final result = await _repository.createOffer(offerData);
    return result.when(
      success: (_) {
        loadOffers();
        return true;
      },
      failure: (_) => false,
    );
  }

  Future<bool> updateOfferStatus(String id, bool isActive) async {
    // Optimistically update the UI
    state.whenData((offers) {
      final updatedOffers = offers.map((offer) {
        if (offer.id == id) {
          return Offer(
            id: offer.id,
            title: offer.title,
            description: offer.description,
            type: offer.type,
            isActive: isActive,
            validUntil: offer.validUntil,
            terms: offer.terms,
            venue: offer.venue,
          );
        }
        return offer;
      }).toList();
      state = AsyncValue.data(updatedOffers);
    });

    final result = await _repository.updateOfferStatus(id, isActive);
    return result.when(
      success: (_) => true,
      failure: (_) {
        loadOffers(); // Reload on failure
        return false;
      },
    );
  }
}

final venueOffersProvider = FutureProvider.family<List<Offer>, String>((ref, venueId) async {
  final repository = ref.read(offerRepositoryProvider);
  final result = await repository.getOffersByVenue(venueId);
  return result.when(
    success: (offers) => offers,
    failure: (error) => throw Exception(error),
  );
});

final offerDetailProvider = FutureProvider.family<Offer, String>((ref, id) async {
  final repository = ref.read(offerRepositoryProvider);
  final result = await repository.getOfferById(id);
  return result.when(
    success: (offer) => offer,
    failure: (error) => throw Exception(error),
  );
});

final offerStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final repository = ref.read(offerRepositoryProvider);
  final result = await repository.getOfferStats(id);
  return result.when(
    success: (stats) => stats,
    failure: (error) => throw Exception(error),
  );
});
