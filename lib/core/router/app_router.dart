import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user.dart';
import '../../core/services/auth_service.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/splash/presentation/loading_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/code_verification_screen.dart';
import '../../features/auth/presentation/change_password_screen.dart';
import '../../features/business/presentation/business_login_screen.dart';
import '../../features/business/presentation/business_signup_screen.dart';
import '../../features/venues/presentation/home_screen.dart';
import '../../features/venues/presentation/venue_list_screen.dart';
import '../../features/venues/presentation/venue_filter_screen.dart';

import '../../features/venues/presentation/venue_detail_screen.dart';
import '../../features/venues/presentation/map_view_screen.dart';
import '../../features/offers/presentation/offer_detail_screen.dart';
import '../../features/offers/presentation/offer_redeemed_screen.dart';
import '../../features/offers/presentation/offers_list_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/notifications/presentation/notification_preferences_screen.dart';
import '../../features/business/presentation/business_dashboard_screen.dart';
import '../../features/business/presentation/business_profile_screen.dart';
import '../../features/business/presentation/edit_business_profile_screen.dart';
import '../../features/business/presentation/business_venue_detail_screen.dart';
import '../../features/business/presentation/venue_analytics_screen.dart';
import '../../features/business/presentation/venue_status_screen.dart';
import '../../features/business/presentation/business_update_screen.dart';
import '../../features/business/presentation/manage_offers_screen.dart';
import '../../features/business/presentation/create_offer_screen.dart';
import '../../features/business/presentation/my_venues_screen.dart';
import '../../features/users/presentation/user_preferences_screen.dart';
import '../../features/users/presentation/user_profile_screen.dart';
import '../../features/users/presentation/edit_profile_screen.dart';
import '../../features/business/presentation/business_forgot_password_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/business/presentation/create_venue_screen.dart';
import '../../features/social/presentation/social_hub_screen.dart';

// Routes that require a fully logged-in (non-guest) user
const _guestBlockedRoutes = [
  '/notifications',
  '/profile',
  '/edit-profile',
  '/offer-redeemed',
  '/user-preferences',
  '/notification-preferences',
  '/social',
];

// Routes only accessible to BUSINESS role
const _businessRoutes = [
  '/business-dashboard',
  '/business-profile',
  '/edit-business-profile',
  '/business-venue',
  '/venue-analytics',
  '/venue-status',
  '/business-update',
  '/manage-offers',
  '/create-offer',
  '/vibe-schedules',
  '/admin/create-venue',
];

// Routes only accessible to ADMIN role
const _adminRoutes = [
  '/admin-dashboard',
];

