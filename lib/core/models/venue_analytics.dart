class VenueAnalytics {
  final String venueId;
  final String venueName;
  final int totalVisits;
  final int uniqueVisitors;
  final int averageStayMinutes;
  final Map<String, int> peakHours;
  final Map<String, int> vibeDistribution;

  VenueAnalytics({
    required this.venueId,
    required this.venueName,
    required this.totalVisits,
    required this.uniqueVisitors,
    required this.averageStayMinutes,
    required this.peakHours,
    required this.vibeDistribution,
  });

  factory VenueAnalytics.fromJson(Map<String, dynamic> json) => VenueAnalytics(
    venueId: json['venueId'],
    venueName: json['venueName'],
    totalVisits: json['totalVisits'],
    uniqueVisitors: json['uniqueVisitors'],
    averageStayMinutes: json['averageStayMinutes'],
    peakHours: Map<String, int>.from(json['peakHours']),
    vibeDistribution: Map<String, int>.from(json['vibeDistribution']),
  );
}
