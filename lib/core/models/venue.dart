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
  };

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    address: json['address'],
    busyness: json['busyness'],
    currentVibe: json['currentVibe'],
    availableVibes: List<String>.from(json['availableVibes']),
    offers: (json['offers'] as List).map((o) => Offer.fromJson(o)).toList(),
    lastUpdated: DateTime.parse(json['lastUpdated']),
  );
}

class Offer {
  final String id;
  final String title;
  final String description;
  final String type;
  final bool isActive;
  final DateTime validUntil;

  Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.isActive,
    required this.validUntil,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type,
    'isActive': isActive,
    'validUntil': validUntil.toIso8601String(),
  };

  factory Offer.fromJson(Map<String, dynamic> json) => Offer(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    type: json['type'],
    isActive: json['isActive'],
    validUntil: DateTime.parse(json['validUntil']),
  );
}