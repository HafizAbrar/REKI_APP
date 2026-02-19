class Offer {
  final String id;
  final String title;
  final String description;
  final String type;
  final bool isActive;
  final DateTime validUntil;
  final String terms;
  final Map<String, dynamic>? venue;

  Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.isActive,
    required this.validUntil,
    this.terms = '',
    this.venue,
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
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    type: json['offerType']?.toString() ?? json['type']?.toString() ?? '',
    isActive: json['isActive'] ?? false,
    validUntil: json['endsAt'] != null ? DateTime.parse(json['endsAt']) : (json['validUntil'] != null ? DateTime.parse(json['validUntil']) : DateTime.now()),
    terms: json['terms']?.toString() ?? '',
    venue: json['venue'],
  );
}