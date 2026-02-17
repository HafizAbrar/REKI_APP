import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/code_verification_screen.dart';
import '../../features/auth/presentation/change_password_screen.dart';
import '../../features/venues/presentation/home_screen.dart';
import '../../features/venues/presentation/venue_list_screen.dart';
import '../../features/venues/presentation/venue_filter_screen.dart';
import '../../features/venues/presentation/personalize_feed_screen.dart';
import '../../features/venues/presentation/venue_detail_screen.dart';
import '../../features/venues/presentation/map_view_screen.dart';
import '../../features/offers/presentation/offer_detail_screen.dart';
import '../../features/offers/presentation/offer_redeemed_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/business/presentation/business_dashboard_screen.dart';
import '../../features/business/presentation/business_update_screen.dart';
import '../../features/business/presentation/manage_offers_screen.dart';
import '../../features/splash/presentation/loading_screen.dart';
import '../../features/venues/presentation/no_venues_found_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/loading',
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/loading',
      builder: (context, state) => LoadingScreen(
        onLoadingComplete: () => context.go('/splash'),
      ),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/code-verification',
      builder: (context, state) {
        final phoneNumber = state.extra as String? ?? '';
        return CodeVerificationScreen(phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/venues',
      builder: (context, state) => const VenueListScreen(),
    ),
    GoRoute(
      path: '/filters',
      builder: (context, state) => const VenueFilterScreen(),
    ),
    GoRoute(
      path: '/personalize',
      builder: (context, state) => const PersonalizeFeedScreen(),
    ),
    GoRoute(
      path: '/venue-detail',
      builder: (context, state) {
        final venueId = state.uri.queryParameters['id'] ?? '1';
        return VenueDetailScreen(venueId: venueId);
      },
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) => const MapViewScreen(),
    ),
    GoRoute(
      path: '/offer-detail',
      builder: (context, state) {
        final offerId = state.uri.queryParameters['id'] ?? '1';
        return OfferDetailScreen(offerId: offerId);
      },
    ),
    GoRoute(
      path: '/offer-redeemed',
      builder: (context, state) => const OfferRedeemedScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/business-dashboard',
      builder: (context, state) => const BusinessDashboardScreen(),
    ),
    GoRoute(
      path: '/business-update',
      builder: (context, state) => const BusinessUpdateScreen(),
    ),
    GoRoute(
      path: '/manage-offers',
      builder: (context, state) => const ManageOffersScreen(),
    ),
    GoRoute(
      path: '/no-venues',
      builder: (context, state) => const NoVenuesFoundScreen(),
    ),
  ],
);
