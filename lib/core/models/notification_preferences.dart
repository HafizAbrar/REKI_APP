class NotificationPreferences {
  final String id;
  final String userId;
  final bool vibeAlerts;
  final bool livePerformance;
  final bool socialCheckins;
  final bool offerAlerts;
  final bool weeklyRecap;
  final bool proximityAlerts;
  final String? quietHoursStart;
  final String? quietHoursEnd;

  const NotificationPreferences({
    required this.id,
    required this.userId,
    required this.vibeAlerts,
    required this.livePerformance,
    required this.socialCheckins,
    required this.offerAlerts,
    required this.weeklyRecap,
    required this.proximityAlerts,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      id: json['id'] as String,
      userId: json['userId'] as String,
      vibeAlerts: json['vibeAlerts'] as bool? ?? true,
      livePerformance: json['livePerformance'] as bool? ?? true,
      socialCheckins: json['socialCheckins'] as bool? ?? true,
      offerAlerts: json['offerAlerts'] as bool? ?? true,
      weeklyRecap: json['weeklyRecap'] as bool? ?? true,
      proximityAlerts: json['proximityAlerts'] as bool? ?? true,
      quietHoursStart: json['quietHoursStart'] as String?,
      quietHoursEnd: json['quietHoursEnd'] as String?,
    );
  }

  Map<String, dynamic> toUpdateJson() => {
        'vibeAlerts': vibeAlerts,
        'livePerformance': livePerformance,
        'socialCheckins': socialCheckins,
        'offerAlerts': offerAlerts,
        'weeklyRecap': weeklyRecap,
        'proximityAlerts': proximityAlerts,
        'quietHoursStart': quietHoursStart,
        'quietHoursEnd': quietHoursEnd,
      };

  NotificationPreferences copyWith({
    bool? vibeAlerts,
    bool? livePerformance,
    bool? socialCheckins,
    bool? offerAlerts,
    bool? weeklyRecap,
    bool? proximityAlerts,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationPreferences(
      id: id,
      userId: userId,
      vibeAlerts: vibeAlerts ?? this.vibeAlerts,
      livePerformance: livePerformance ?? this.livePerformance,
      socialCheckins: socialCheckins ?? this.socialCheckins,
      offerAlerts: offerAlerts ?? this.offerAlerts,
      weeklyRecap: weeklyRecap ?? this.weeklyRecap,
      proximityAlerts: proximityAlerts ?? this.proximityAlerts,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}
