import 'offer.dart';

class Venue {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String address;
  String busyness;
  String currentVibe;
  final List<String> availableVibes;
  final List<Offer> offers;
  final DateTime lastUpdated;
  final String? postcode;
  final String? coverImageUrl;
  final String? description;
  final int activeOffersCount;
  final int? priceLevel;

  Venue({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.busyness,
    required this.currentVibe,
    required this.availableVibes,
    required this.offers,
    required this.lastUpdated,
    this.postcode,
    this.coverImageUrl,
    this.description,
    this.activeOffersCount = 0,
    this.priceLevel,
  });

  String? get budgetSymbol =>
      priceLevel == null ? null : '£' * priceLevel!.clamp(1, 4);

  String? get budgetLabel {
    switch (priceLevel) {
      case 1:
        return 'Budget';
      case 2:
        return 'Mid-range';
      case 3:
        return 'Upscale';
      case 4:
        return 'Luxury';
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'busyness': busyness,
        'currentVibe': currentVibe,
        'availableVibes': availableVibes,
        'offers': offers.map((o) => o.toJson()).toList(),
        'lastUpdated': lastUpdated.toIso8601String(),
        'postcode': postcode,
        'coverImageUrl': coverImageUrl,
        'description': description,
        'activeOffersCount': activeOffersCount,
        'priceLevel': priceLevel,
      };

  factory Venue.fromJson(Map<String, dynamic> json) {
    // busyness is an object { level, percentage } or a plain string
    final busynessRaw = json['busyness'];
    final busynessStr = (busynessRaw is Map
            ? (busynessRaw['level']?.toString() ?? 'quiet')
            : busynessRaw?.toString() ?? 'quiet')
        .toUpperCase();

    // vibe is an object { tags, description } or a plain string
    final vibeRaw = json['vibe'];
    String vibeStr = '';
    if (vibeRaw is Map) {
      final tags = vibeRaw['tags'];
      vibeStr = (tags is List && tags.isNotEmpty)
          ? tags.first.toString()
          : vibeRaw['description']?.toString() ?? '';
    } else {
      vibeStr = vibeRaw?.toString() ?? '';
    }

    // coverImageUrl: direct field or first item in images array
    String? coverImageUrl = json['coverImageUrl']?.toString();
    if (coverImageUrl == null) {
      final images = json['images'];
      if (images is List && images.isNotEmpty) {
        coverImageUrl = images.first?.toString();
      }
    }

    // offers: map using expiresAt or validUntil
    List<Offer> offers = [];
    if (json['offers'] is List) {
      for (final o in json['offers'] as List) {
        try {
          offers.add(Offer.fromJson(o as Map<String, dynamic>));
        } catch (_) {}
      }
    }

    final priceLevelRaw = json['priceLevel'] ??
        json['price_level'] ??
        json['budgetLevel'] ??
        (json['pricing'] is Map ? json['pricing']['priceLevel'] : null);
    final parsedPriceLevel = priceLevelRaw is num
        ? priceLevelRaw.toInt()
        : int.tryParse(priceLevelRaw?.toString() ?? '');

    return Venue(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? json['category']?.toString() ?? 'bar',
      latitude: double.tryParse(json['lat']?.toString() ?? '') ??
          (json['latitude'] as num?)?.toDouble() ??
          0.0,
      longitude: double.tryParse(json['lng']?.toString() ?? '') ??
          (json['longitude'] as num?)?.toDouble() ??
          0.0,
      address: json['address']?.toString() ?? '',
      busyness: busynessStr,
      currentVibe: vibeStr,
      availableVibes: json['availableVibes'] is List
          ? (json['availableVibes'] as List)
              .map((value) => value.toString())
              .toList()
          : const [],
      offers: offers,
      lastUpdated: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      postcode: json['postcode']?.toString(),
      coverImageUrl: coverImageUrl,
      description: json['description']?.toString(),
      activeOffersCount: (json['activeOffersCount'] as num?)?.toInt() ??
          (json['offers'] is List ? (json['offers'] as List).length : 0),
      priceLevel: parsedPriceLevel != null &&
              parsedPriceLevel >= 1 &&
              parsedPriceLevel <= 4
          ? parsedPriceLevel
          : null,
    );
  }
}
