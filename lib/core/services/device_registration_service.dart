import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../services/fcm_service.dart';
import '../utils/app_logger.dart';

final deviceRegistrationServiceProvider = Provider<DeviceRegistrationService>((ref) {
  return DeviceRegistrationService(
    ref.read(apiClientProvider),
    ref.read(fcmServiceProvider),
  );
});

class DeviceRegistrationService {
  final Dio _dio;
  final FcmService _fcm;

  DeviceRegistrationService(this._dio, this._fcm);

  static const _prefKeyDeviceId = 'reki_device_id';

  /// Deactivate device on logout — DELETE /devices/{deviceId}
  Future<void> deactivate() async {
    try {
      final deviceId = await _getOrCreateDeviceId();
      await _dio.delete('/devices/$deviceId');
      appLogger.i('DeviceRegistration: deactivated $deviceId');
    } catch (e) {
      appLogger.w('DeviceRegistration: deactivate failed (non-fatal): $e');
    }
  }

  /// Call this after every successful login / token refresh.
  Future<void> register() async {
    try {
      final fcmToken = _fcm.token;
      if (fcmToken == null || fcmToken.isEmpty) {
        appLogger.w('DeviceRegistration: FCM token not available, skipping');
        return;
      }

      final deviceId = await _getOrCreateDeviceId();
      final platform = Platform.isIOS ? 'ios' : 'android';

      await _dio.post('/devices/register', data: {
        'fcmToken': fcmToken,
        'platform': platform,
        'deviceId': deviceId,
        'appVersion': '1.0.0',
      });

      appLogger.i('DeviceRegistration: registered [$platform] $deviceId');
    } catch (e) {
      appLogger.w('DeviceRegistration: failed (non-fatal): $e');
    }
  }

  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_prefKeyDeviceId);
    if (id == null) {
      id = _generateId();
      await prefs.setString(_prefKeyDeviceId, id);
    }
    return id;
  }

  String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rng = Random.secure();
    return List.generate(32, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
