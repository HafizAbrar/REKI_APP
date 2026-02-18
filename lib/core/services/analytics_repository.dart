import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_dashboard.dart';
import '../models/venue_analytics.dart';
import '../models/offer_analytics.dart';
import '../models/platform_engagement.dart';
import '../network/analytics_api_service.dart';
import '../utils/result.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.read(analyticsApiServiceProvider));
});

class AnalyticsRepository {
  final AnalyticsApiService _apiService;

  AnalyticsRepository(this._apiService);

  Future<Result<AnalyticsDashboard>> getOwnerDashboard() async {
    try {
      final dashboard = await _apiService.getOwnerDashboard();
      return Result.success(dashboard);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<VenueAnalytics>> getVenueAnalytics(String venueId) async {
    try {
      final analytics = await _apiService.getVenueAnalytics(venueId);
      return Result.success(analytics);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<OfferAnalytics>> getOfferAnalytics(String offerId) async {
    try {
      final analytics = await _apiService.getOfferAnalytics(offerId);
      return Result.success(analytics);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<PlatformEngagement>> getPlatformEngagement() async {
    try {
      final engagement = await _apiService.getPlatformEngagement();
      return Result.success(engagement);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
