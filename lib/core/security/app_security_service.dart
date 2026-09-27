import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp/freerasp.dart';
import '../utils/app_logger.dart';

final appSecurityServiceProvider =
    Provider<AppSecurityService>((ref) => AppSecurityService());

/// Phase 8 — Runtime security: jailbreak/root detection, debugger hooking,
/// tamper evidence (via freeRASP RASP SDK).
///
/// Fail-open by design in debug/staging; in production a hard-threat triggers
/// `onHardThreat`, which main.dart uses to show a blocking screen.
class AppSecurityService {
  bool _started = false;
  void Function(String threat)? onHardThreat;

  Future<void> initialise() async {
    if (_started || kDebugMode) return; // dev builds stay usable
    try {
      final config = TalsecConfig(
        androidConfig: AndroidConfig(
          packageName: 'uk.reki.app',
          // Download/rotate via freeRASP dashboard; placeholder env-provided cert fingerprint.
          signingCertHashes: const [
            String.fromEnvironment('ANDROID_SIGNING_CERT_HASH', defaultValue: ''),
          ],
        ),
        iosConfig: IOSConfig(
          bundleIds: const ['uk.reki.app'],
          teamId: const String.fromEnvironment('APPLE_TEAM_ID', defaultValue: ''),
        ),
        watcherMail: 'security@reki.uk',
        isProd: true,
      );

      await Talsec.instance.attachListener(ThreatCallback(
        onAppIntegrity: () => _hard('app_integrity'), // tampering/re-signing
        onPrivilegedAccess: () => _hard('privileged_access'), // jailbreak/root
        onSimulator: () => appLogger.w('RASP: simulator detected (soft)'),
        onDebug: () => appLogger.w('RASP: debugger attached (soft)'),
      ));
      await Talsec.instance.start(config);
      _started = true;
    } catch (e) {
      appLogger.w('RASP init skipped: $e');
    }
  }

  void _hard(String threat) {
    appLogger.e('RASP hard threat: $threat');
    onHardThreat?.call(threat);
  }
}
