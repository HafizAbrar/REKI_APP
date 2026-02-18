class VibeSchedule {
  final String id;
  final String venueId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String vibe;
  final int priority;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  VibeSchedule({
    required this.id,
    required this.venueId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.vibe,
    required this.priority,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VibeSchedule.fromJson(Map<String, dynamic> json) => VibeSchedule(
    id: json['id'],
    venueId: json['venueId'],
    dayOfWeek: json['dayOfWeek'],
    startTime: json['startTime'],
    endTime: json['endTime'],
    vibe: json['vibe'],
    priority: json['priority'],
    isActive: json['isActive'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  String get dayName {
    switch (dayOfWeek) {
      case 0: return 'Sunday';
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      default: return '';
    }
  }
}
