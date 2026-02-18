class OfferAnalytics {
  final String offerId;
  final String offerTitle;
  final int views;
  final int clicks;
  final int redemptions;
  final double clickThroughRate;
  final double conversionRate;
  final int revenue;

  OfferAnalytics({
    required this.offerId,
    required this.offerTitle,
    required this.views,
    required this.clicks,
    required this.redemptions,
    required this.clickThroughRate,
    required this.conversionRate,
    required this.revenue,
  });

  factory OfferAnalytics.fromJson(Map<String, dynamic> json) => OfferAnalytics(
    offerId: json['offerId'],
    offerTitle: json['offerTitle'],
    views: json['views'],
    clicks: json['clicks'],
    redemptions: json['redemptions'],
    clickThroughRate: json['clickThroughRate'].toDouble(),
    conversionRate: json['conversionRate'].toDouble(),
    revenue: json['revenue'],
  );
}
