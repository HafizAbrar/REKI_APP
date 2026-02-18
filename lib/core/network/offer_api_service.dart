import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/offer.dart';
import 'api_client.dart';

final offerApiServiceProvider = Provider<OfferApiService>((ref) {
  return OfferApiService(ref.read(apiClientProvider));
});

class OfferApiService {
  final Dio _dio;

  OfferApiService(this._dio);

  Future<List<Offer>> getAllOffers() async {
    final response = await _dio.get('/offers');
    return (response.data as List).map((json) => Offer.fromJson(json)).toList();
  }

  Future<Offer> createOffer(Map<String, dynamic> offerData) async {
    final response = await _dio.post('/offers', data: offerData);
    return Offer.fromJson(response.data);
  }

  Future<List<Offer>> getOffersByVenue(String venueId) async {
    final response = await _dio.get('/offers/by-venue/$venueId');
    return (response.data as List).map((json) => Offer.fromJson(json)).toList();
  }

  Future<Offer> getOfferById(String id) async {
    final response = await _dio.get('/offers/$id');
    return Offer.fromJson(response.data);
  }

  Future<Map<String, dynamic>> redeemOffer(String offerId) async {
    final response = await _dio.post('/offers/redeem', data: {'offerId': offerId});
    return response.data;
  }

  Future<Offer> markOfferViewed(String id) async {
    final response = await _dio.patch('/offers/$id/view');
    return Offer.fromJson(response.data);
  }

  Future<Offer> markOfferClicked(String id) async {
    final response = await _dio.patch('/offers/$id/click');
    return Offer.fromJson(response.data);
  }

  Future<Map<String, dynamic>> getOfferStats(String id) async {
    final response = await _dio.get('/offers/$id/stats');
    return response.data;
  }

  Future<Offer> updateOfferStatus(String id, bool isActive) async {
    final response = await _dio.patch('/offers/$id/status', data: {'isActive': isActive});
    return Offer.fromJson(response.data);
  }
}
