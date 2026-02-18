class City {
  final String id;
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final bool isActive;

  City({
    required this.id,
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.isActive,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
    id: json['id'],
    name: json['name'],
    country: json['country'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    isActive: json['isActive'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'isActive': isActive,
  };
}
