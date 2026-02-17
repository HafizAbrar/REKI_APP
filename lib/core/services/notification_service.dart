import '../models/notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;

  void initialize() {
    _notifications = _getMockNotifications();
  }

  List<AppNotification> _getMockNotifications() {
    return [
      AppNotification(
        id: '1',
        title: 'New Offer Available',
        message: 'The Alchemist has a new 2-for-1 cocktail offer',
        type: NotificationType.offer,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      AppNotification(
        id: '2',
        title: 'Venue Update',
        message: 'Revolution is now less busy - perfect time to visit!',
        type: NotificationType.venue,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      AppNotification(
        id: '3',
        title: 'Offer Redeemed',
        message: 'You successfully redeemed your offer at Dishoom',
        type: NotificationType.system,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
    ];
  }

  void markAsRead(String id) {
    final notification = _notifications.firstWhere((n) => n.id == id);
    notification.isRead = true;
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
  }
}