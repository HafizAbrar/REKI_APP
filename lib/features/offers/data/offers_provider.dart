import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/offer.dart';
import '../../../core/network/venue_api_service.dart';
import '../../../core/services/offer_repository.dart';

final offersProvider = FutureProvider<List<Offer>>((ref) async {
  final result = await ref.read(offerRepositoryProvider).getAllOffers();
  return result.when(success: (o) => o, failure: (e) => throw Exception(e));
});

// GET /venues/{id}/offers
final venueOffersProvider = FutureProvider.family<List<Offer>, String>((ref, venueId) async {
  final raw = await ref.read(venueApiServiceProvider).getVenueOffers(venueId);
  return raw.map((json) => Offer.fromJson(json)).toList();
});

final venueOffersFilterProvider = FutureProvider.family<List<Offer>, String?>((ref, venueId) async {
  if (venueId == null || venueId.isEmpty) {
    final result = await ref.read(offerRepositoryProvider).getAllOffers();
    return result.when(success: (o) => o, failure: (e) => throw Exception(e));
  }
  final result = await ref.read(offerRepositoryProvider).getOffersByVenue(venueId);
  return result.when(success: (o) => o, failure: (e) => throw Exception(e));
});
