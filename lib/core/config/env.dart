class Env {
  static const String env = String.fromEnvironment('ENV', defaultValue: 'prod');
  static const String _apiBaseUrlOverride =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
    return 'https://api.reki.uk';
  }

  static bool get isProd => env == 'prod';
  static bool get isStaging => env == 'staging';
  static bool get isDev => env == 'dev';

  /// Public HTTPS origin used in share cards and universal links.
  static const String appLinkBaseUrl = String.fromEnvironment(
    'APP_LINK_BASE_URL',
    defaultValue: 'https://reki.uk',
  );

  /// OAuth 2.0 Web client used to request a backend-verifiable Google ID token.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '268435917845-nugtqnlvaiikg4aqq3shkrjavsh5v5rc.apps.googleusercontent.com',
  );
}
