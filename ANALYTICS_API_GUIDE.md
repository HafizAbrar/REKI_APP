# Analytics API Implementation Guide

## Overview
Complete implementation of the Analytics API with 4 endpoints for tracking business metrics, venue performance, offer effectiveness, and platform-wide engagement.

## API Endpoints

### 1. GET /analytics/owner/dashboard
**Purpose**: Get business owner's analytics dashboard with revenue and offer metrics

**Response Model**: `AnalyticsDashboard`
```dart
{
  totalRevenue: int,
  totalOffers: int,
  activeOffers: int,
  totalRedemptions: int,
  totalViews: int,
  totalClicks: int,
  conversionRate: double
}
```

**Usage**:
```dart
// In screen
final dashboardAsync = ref.watch(ownerDashboardProvider);

// Refresh
ref.refresh(ownerDashboardProvider);
```

**Screen**: `OwnerDashboardScreen`
- Displays revenue, offers, redemptions, views, clicks
- Shows conversion rate percentage
- Pull-to-refresh support

---

### 2. GET /analytics/venues/{venueId}
**Purpose**: Get detailed analytics for a specific venue

**Response Model**: `VenueAnalytics`
```dart
{
  venueId: String,
  venueName: String,
  totalVisits: int,
  uniqueVisitors: int,
  averageStayMinutes: int,
  peakHours: Map<String, int>,
  vibeDistribution: Map<String, int>
}
```

**Usage**:
```dart
// In screen
final analyticsAsync = ref.watch(venueAnalyticsProvider(venueId));

// Refresh
ref.refresh(venueAnalyticsProvider(venueId));
```

**Screen**: `VenueAnalyticsScreen`
- Shows visits, unique visitors, average stay time
- Displays peak hours breakdown
- Shows vibe distribution chart
- Pull-to-refresh support

---

### 3. GET /analytics/offers/{offerId}
**Purpose**: Get detailed analytics for a specific offer

**Response Model**: `OfferAnalytics`
```dart
{
  offerId: String,
  offerTitle: String,
  views: int,
  clicks: int,
  redemptions: int,
  clickThroughRate: double,
  conversionRate: double,
  revenue: int
}
```

**Usage**:
```dart
// In screen
final analyticsAsync = ref.watch(offerAnalyticsProvider(offerId));

// Refresh
ref.refresh(offerAnalyticsProvider(offerId));
```

**Screen**: `OfferAnalyticsScreen`
- Shows views, clicks, redemptions
- Displays CTR and conversion rate
- Shows revenue generated
- Pull-to-refresh support

---

### 4. GET /analytics/platform/engagement
**Purpose**: Get platform-wide engagement metrics (admin only)

**Response Model**: `PlatformEngagement`
```dart
{
  totalUsers: int,
  activeUsers: int,
  totalVenues: int,
  totalOffers: int,
  totalRedemptions: int,
  usersByCity: Map<String, int>,
  venuesByType: Map<String, int>
}
```

**Usage**:
```dart
// In screen
final engagementAsync = ref.watch(platformEngagementProvider);

// Refresh
ref.refresh(platformEngagementProvider);
```

**Screen**: `PlatformEngagementScreen`
- Shows total users, active users, venues, offers
- Displays users by city breakdown
- Shows venues by type distribution
- Pull-to-refresh support

---

## Architecture

### Models
- `lib/core/models/analytics_dashboard.dart` - Owner dashboard data
- `lib/core/models/venue_analytics.dart` - Venue performance data
- `lib/core/models/offer_analytics.dart` - Offer effectiveness data
- `lib/core/models/platform_engagement.dart` - Platform-wide metrics

### API Service
- `lib/core/network/analytics_api_service.dart`
- Methods: `getOwnerDashboard()`, `getVenueAnalytics()`, `getOfferAnalytics()`, `getPlatformEngagement()`
- Uses Dio client with auth interceptor

### Repository
- `lib/core/services/analytics_repository.dart`
- Wraps API calls with `Result<T>` error handling
- Provides clean interface for data layer

### Providers
- `lib/features/analytics/data/analytics_provider.dart`
- `ownerDashboardProvider` - FutureProvider for dashboard
- `venueAnalyticsProvider` - FutureProvider.family for venue analytics
- `offerAnalyticsProvider` - FutureProvider.family for offer analytics
- `platformEngagementProvider` - FutureProvider for platform metrics

### Screens
- `lib/features/analytics/presentation/owner_dashboard_screen.dart`
- `lib/features/analytics/presentation/venue_analytics_screen.dart`
- `lib/features/analytics/presentation/offer_analytics_screen.dart`
- `lib/features/analytics/presentation/platform_engagement_screen.dart`

---

## Integration Examples

### Navigate to Owner Dashboard
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
);
```

### Navigate to Venue Analytics
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => VenueAnalyticsScreen(venueId: 'venue-123'),
  ),
);
```

### Navigate to Offer Analytics
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => OfferAnalyticsScreen(offerId: 'offer-456'),
  ),
);
```

### Navigate to Platform Engagement
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const PlatformEngagementScreen()),
);
```

---

## Features

### All Screens Include:
- ✅ Pull-to-refresh functionality
- ✅ Loading states with CircularProgressIndicator
- ✅ Error handling with user-friendly messages
- ✅ Clean card-based UI with icons
- ✅ Real-time data from API
- ✅ Automatic state management via Riverpod

### Data Visualization:
- Metric cards with icons and values
- List-based breakdowns for distributions
- Percentage formatting for rates
- Currency formatting for revenue

---

## Error Handling

All API calls are wrapped in try-catch with Result<T>:
```dart
Future<Result<AnalyticsDashboard>> getOwnerDashboard() async {
  try {
    final dashboard = await _apiService.getOwnerDashboard();
    return Result.success(dashboard);
  } catch (e) {
    return Result.failure(e.toString());
  }
}
```

Providers handle errors gracefully:
```dart
analyticsAsync.when(
  data: (analytics) => /* Show data */,
  loading: () => CircularProgressIndicator(),
  error: (error, _) => Text('Error: $error'),
);
```

---

## Testing

### Test Owner Dashboard
1. Navigate to OwnerDashboardScreen
2. Verify all metrics display correctly
3. Pull down to refresh
4. Check error handling with invalid auth

### Test Venue Analytics
1. Navigate with valid venueId
2. Verify venue name and metrics
3. Check peak hours and vibe distribution
4. Test refresh functionality

### Test Offer Analytics
1. Navigate with valid offerId
2. Verify offer title and metrics
3. Check CTR and conversion calculations
4. Test refresh functionality

### Test Platform Engagement
1. Navigate to PlatformEngagementScreen (admin only)
2. Verify platform-wide metrics
3. Check city and venue type breakdowns
4. Test refresh functionality

---

## Next Steps

1. **Add to Business Dashboard**: Link owner dashboard from business home
2. **Add to Venue Details**: Link venue analytics from venue detail screen
3. **Add to Offer Details**: Link offer analytics from offer detail screen
4. **Admin Panel**: Create admin panel with platform engagement link
5. **Charts**: Add visual charts using fl_chart package
6. **Export**: Add CSV/PDF export functionality
7. **Date Filters**: Add date range filtering
8. **Real-time Updates**: Add WebSocket support for live metrics

---

## Dependencies

All required dependencies are already in the project:
- `flutter_riverpod` - State management
- `dio` - HTTP client
- `flutter/material.dart` - UI components

No additional packages needed for basic implementation.
