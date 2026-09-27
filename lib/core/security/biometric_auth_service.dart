import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../utils/app_logger.dart';

final biometricAuthServiceProvider =
    Provider<BiometricAuthService>((ref) => BiometricAuthService());

/// Phase 8 — Biometric authentication (Face ID / Touch ID / fingerprint)
/// for sensitive actions: opening the business dashboard, confirming payout
/// changes, etc.
class BiometricAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported || canCheck;
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> enrolledBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return const [];
    }
  }

  /// Prompts the user; returns false on cancel/unavailable — callers decide
  /// whether to fall back to PIN (recommended UX).
  Future<bool> authenticate({String reason = 'Verify your identity'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // allow device PIN fallback
        ),
      );
    } on PlatformException catch (e) {
      appLogger.w('Biometric auth unavailable: $e');
      return false;
    }
  }
}
