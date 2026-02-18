import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_dashboard.dart';
import '../models/venue_analytics.dart';
import '../models/offer_analytics.dart';
import '../models/platform_engagement.dart';
import 'api_client.dart';

final analyticsApiServiceProvider = Provider<AnalyticsApiService>((ref) {
  return AnalyticsApiService(ref.read(apiClientProvider));
});

class AnalyticsApiService {
  final Dio _dio;

  AnalyticsApiService(this._dio);

  Future<AnalyticsDashboard> getOwnerDashboard() async {
    final response = await _dio.get('/analytics/owner/dashboard');
    return AnalyticsDashboard.fromJson(response.data);
  }

  Future<VenueAnalytics> getVenueAnalytics(String venueId) async {
    final response = await _dio.get('/analytics/venues/$venueId');
    return VenueAnalytics.fromJson(response.data);
  }

  Future<OfferAnalytics> getOfferAnalytics(String offerId) async {
    final response = await _dio.get('/analytics/offers/$offerId');
    return OfferAnalytics.fromJson(response.data);
  }

  Future<PlatformEngagement> getPlatformEngagement() async {
    final response = await _dio.get('/analytics/platform/engagement');
    return PlatformEngagement.fromJson(response.data);
  }
}
