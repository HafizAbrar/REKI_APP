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
    final data = response.data is Map
        ? (response.data['offers'] ?? response.data['data'] ?? [])
        : response.data;
    return (data as List).map((json) => Offer.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Offer> createOffer(Map<String, dynamic> offerData) async {
    final response = await _dio.post('/offers', data: offerData);
    return Offer.fromJson(response.data);
  }

  Future<List<Offer>> getOffersByVenue(String venueId) async {
    final response = await _dio.get('/offers/by-venue/$venueId');
    return (response.data as List).map((json) => Offer.fromJson(json)).toList();
  }

  // GET /offers/{id} - Get offer detail by ID
  Future<Offer> getOfferById(String id) async {
    final response = await _dio.get('/offers/$id');
    final data = response.data is Map
        ? (response.data['offer'] ?? response.data['data'] ?? response.data)
        : response.data;
    return Offer.fromJson(data as Map<String, dynamic>);
  }

  // POST /offers/{id}/claim - Claim offer, generates voucher code + QR
  Future<Map<String, dynamic>> claimOffer(String id) async {
    final response = await _dio.post('/offers/$id/claim');
    return response.data as Map<String, dynamic>;
  }

  // POST /offers/{id}/redeem - Redeem a claimed offer
  Future<Map<String, dynamic>> redeemOffer(String id) async {
    final response = await _dio.post('/offers/$id/redeem');
    return response.data as Map<String, dynamic>;
  }

  // POST /offers/{id}/wallet-pass - Generate Apple Wallet pass
  Future<Map<String, dynamic>> generateWalletPass(String id) async {
    final response = await _dio.post('/offers/$id/wallet-pass');
    return response.data as Map<String, dynamic>;
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

  // POST /offers/redeem-by-code - Worker scans customer QR (Phase 6)
  Future<Map<String, dynamic>> redeemByCode(String code) async {
    final response = await _dio.post('/offers/redeem-by-code', data: {'code': code});
    return response.data as Map<String, dynamic>;
  }

  Future<Offer> updateOfferStatus(String id, bool isActive) async {
    final response = await _dio.patch('/offers/$id/status', data: {'isActive': isActive});
    return Offer.fromJson(response.data);
  }
}
