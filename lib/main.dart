import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/offline_sync_service.dart';
import 'core/utils/app_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/network/interceptors/auth_interceptor.dart';
import 'core/services/auth_service.dart';
import 'core/services/device_registration_service.dart';
import 'shared/widgets/connectivity_banner.dart';
import 'features/city_selection/presentation/city_selection_screen.dart'
    show selectedCityProvider;
import 'shared/widgets/city_localization.dart';

Future<void> main() async {
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

  final _subscriptions = <StreamSubscription<dynamic>>[];
  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }

  bool _handlingExpiry = false;
  String? _cityTopic;
  Future<void> _topicChange = Future.value();
  void _switchCityTopic(String topic) {
    _topicChange = _topicChange.then((_) async {
      if (!mounted || _cityTopic == topic) return;
      final fcm = ref.read(fcmServiceProvider);
      if (_cityTopic != null) await fcm.unsubscribeFromTopic(_cityTopic!);
      await fcm.subscribeToTopic(topic);
      _cityTopic = topic;
    }).catchError((Object e) {
      appLogger.w('City notification subscription failed: $e');
    });
  }

  void _listenSessionExpiry() {
    try {
      _subscriptions.add(sessionExpiredStream.stream.listen((_) async {
        if (_handlingExpiry) return;
        _handlingExpiry = true;
        // Verify both tokens are truly gone before logging out.
        // A 401 on a non-critical endpoint (e.g. /live/snapshot) can fire
        // this stream even when the session is still valid.
        const storage = FlutterSecureStorage();
        final accessToken = await storage.read(key: 'access_token');
        final refreshToken = await storage.read(key: 'refresh_token');
        if (accessToken != null || refreshToken != null) {
          // Tokens still present — this was a spurious 401, not a real expiry.
          _handlingExpiry = false;
          return;
        }
        appLogger.w('Session expired — redirecting to login');
        final authService = AuthService();
        await authService.clearSession();
        appRouter.go('/login');
        _handlingExpiry = false;
      }));
      _subscriptions.add(tokenRefreshedStream.stream.listen((_) {
        ref.read(deviceRegistrationServiceProvider).register();
      }));
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
      // Subscribe to the user's selected city topic for city-scoped push
      // (falls back to Manchester for fresh installs before city selection).
      if (!mounted) return;
      final city = await ref.read(selectedCityProvider.future);
      if (!mounted) return;
      _switchCityTopic(city?.slug ?? 'manchester');
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
      _subscriptions
          .add(ref.read(connectivityServiceProvider).onConnected(() async {
        appLogger.i('Connectivity restored — syncing offline queue');
        try {
          await ref.read(offlineSyncServiceProvider).sync();
        } catch (e) {
          appLogger.w('Offline sync failed: $e');
        }
      }));
    } catch (e) {
      appLogger.w('Connectivity init skipped: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds app-level locale/direction when the user switches city.
    ref.listen(selectedCityProvider, (previous, next) {
      final city = next.valueOrNull;
      if (city != null) _switchCityTopic(city.slug);
    });
    final city = ref.watch(selectedCityProvider).valueOrNull;
    return MaterialApp.router(
      title: 'REKI',
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      locale: CityLocalization.localeFor(city),
      supportedLocales: const [
        Locale('en', 'GB'),
        Locale('ar', 'AE'),
        Locale('fa'),
        Locale('he'),
        Locale('ur'),
        Locale('de', 'DE'),
        Locale('fr', 'FR'),
        Locale('es', 'ES'),
        Locale('ja', 'JP'),
      ],
      builder: (context, child) {
        return CityLocalization(
          city: city,
          child: ConnectivityBanner(child: child ?? const SizedBox()),
        );
      },
    );
  }
}
