import '../models/voucher_scan.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/offer.dart';
import '../utils/async_ttl_cache.dart';
import 'api_client.dart';

final offerApiServiceProvider = Provider<OfferApiService>((ref) {
  return OfferApiService(ref.read(apiClientProvider));
});

class OfferApiService {
  final Dio _dio;
  final _venueCities =
      AsyncTtlCache<String, String>(ttl: const Duration(minutes: 5));

  OfferApiService(this._dio);

  Future<List<Offer>> getAllOffers() async {
    final response = await _dio.get('/offers');
    final data = response.data is Map
        ? (response.data['offers'] ?? response.data['data'] ?? [])
        : response.data;
    final city = response.requestOptions.queryParameters['city']
        ?.toString()
        .toLowerCase();
    final rows = data as List;
    final scoped = <Offer>[];
    // Bound network fan-out even when the backend returns a large offer list.
    for (var offset = 0; offset < rows.length; offset += 4) {
      final batch =
          await Future.wait(rows.skip(offset).take(4).map((raw) async {
        final json = raw as Map<String, dynamic>;
        if (city == null) return Offer.fromJson(json);
        final venue = json['venue'];
        if (venue is! Map) return null;
        var venueCity = venue['city']?.toString().toLowerCase();
        final id = venue['id']?.toString();
        if (venueCity == null && id != null) {
          venueCity = await _venueCities.get(id, () async {
            final detail = await _dio.get('/venues/$id');
            final body = detail.data;
            final record =
                body is Map ? (body['venue'] ?? body['data'] ?? body) : null;
            final resolved =
                record is Map ? record['city']?.toString().toLowerCase() : null;
            if (resolved == null) throw StateError('Venue city unavailable');
            return resolved;
          });
        }
        return venueCity == city ? Offer.fromJson(json) : null;
      }));
      scoped.addAll(batch.whereType<Offer>());
    }
    return scoped;
  }

  Future<Offer> createOffer(Map<String, dynamic> offerData) async {
    final response = await _dio.post('/offers', data: offerData);
    return Offer.fromJson(response.data);
  }

  Future<List<Offer>> getOffersByVenue(String venueId) async {
    final response = await _dio.get('/venues/$venueId/offers');
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
  Future<Map<String, dynamic>> redeemOffer(String id,
      {required String voucherCode}) async {
    final response = await _dio
        .post('/offers/$id/redeem', data: {'voucherCode': voucherCode});
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

  Future<void> trackOfferClick(String id) async {
    await _dio.post('/offers/$id/click');
  }

  Future<Map<String, dynamic>> getOfferStats(String id) async {
    final response = await _dio.get('/offers/$id/stats');
    return response.data;
  }

  // POST /worker/venues/{venueId}/redemptions/scan - Worker scans customer QR (Phase 6)
  Future<Map<String, dynamic>> redeemByCode(String code,
      {String? venueId}) async {
    if (venueId == null || venueId.isEmpty) {
      throw StateError('Venue ID required for worker redemption.');
    }
    final response = await _dio.post('/worker/venues/$venueId/redemptions/scan',
        data: VoucherScan.redemptionPayload(code),
        options: Options(
            sendTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8)));
    final raw = response.data;
    final data = raw is Map ? raw['data'] ?? raw : null;
    if (data is! Map ||
        data['transactionId'] == null ||
        data['success'] == false) {
      throw StateError(
          'Redemption confirmation missing; check status before retrying.');
    }
    return Map<String, dynamic>.from(data);
  }

  Future<Offer> updateOfferStatus(String id, bool isActive) async {
    final response =
        await _dio.patch('/offers/$id/status', data: {'isActive': isActive});
    return Offer.fromJson(response.data);
  }
}
