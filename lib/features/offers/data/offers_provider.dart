import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/offer.dart';
import '../../../core/services/offer_repository.dart';

final offersProvider = FutureProvider<List<Offer>>((ref) async {
  final repository = ref.read(offerRepositoryProvider);
  final result = await repository.getAllOffers();
  return result.when(
    success: (offers) => offers,
    failure: (error) => throw Exception(error),
  );
});
