import 'dart:math' show sin, cos, sqrt, atan2, pi;

class City {
  final String id;
  final String name;
  final String slug;
  final String country;
  final String countryCode;
  final String timezone;
  final double defaultLat;
  final double defaultLng;
  final bool isActive;
  final List<String> supportedLanguages;
  final String currency;
  final String currencySymbol;
  final String dateFormat;
  final String timeFormat;
  final bool isRTL;
  final String? coverImageUrl;
  final Map<String, dynamic>? metadata;

  City({
    required this.id,
    required this.name,
    required this.slug,
    required this.country,
    required this.countryCode,
    required this.timezone,
    required this.defaultLat,
    required this.defaultLng,
    required this.isActive,
    required this.supportedLanguages,
    required this.currency,
    required this.currencySymbol,
    required this.dateFormat,
    required this.timeFormat,
    required this.isRTL,
    this.coverImageUrl,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'country': country,
        'countryCode': countryCode,
        'timezone': timezone,
        'defaultLat': defaultLat,
        'defaultLng': defaultLng,
        'isActive': isActive,
        'supportedLanguages': supportedLanguages,
        'currency': currency,
        'currencySymbol': currencySymbol,
        'dateFormat': dateFormat,
        'timeFormat': timeFormat,
        'isRTL': isRTL,
        'coverImageUrl': coverImageUrl,
        'metadata': metadata,
      };

  static const rtlLanguages = {'ar', 'fa', 'he', 'ur', 'ps', 'sd', 'ug', 'yi'};

  static bool isRtlLanguage(String tag) => rtlLanguages
      .contains(tag.replaceAll('_', '-').split('-').first.toLowerCase());

  static List<String> _languages(Map<String, dynamic> json) {
    final preferred = json['defaultLocale']?.toString();
    final supported = json['supportedLanguages'] ?? json['supported_languages'];
    final languages = <String>{
      if (preferred != null && preferred.trim().isNotEmpty) preferred.trim(),
      if (supported is List)
        ...supported
            .whereType<String>()
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty),
    };
    return languages.isEmpty ? ['en-GB'] : languages.toList();
  }

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
        country: json['country']?.toString() ?? '',
        countryCode: json['countryCode']?.toString() ??
            json['country_code']?.toString() ??
            '',
        timezone: json['timezone']?.toString() ?? 'UTC',
        defaultLat: double.tryParse((json['defaultLat'] ??
                    json['default_lat'] ??
                    json['latitude'] ??
                    '')
                .toString()) ??
            0,
        defaultLng: double.tryParse((json['defaultLng'] ??
                    json['default_lng'] ??
                    json['longitude'] ??
                    '')
                .toString()) ??
            0,
        isActive: json['isActive'] ?? json['is_active'] ?? true,
        supportedLanguages: _languages(json),
        currency: json['currency']?.toString() ?? 'GBP',
        currencySymbol: json['currencySymbol']?.toString() ??
            json['currency_symbol']?.toString() ??
            '£',
        dateFormat: json['dateFormat']?.toString() ??
            json['date_format']?.toString() ??
            'dd/MM/yyyy',
        timeFormat: json['timeFormat']?.toString() ??
            json['time_format']?.toString() ??
            'HH:mm',
        isRTL: json['isRTL'] ??
            json['is_rtl'] ??
            isRtlLanguage(_languages(json).first),
        coverImageUrl: json['coverImageUrl']?.toString() ??
            json['cover_image_url']?.toString(),
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  static List<City> defaultCities() => [
        City(
          id: 'manchester',
          name: 'Manchester',
          slug: 'manchester',
          country: 'United Kingdom',
          countryCode: 'GB',
          timezone: 'Europe/London',
          defaultLat: 53.4808,
          defaultLng: -2.2426,
          isActive: true,
          supportedLanguages: ['en'],
          currency: 'GBP',
          currencySymbol: '£',
          dateFormat: 'dd/MM/yyyy',
          timeFormat: 'HH:mm',
          isRTL: false,
        ),
        City(
          id: 'london',
          name: 'London',
          slug: 'london',
          country: 'United Kingdom',
          countryCode: 'GB',
          timezone: 'Europe/London',
          defaultLat: 51.5074,
          defaultLng: -0.1278,
          isActive: true,
          supportedLanguages: ['en'],
          currency: 'GBP',
          currencySymbol: '£',
          dateFormat: 'dd/MM/yyyy',
          timeFormat: 'HH:mm',
          isRTL: false,
        ),
        City(
          id: 'birmingham',
          name: 'Birmingham',
          slug: 'birmingham',
          country: 'United Kingdom',
          countryCode: 'GB',
          timezone: 'Europe/London',
          defaultLat: 52.4862,
          defaultLng: -1.8904,
          isActive: false,
          supportedLanguages: ['en'],
          currency: 'GBP',
          currencySymbol: '£',
          dateFormat: 'dd/MM/yyyy',
          timeFormat: 'HH:mm',
          isRTL: false,
        ),
        City(
          id: 'leeds',
          name: 'Leeds',
          slug: 'leeds',
          country: 'United Kingdom',
          countryCode: 'GB',
          timezone: 'Europe/London',
          defaultLat: 53.8008,
          defaultLng: -1.5491,
          isActive: false,
          supportedLanguages: ['en'],
          currency: 'GBP',
          currencySymbol: '£',
          dateFormat: 'dd/MM/yyyy',
          timeFormat: 'HH:mm',
          isRTL: false,
        ),
        City(
          id: 'glasgow',
          name: 'Glasgow',
          slug: 'glasgow',
          country: 'United Kingdom',
          countryCode: 'GB',
          timezone: 'Europe/London',
          defaultLat: 55.8642,
          defaultLng: -4.2518,
          isActive: false,
          supportedLanguages: ['en'],
          currency: 'GBP',
          currencySymbol: '£',
          dateFormat: 'dd/MM/yyyy',
          timeFormat: 'HH:mm',
          isRTL: false,
        ),
        City(
          id: 'dubai',
          name: 'Dubai',
          slug: 'dubai',
          country: 'United Arab Emirates',
          countryCode: 'AE',
          timezone: 'Asia/Dubai',
          defaultLat: 25.2048,
          defaultLng: 55.2708,
          isActive: false,
          supportedLanguages: ['en', 'ar'],
          currency: 'AED',
          currencySymbol: 'د.إ',
          dateFormat: 'dd/MM/yyyy',
          timeFormat: 'HH:mm',
          isRTL: true,
        ),
      ];

  static City? findBySlug(String slug) {
    try {
      return defaultCities().firstWhere(
        (c) => c.slug.toLowerCase() == slug.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static City? findById(String id) {
    try {
      return defaultCities().firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static City? findNearest(double lat, double lng) {
    City? nearest;
    double minDistance = double.infinity;
    for (final city in defaultCities().where((city) => city.isActive)) {
      final d = _haversineDistance(lat, lng, city.defaultLat, city.defaultLng);
      if (d < minDistance) {
        minDistance = d;
        nearest = city;
      }
    }
    return minDistance <= 100000 ? nearest : null;
  }

  static double _haversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _toRadians(double d) => d * pi / 180;
}
