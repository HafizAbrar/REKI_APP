import '../models/user.dart';

String roleHome(UserRole role) => switch (role) {
      UserRole.USER => '/home',
      UserRole.BUSINESS => '/business-dashboard',
      UserRole.ADMIN => '/admin-dashboard',
      UserRole.WORKER => '/worker-home',
    };

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

// Business routes shared by owners, admins and assigned workers.
const _businessRoutes = [
  '/my-venues',
  '/business-dashboard',
  '/worker-home',
  '/business-profile',
  '/edit-business-profile',
  '/business-venue',
  '/venue-analytics',
  '/venue-status',
  '/business-update',
  '/manage-offers',
  '/create-offer',
  '/vibe-schedules',
  '/qr-scan',
  '/admin/create-venue',
  '/staff-management',
];

// Routes only accessible to ADMIN role
const _adminRoutes = [
  '/admin-dashboard',
];

String? roleRedirect(User? user, String path) {
  if (user?.role == UserRole.WORKER &&
      [
        '/my-venues',
        '/business-venue',
        '/business-update',
        '/create-offer',
        '/manage-offers',
        '/admin/create-venue',
        '/edit-business-profile',
        '/venue-analytics',
        '/staff-management',
        '/business-dashboard',
        '/business-profile',
        '/vibe-schedules',
        '/admin',
      ].any((p) => path.startsWith(p))) {
    return '/worker-home';
  }

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
      // Shared venue links must remain viewable before authentication. Actions
      // such as saving and checking in are still protected inside the screen.
      '/venue/',
    ];
    if (!publicPaths.any((p) => path.startsWith(p))) return '/login';
    return null;
  }

  if (user.isGuest && _guestBlockedRoutes.any((r) => path.startsWith(r))) {
    return '/home';
  }

  final isBusinessOrAdmin = user.role == UserRole.BUSINESS ||
      user.role == UserRole.WORKER ||
      user.role == UserRole.ADMIN;
  final isAdmin = user.role == UserRole.ADMIN;

  if (_businessRoutes.any((r) => path.startsWith(r)) && !isBusinessOrAdmin) {
    return roleHome(user.role);
  }

  if (_adminRoutes.any((r) => path.startsWith(r)) && !isAdmin) {
    return roleHome(user.role);
  }

  return null;
}
