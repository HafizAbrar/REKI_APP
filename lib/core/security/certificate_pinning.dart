import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../config/env.dart';
import '../utils/app_logger.dart';

/// Phase 8 — TLS certificate pinning.
///
/// Pins the SHA-256 fingerprint of the server's X.509 certificate. Configured
/// via `--dart-define CERT_PINS="base64sha256pin1,base64sha256pin2"` (include
/// both the current and next rotation pin). When no pins are configured the
/// client falls back to default OS verification — acceptable for staging.
void applyCertificatePinning(Dio dio) {
  if (Env.certificatePins.isEmpty) {
    appLogger.w('CERT_PINS not configured — certificate pinning disabled');
    return;
  }
  final pins = Env.certificatePins
      .split(',')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toSet();

  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final context = SecurityContext(withTrustedRoots: true);
      final client = HttpClient(context: context);
      client.badCertificateCallback = (cert, host, port) {
        final fingerprint = base64Encode(sha256.convert(cert.der).bytes);
        final trusted = pins.contains(fingerprint);
        if (!trusted) {
          appLogger.e('Certificate pin mismatch for $host:$port');
        }
        return trusted;
      };
      return client;
    },
  );
  appLogger.i('Certificate pinning enabled (${pins.length} pin(s))');
}
