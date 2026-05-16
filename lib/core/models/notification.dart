enum NotificationType {
  offer,
  venue,
  system,
  welcome,
  vibe,
  alert,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final String? icon;
  final String? venueId;
  final String? offerId;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.icon,
    this.venueId,
    this.offerId,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    NotificationType resolveType(dynamic raw) {
      switch (raw?.toString().toLowerCase()) {
        case 'offer': return NotificationType.offer;
        case 'venue': return NotificationType.venue;
        case 'welcome': return NotificationType.welcome;
        case 'vibe': return NotificationType.vibe;
        case 'alert': return NotificationType.alert;
        default:
          if (raw?.toString().toLowerCase().contains('offer') == true) return NotificationType.offer;
          if (raw?.toString().toLowerCase().contains('venue') == true) return NotificationType.venue;
          if (raw?.toString().toLowerCase().contains('vibe') == true) return NotificationType.vibe;
          return NotificationType.system;
      }
    }

    DateTime resolveTimestamp(dynamic raw) {
      if (raw == null) return DateTime.now();
      try { return DateTime.parse(raw.toString()); } catch (_) { return DateTime.now(); }
    }

    return AppNotification(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? 'Notification',
      message: data['message']?.toString() ?? data['body']?.toString() ?? '',
      type: resolveType(data['type']),
      timestamp: resolveTimestamp(
          data['createdAt'] ?? data['timestamp'] ?? data['sentAt']),
      icon: data['icon']?.toString(),
      venueId: data['venueId']?.toString(),
      offerId: data['offerId']?.toString(),
      isRead: data['isRead'] ?? data['read'] ?? false,
    );
  }
}