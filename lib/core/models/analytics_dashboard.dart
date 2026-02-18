class AnalyticsDashboard {
  final int totalRevenue;
  final int totalOffers;
  final int activeOffers;
  final int totalRedemptions;
  final int totalViews;
  final int totalClicks;
  final double conversionRate;

  AnalyticsDashboard({
    required this.totalRevenue,
    required this.totalOffers,
    required this.activeOffers,
    required this.totalRedemptions,
    required this.totalViews,
    required this.totalClicks,
    required this.conversionRate,
  });

  factory AnalyticsDashboard.fromJson(Map<String, dynamic> json) => AnalyticsDashboard(
    totalRevenue: json['totalRevenue'],
    totalOffers: json['totalOffers'],
    activeOffers: json['activeOffers'],
    totalRedemptions: json['totalRedemptions'],
    totalViews: json['totalViews'],
    totalClicks: json['totalClicks'],
    conversionRate: json['conversionRate'].toDouble(),
  );
}
