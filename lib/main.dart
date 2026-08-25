import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/venue_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/offline_sync_service.dart';
import 'core/utils/app_logger.dart';
import 'core/network/interceptors/auth_interceptor.dart';
import 'core/services/auth_service.dart';
import 'core/services/device_registration_service.dart';
import 'shared/widgets/connectivity_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Week 7 — Firebase Crashlytics (graceful fallback if not yet configured)
  try {
    await Firebase.initializeApp();
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    appLogger.i('Firebase initialised');
  } catch (e) {
    appLogger.w('Firebase init skipped: $e');
  }

  VenueService().initialize();
  NotificationService().initialize();
  appLogger.i('REKI MVP started');

  runApp(const ProviderScope(child: RekiApp()));
}

class RekiApp extends ConsumerStatefulWidget {
  const RekiApp({super.key});

  @override
  ConsumerState<RekiApp> createState() => _RekiAppState();
}

class _RekiAppState extends ConsumerState<RekiApp> {
  @override
  void initState() {
    super.initState();
    _initFcm();
    _initConnectivity();
    _listenSessionExpiry();
  }

  bool _handlingExpiry = false;

  void _listenSessionExpiry() {
    try {
      sessionExpiredStream.stream.listen((_) async {
        if (_handlingExpiry) return;
        _handlingExpiry = true;
        appLogger.w('Session expired — redirecting to login');
        // Clear local state only — do NOT call logout() API (token already invalid)
        final authService = AuthService();
        authService.clearSession();
        appRouter.go('/login');
        _handlingExpiry = false;
      });
      tokenRefreshedStream.stream.listen((_) {
        ref.read(deviceRegistrationServiceProvider).register();
      });
    } catch (e) {
      appLogger.w('Session expiry listener init skipped: $e');
    }
  }

  Future<void> _initFcm() async {
    // Week 9 — FCM push notifications
    try {
      final fcm = ref.read(fcmServiceProvider);
      await fcm.initialize(
        onDeepLink: (route) {
          appLogger.i('FCM deep link: $route');
          appRouter.go(route);
        },
      );
      await fcm.subscribeToTopic('manchester');
      // Re-register device on every app start so the backend always has
      // a valid FCM token — covers already-logged-in users who skip login.
      final deviceReg = ref.read(deviceRegistrationServiceProvider);
      await deviceReg.register();
      // Re-register whenever FCM rotates the token
      fcm.setTokenRefreshCallback((_) => deviceReg.register());
    } catch (e) {
      appLogger.w('FCM init skipped: $e');
    }
  }

  void _initConnectivity() {
    // Week 10 — trigger offline sync when connectivity restored
    try {
      ref.read(connectivityServiceProvider).onConnected(() async {
        appLogger.i('Connectivity restored — syncing offline queue');
        await ref.read(offlineSyncServiceProvider).sync();
      });
    } catch (e) {
      appLogger.w('Connectivity init skipped: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'REKI',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      builder: (context, child) =>
          ConnectivityBanner(child: child ?? const SizedBox()),
    );
  }
}
