class PlatformEngagement {
  final int totalUsers;
  final int activeUsers;
  final int totalVenues;
  final int totalOffers;
  final int totalRedemptions;
  final Map<String, int> usersByCity;
  final Map<String, int> venuesByType;

  PlatformEngagement({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalVenues,
    required this.totalOffers,
    required this.totalRedemptions,
    required this.usersByCity,
    required this.venuesByType,
  });

  factory PlatformEngagement.fromJson(Map<String, dynamic> json) => PlatformEngagement(
    totalUsers: json['totalUsers'],
    activeUsers: json['activeUsers'],
    totalVenues: json['totalVenues'],
    totalOffers: json['totalOffers'],
    totalRedemptions: json['totalRedemptions'],
    usersByCity: Map<String, int>.from(json['usersByCity']),
    venuesByType: Map<String, int>.from(json['venuesByType']),
  );
}
