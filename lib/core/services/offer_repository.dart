import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/offer.dart';
import '../network/offer_api_service.dart';
import '../utils/result.dart';

final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  return OfferRepository(ref.read(offerApiServiceProvider));
});

class OfferRepository {
  final OfferApiService _apiService;

  OfferRepository(this._apiService);

  Future<Result<List<Offer>>> getAllOffers() async {
    try {
      final offers = await _apiService.getAllOffers();
      return Result.success(offers);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Offer>> createOffer(Map<String, dynamic> offerData) async {
    try {
      final offer = await _apiService.createOffer(offerData);
      return Result.success(offer);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<List<Offer>>> getOffersByVenue(String venueId) async {
    try {
      final offers = await _apiService.getOffersByVenue(venueId);
      return Result.success(offers);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Offer>> getOfferById(String id) async {
    try {
      final offer = await _apiService.getOfferById(id);
      return Result.success(offer);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> redeemOffer(String offerId) async {
    try {
      final result = await _apiService.redeemOffer(offerId);
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Offer>> markOfferViewed(String id) async {
    try {
      final offer = await _apiService.markOfferViewed(id);
      return Result.success(offer);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Offer>> markOfferClicked(String id) async {
    try {
      final offer = await _apiService.markOfferClicked(id);
      return Result.success(offer);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> getOfferStats(String id) async {
    try {
      final stats = await _apiService.getOfferStats(id);
      return Result.success(stats);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<Offer>> updateOfferStatus(String id, bool isActive) async {
    try {
      final offer = await _apiService.updateOfferStatus(id, isActive);
      return Result.success(offer);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