String? _routeGuard(BuildContext context, GoRouterState state) {
  final user = AuthService().currentUser;
  final path = state.matchedLocation;

  if (user == null) {
    const publicPaths = [
      '/splash',
      '/loading',
      '/login',
      '/signup',
      '/forgot-password',
      '/code-verification',
      '/business-login',
      '/business-signup',
      '/business-forgot-password',
    ];
    if (!publicPaths.any((p) => path.startsWith(p))) return '/login';
    return null;
  }

  if (user.isGuest && _guestBlockedRoutes.any((r) => path.startsWith(r))) {
    return '/home';
  }

  final isBusinessOrAdmin =
      user.role == UserRole.BUSINESS || user.role == UserRole.ADMIN;
  final isAdmin = user.role == UserRole.ADMIN;

  if (_businessRoutes.any((r) => path.startsWith(r)) && !isBusinessOrAdmin) {
    return '/home';
  }

  if (_adminRoutes.any((r) => path.startsWith(r)) && !isAdmin) {
    return '/home';
  }

  return null;
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: _routeGuard,
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.uri}')),
  ),
  routes: [
    // ── Splash & Loading ──────────────────────────────────────────────────
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/loading',
      builder: (context, _) =>
          LoadingScreen(onLoadingComplete: () => context.go('/splash')),
    ),

    // ── Auth ──────────────────────────────────────────────────────────────
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
    GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(
      path: '/code-verification',
      builder: (_, state) =>
          CodeVerificationScreen(phoneNumber: state.extra as String? ?? ''),
    ),
    GoRoute(
        path: '/change-password',
        builder: (_, __) => const ChangePasswordScreen()),
    GoRoute(
        path: '/business-login',
        builder: (_, __) => const BusinessLoginScreen()),
    GoRoute(
        path: '/business-signup',
        builder: (_, __) => const BusinessSignupScreen()),
    GoRoute(
        path: '/business-forgot-password',
        builder: (_, __) => const BusinessForgotPasswordScreen()),

    // ── Customer App ──────────────────────────────────────────────────────
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/venues', builder: (_, __) => const VenueListScreen()),
    GoRoute(path: '/filters', builder: (_, __) => const VenueFilterScreen()),
    GoRoute(
      path: '/venue/:id',
      builder: (_, state) =>
          VenueDetailScreen(venueId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: '/venue-detail',
      builder: (_, state) =>
          VenueDetailScreen(venueId: state.uri.queryParameters['id'] ?? '1'),
    ),
    GoRoute(
      path: '/map',
      builder: (_, state) =>
          MapViewScreen(venueId: state.uri.queryParameters['venueId']),
    ),

    // ── Offers ────────────────────────────────────────────────────────────
    GoRoute(
      path: '/offers',
      builder: (_, state) => OffersListScreen(
        venueId: state.uri.queryParameters['venueId'],
        venueName: state.uri.queryParameters['venueName'],
      ),
    ),
    GoRoute(
      path: '/offer-detail',
      builder: (_, state) =>
          OfferDetailScreen(offerId: state.uri.queryParameters['id'] ?? '1'),
    ),
    GoRoute(
      path: '/offer-redeemed',
      builder: (_, state) => OfferRedeemedScreen(
        offerId: state.uri.queryParameters['offerId'] ?? '',
        claimData: state.extra as Map<String, dynamic>?,
      ),
    ),

    // ── Notifications ─────────────────────────────────────────────────────
    GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen()),
    GoRoute(
        path: '/notification-preferences',
        builder: (_, __) => const NotificationPreferencesScreen()),

    // ── User ──────────────────────────────────────────────────────────────
    GoRoute(
        path: '/user-preferences',
        builder: (_, __) => const UserPreferencesScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const UserProfileScreen()),
    GoRoute(
        path: '/edit-profile', builder: (_, __) => const EditProfileScreen()),
    GoRoute(path: '/social', builder: (_, __) => const SocialHubScreen()),

    // ── Business Dashboard ────────────────────────────────────────────────
    GoRoute(
        path: '/business-dashboard',
        builder: (_, __) => const BusinessDashboardScreen()),
    GoRoute(
        path: '/business-profile',
        builder: (_, __) => const BusinessProfileScreen()),
    GoRoute(
        path: '/edit-business-profile',
        builder: (_, __) => const EditBusinessProfileScreen()),
    GoRoute(
      path: '/business-venue/:id',
      builder: (_, state) => BusinessVenueDetailScreen(
        venueId: state.pathParameters['id'] ?? '',
        venueName: state.uri.queryParameters['name'] ?? '',
        venueAddress: state.uri.queryParameters['address'] ?? '',
      ),
    ),
    GoRoute(
      path: '/venue-analytics/:id',
      builder: (_, state) => VenueAnalyticsScreen(
        venueId: state.pathParameters['id'] ?? '',
        venueName: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/venue-status/:id',
      builder: (_, state) => VenueStatusScreen(
        venueId: state.pathParameters['id'] ?? '',
        venueName: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
        path: '/business-update',
        builder: (_, __) => const BusinessUpdateScreen()),
    GoRoute(
        path: '/manage-offers', builder: (_, __) => const ManageOffersScreen()),
    GoRoute(path: '/my-venues', builder: (_, __) => const MyVenuesScreen()),
    GoRoute(
      path: '/create-offer',
      builder: (_, state) => CreateOfferScreen(
          venueId: state.uri.queryParameters['venueId'] ?? ''),
    ),
    // ── Admin Dashboard ───────────────────────────────────────────────────
    GoRoute(
        path: '/admin-dashboard',
        builder: (_, __) => const AdminDashboardScreen()),
    GoRoute(
        path: '/admin/create-venue',
        builder: (_, __) => const CreateVenueScreen()),
  ],
);
