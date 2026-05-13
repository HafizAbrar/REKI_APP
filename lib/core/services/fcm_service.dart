import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

final fcmServiceProvider = Provider<FcmService>((ref) => FcmService());

// Background message handler — must be top-level
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  appLogger.i('FCM background: ${message.messageId}');
}

const _androidChannel = AndroidNotificationChannel(
  'reki_high_importance',
  'REKI Notifications',
  description: 'Venue offers, busyness alerts and updates',
  importance: Importance.high,
);

class FcmService {
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  String? _token;
  String? get token => _token;

  static const _prefKeyOptIn = 'fcm_opt_in';

  Future<void> initialize({Function(String route)? onDeepLink}) async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    // Request permission (iOS prompt / Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final granted = settings.authorizationStatus ==
        AuthorizationStatus.authorized;
    appLogger.i('FCM permission: ${settings.authorizationStatus}');

    // Persist opt-in state for preference toggle UI
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyOptIn, granted);

    if (!granted) return;

    // Set up local notifications channel (Android)
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false, // already requested above
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null && onDeepLink != null) {
          onDeepLink(details.payload!);
        }
      },
    );

    // Foreground messages → show local notification
    FirebaseMessaging.onMessage.listen((message) {
      _showLocal(message);
    });

    // Notification tap while app in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final route = message.data['route'];
      if (route != null && onDeepLink != null) onDeepLink(route);
    });

    // Check if app was launched from a notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      final route = initial.data['route'];
      if (route != null && onDeepLink != null) onDeepLink(route);
    }

    // Get & cache device token
    _token = await _messaging.getToken();
    appLogger.i('FCM token: $_token');

    _messaging.onTokenRefresh.listen((t) {
      _token = t;
      appLogger.i('FCM token refreshed');
    });
  }

  void _showLocal(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;

    _localNotifications.show(
      n.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['route'],
    );
  }

  Future<bool> isOptedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKeyOptIn) ?? false;
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    appLogger.d('FCM subscribed: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    appLogger.d('FCM unsubscribed: $topic');
  }
}
