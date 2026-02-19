import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/offer.dart';
import '../../../core/services/offer_repository.dart';

final offerDetailProvider = FutureProvider.family<Offer, String>((ref, id) async {
  final repository = ref.read(offerRepositoryProvider);
  final result = await repository.getOfferById(id);
  return result.when(
    success: (offer) => offer,
    failure: (error) => throw Exception(error),
  );
});
