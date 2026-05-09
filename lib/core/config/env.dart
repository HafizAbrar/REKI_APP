import 'dart:io';

class Env {
  static const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
  static const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
    // Android emulator uses 10.0.2.2 to reach host machine's localhost
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }
  
  static bool get isProd => env == 'prod';
  static bool get isStaging => env == 'staging';
  static bool get isDev => env == 'dev';
}