import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/analytics_dashboard.dart';
import '../../../core/models/venue_analytics.dart';
import '../../../core/models/offer_analytics.dart';
import '../../../core/models/platform_engagement.dart';
import '../../../core/services/analytics_repository.dart';

final ownerDashboardProvider = FutureProvider<AnalyticsDashboard>((ref) async {
  final repository = ref.read(analyticsRepositoryProvider);
  final result = await repository.getOwnerDashboard();
  return result.when(
    success: (data) => data,
    failure: (error) => throw Exception(error),
  );
});

final venueAnalyticsProvider = FutureProvider.family<VenueAnalytics, String>((ref, venueId) async {
  final repository = ref.read(analyticsRepositoryProvider);
  final result = await repository.getVenueAnalytics(venueId);
  return result.when(
    success: (data) => data,
    failure: (error) => throw Exception(error),
  );
});

final offerAnalyticsProvider = FutureProvider.family<OfferAnalytics, String>((ref, offerId) async {
  final repository = ref.read(analyticsRepositoryProvider);
  final result = await repository.getOfferAnalytics(offerId);
  return result.when(
    success: (data) => data,
    failure: (error) => throw Exception(error),
  );
});

final platformEngagementProvider = FutureProvider<PlatformEngagement>((ref) async {
  final repository = ref.read(analyticsRepositoryProvider);
  final result = await repository.getPlatformEngagement();
  return result.when(
    success: (data) => data,
    failure: (error) => throw Exception(error),
  );
});
