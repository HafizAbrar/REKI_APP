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
  });

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
  };

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
    id: json['id'],
    name: json['name'],
    type: json['category'] ?? json['type'],
    latitude: (json['lat'] ?? json['latitude']).toDouble(),
    longitude: (json['lng'] ?? json['longitude']).toDouble(),
    address: json['address'],
    busyness: json['busyness'] ?? 'QUIET',
    currentVibe: json['vibe'] ?? json['currentVibe'] ?? 'PARTY',
    availableVibes: json['availableVibes'] != null ? List<String>.from(json['availableVibes']) : ['PARTY'],
    offers: json['offers'] != null ? (json['offers'] as List).map((o) => Offer.fromJson(o)).toList() : [],
    lastUpdated: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    postcode: json['postcode'],
    coverImageUrl: json['coverImageUrl'],
    description: json['description'],
    activeOffersCount: json['activeOffersCount'] ?? 0,
  );
}