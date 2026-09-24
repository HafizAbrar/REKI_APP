import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider =
    Provider<ConnectivityService>((ref) => ConnectivityService());

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).onConnectivityChanged;
});

class ConnectivityService {
  final _connectivity = Connectivity();

  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged
      .map((results) => _isConnected(results))
      .distinct();

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  bool _isConnected(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  /// Registers [callback] to fire each time connectivity is restored.
  StreamSubscription<bool> onConnected(VoidCallback callback) {
    return onConnectivityChanged.listen((online) {
      if (online) callback();
    });
  }
}
