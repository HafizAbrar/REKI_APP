class Offer {
  final String id;
  final String title;
  final String description;
  final String type;
  final bool isActive;
  final DateTime validUntil;
  final String terms;

  Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.isActive,
    required this.validUntil,
    this.terms = '',
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