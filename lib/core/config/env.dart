class Env {
  static const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
  static const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static const String _liveBaseUrl = 'https://api.reki.uk';

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
    return _liveBaseUrl;
  }

  static bool get isProd => env == 'prod';
  static bool get isStaging => env == 'staging';
  static bool get isDev => env == 'dev';
}