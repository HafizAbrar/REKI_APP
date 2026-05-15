class Offer {
  final String id;
  final String title;
  final String description;
  final String type;
  final bool isActive;
  final DateTime validUntil;
  final String terms;
  final Map<String, dynamic>? venue;
  final List<String> validDays;
  final String? validTimeStart;
  final String? validTimeEnd;
  final int? maxRedemptions;
  final num? savingValue;
  final String status;
  final bool isAvailableNow;

  Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.isActive,
    required this.validUntil,
    this.terms = '',
    this.venue,
    this.validDays = const [],
    this.validTimeStart,
    this.validTimeEnd,
    this.maxRedemptions,
    this.savingValue,
    this.status = 'inactive',
    this.isAvailableNow = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type,
    'isActive': isActive,
    'expiresAt': validUntil.toIso8601String(),
    'validDays': validDays,
    if (validTimeStart != null) 'validTimeStart': validTimeStart,
    if (validTimeEnd != null) 'validTimeEnd': validTimeEnd,
    if (maxRedemptions != null) 'maxRedemptions': maxRedemptions,
    if (savingValue != null) 'savingValue': savingValue,
    'status': status,
    'isAvailableNow': isAvailableNow,
  };

  factory Offer.fromJson(Map<String, dynamic> json) => Offer(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    type: json['type']?.toString() ?? json['offerType']?.toString() ?? 'discount',
    isActive: json['isActive'] ?? false,
    validUntil: json['expiresAt'] != null
        ? DateTime.parse(json['expiresAt'])
        : json['endsAt'] != null
            ? DateTime.parse(json['endsAt'])
            : json['validUntil'] != null
                ? DateTime.parse(json['validUntil'])
                : DateTime.now(),
    terms: json['terms']?.toString() ?? '',
    venue: json['venue'] as Map<String, dynamic>?,
    validDays: (json['validDays'] as List?)?.map((e) => e.toString()).toList() ?? [],
    validTimeStart: json['validTimeStart']?.toString(),
    validTimeEnd: json['validTimeEnd']?.toString(),
    maxRedemptions: json['maxRedemptions'] as int?,
    savingValue: json['savingValue'] as num?,
    status: json['status']?.toString() ?? 'inactive',
    isAvailableNow: json['isAvailableNow'] as bool? ?? false,
  );
}
