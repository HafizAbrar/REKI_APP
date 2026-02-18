class AutomationStatus {
  final bool vibeScheduleEnabled;
  final bool busynessSimulationEnabled;
  final String lastVibeUpdate;
  final String lastBusynessUpdate;

  AutomationStatus({
    required this.vibeScheduleEnabled,
    required this.busynessSimulationEnabled,
    required this.lastVibeUpdate,
    required this.lastBusynessUpdate,
  });

  factory AutomationStatus.fromJson(Map<String, dynamic> json) => AutomationStatus(
    vibeScheduleEnabled: json['vibeScheduleEnabled'],
    busynessSimulationEnabled: json['busynessSimulationEnabled'],
    lastVibeUpdate: json['lastVibeUpdate'],
    lastBusynessUpdate: json['lastBusynessUpdate'],
  );
}
