class TestPushResult {
  final bool sent;
  final bool firebaseConfigured;
  final int totalSent;
  final int delivered;
  final int failed;
  final int opened;
  final String openRate;

  const TestPushResult({
    required this.sent,
    required this.firebaseConfigured,
    required this.totalSent,
    required this.delivered,
    required this.failed,
    required this.opened,
    required this.openRate,
  });

  factory TestPushResult.fromJson(Map<String, dynamic> json) {
    final ps = json['pushStats'] as Map<String, dynamic>? ?? {};
    return TestPushResult(
      sent: json['sent'] as bool? ?? false,
      firebaseConfigured: json['firebaseConfigured'] as bool? ?? false,
      totalSent: ps['totalSent'] as int? ?? 0,
      delivered: ps['delivered'] as int? ?? 0,
      failed: ps['failed'] as int? ?? 0,
      opened: ps['opened'] as int? ?? 0,
      openRate: ps['openRate']?.toString() ?? '0%',
    );
  }
}

class OfflineStats {
  final int totalSyncActions;
  final int pendingSyncActions;
  final int successfulSyncs;
  final int conflictsToday;
  final int rejectedToday;
  final String syncSuccessRate;
  final String avgSyncDelay;

  const OfflineStats({
    required this.totalSyncActions,
    required this.pendingSyncActions,
    required this.successfulSyncs,
    required this.conflictsToday,
    required this.rejectedToday,
    required this.syncSuccessRate,
    required this.avgSyncDelay,
  });

  factory OfflineStats.fromJson(Map<String, dynamic> json) {
    // Handle: { data: {...} }, { offlineStats: {...} }, or flat
    final d = (json['data'] ?? json['offlineStats'] ?? json) as Map<String, dynamic>;
    return OfflineStats(
      totalSyncActions: d['totalSyncActions'] as int? ?? json['totalSyncActions'] as int? ?? 0,
      pendingSyncActions: d['pendingSyncActions'] as int? ?? json['pendingSyncActions'] as int? ?? 0,
      successfulSyncs: d['successfulSyncs'] as int? ?? json['successfulSyncs'] as int? ?? 0,
      conflictsToday: d['conflictsToday'] as int? ?? json['conflictsToday'] as int? ?? 0,
      rejectedToday: d['rejectedToday'] as int? ?? json['rejectedToday'] as int? ?? 0,
      syncSuccessRate: d['syncSuccessRate']?.toString() ?? json['syncSuccessRate']?.toString() ?? '0.0%',
      avgSyncDelay: d['avgSyncDelay']?.toString() ?? json['avgSyncDelay']?.toString() ?? '0 minutes',
    );
  }
}

class RealtimeStats {
  final int activeWebSocketConnections;
  final int uniqueConnectedUsers;
  final int pushNotificationsSentToday;
  final int pushDelivered;
  final int pushFailed;
  final String pushOpenRate;
  final int registeredDevices;
  final bool fcmConfigured;

  const RealtimeStats({
    required this.activeWebSocketConnections,
    required this.uniqueConnectedUsers,
    required this.pushNotificationsSentToday,
    required this.pushDelivered,
    required this.pushFailed,
    required this.pushOpenRate,
    required this.registeredDevices,
    required this.fcmConfigured,
  });

  factory RealtimeStats.fromJson(Map<String, dynamic> json) {
    // Handle: { realTimeStats: {...} }, { data: {...} }, or flat
    final d = (json['realTimeStats'] ?? json['realtimeStats'] ?? json['data'] ?? json) as Map<String, dynamic>;
    return RealtimeStats(
      activeWebSocketConnections: d['activeWebSocketConnections'] as int? ?? json['activeWebSocketConnections'] as int? ?? 0,
      uniqueConnectedUsers: d['uniqueConnectedUsers'] as int? ?? json['uniqueConnectedUsers'] as int? ?? 0,
      pushNotificationsSentToday: d['pushNotificationsSentToday'] as int? ?? json['pushNotificationsSentToday'] as int? ?? 0,
      pushDelivered: d['pushDelivered'] as int? ?? json['pushDelivered'] as int? ?? 0,
      pushFailed: d['pushFailed'] as int? ?? json['pushFailed'] as int? ?? 0,
      pushOpenRate: d['pushOpenRate']?.toString() ?? json['pushOpenRate']?.toString() ?? '0%',
      registeredDevices: d['registeredDevices'] as int? ?? json['registeredDevices'] as int? ?? 0,
      fcmConfigured: d['fcmConfigured'] as bool? ?? json['fcmConfigured'] as bool? ?? false,
    );
  }
}

class AdminStats {
  final int totalUsers;
  final int totalVenues;
  final int activeOffers;
  final int redemptionsToday;
  final int newSignupsToday;
  final int liveVenuesNow;

  const AdminStats({
    required this.totalUsers,
    required this.totalVenues,
    required this.activeOffers,
    required this.redemptionsToday,
    required this.newSignupsToday,
    required this.liveVenuesNow,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    // Handle: { data: {...} }, { stats: {...} }, or flat
    final d = (json['data'] ?? json['stats'] ?? json) as Map<String, dynamic>;
    return AdminStats(
      totalUsers: d['totalUsers'] as int? ?? json['totalUsers'] as int? ?? 0,
      totalVenues: d['totalVenues'] as int? ?? json['totalVenues'] as int? ?? 0,
      activeOffers: d['activeOffers'] as int? ?? json['activeOffers'] as int? ?? 0,
      redemptionsToday: d['redemptionsToday'] as int? ?? json['redemptionsToday'] as int? ?? 0,
      newSignupsToday: d['newSignupsToday'] as int? ?? json['newSignupsToday'] as int? ?? 0,
      liveVenuesNow: d['liveVenuesNow'] as int? ?? json['liveVenuesNow'] as int? ?? 0,
    );
  }
}

class TopArea {
  final String name;
  final int venueCount;
  final int avgBusyness;

  const TopArea({
    required this.name,
    required this.venueCount,
    required this.avgBusyness,
  });

  factory TopArea.fromJson(Map<String, dynamic> json) => TopArea(
        name: json['name']?.toString() ?? '',
        venueCount: json['venueCount'] ?? 0,
        avgBusyness: json['avgBusyness'] ?? 0,
      );
}

class LocationStats {
  final int usersWithLocation;
  final int geofenceNotificationsSent;
  final List<TopArea> topAreas;

  const LocationStats({
    required this.usersWithLocation,
    required this.geofenceNotificationsSent,
    required this.topAreas,
  });

  factory LocationStats.fromJson(Map<String, dynamic> json) {
    // Handle: { data: {...} }, { locationStats: {...} }, or flat
    final d = (json['data'] ?? json['locationStats'] ?? json) as Map<String, dynamic>;
    return LocationStats(
      usersWithLocation: d['usersWithLocation'] as int? ?? json['usersWithLocation'] as int? ?? 0,
      geofenceNotificationsSent: d['geofenceNotificationsSent'] as int? ?? json['geofenceNotificationsSent'] as int? ?? 0,
      topAreas: (d['topAreas'] as List? ?? json['topAreas'] as List? ?? [])
          .map((e) => TopArea.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AdminUser {
  final String id;
  final String? email;
  final String name;
  final String role;
  final String authProvider;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;

  const AdminUser({
    required this.id,
    this.email,
    required this.name,
    required this.role,
    required this.authProvider,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        id: json['id']?.toString() ?? '',
        email: json['email']?.toString(),
        name: json['fullName']?.toString() ?? json['name']?.toString() ?? 'Unknown',
        role: json['role']?.toString() ?? 'user',
        authProvider: json['authProvider']?.toString() ?? 'email',
        isVerified: json['isVerified'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
      );
}

class AdminUsersPage {
  final List<AdminUser> users;
  final int total;
  final int page;
  final int pages;
  final bool hasNext;
  final bool hasPrev;

  const AdminUsersPage({
    required this.users,
    required this.total,
    required this.page,
    required this.pages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory AdminUsersPage.fromJson(Map<String, dynamic> json) {
    final list = (json['users'] as List? ?? [])
        .map((e) => AdminUser.fromJson(e as Map<String, dynamic>))
        .toList();
    return AdminUsersPage(
      users: list,
      total: json['total'] ?? list.length,
      page: json['page'] ?? 1,
      pages: json['pages'] ?? 1,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrev: json['hasPrev'] as bool? ?? false,
    );
  }
}

class AdminVenue {
  final String id;
  final String name;
  final String address;
  final String city;
  final String category;
  final String busynessLevel;
  final int busynessPercent;
  final List<String> vibes;
  final bool isLive;

  const AdminVenue({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.category,
    required this.busynessLevel,
    required this.busynessPercent,
    required this.vibes,
    required this.isLive,
  });

  factory AdminVenue.fromJson(Map<String, dynamic> json) => AdminVenue(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        category: json['category']?.toString() ?? json['type']?.toString() ?? '',
        busynessLevel: json['busynessLevel']?.toString() ??
            json['busyness']?.toString() ?? 'quiet',
        busynessPercent: json['busynessPercent'] as int? ?? 0,
        vibes: (json['vibes'] as List? ?? [])
            .map((e) => e.toString())
            .toList(),
        isLive: json['isLive'] as bool? ?? json['isActive'] as bool? ?? false,
      );
}

class AdminVenuesPage {
  final List<AdminVenue> venues;
  final int total;
  final int page;
  final int pages;
  final bool hasNext;
  final bool hasPrev;

  const AdminVenuesPage({
    required this.venues,
    required this.total,
    required this.page,
    required this.pages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory AdminVenuesPage.fromJson(Map<String, dynamic> json) {
    final list = (json['venues'] as List? ?? [])
        .map((e) => AdminVenue.fromJson(e as Map<String, dynamic>))
        .toList();
    return AdminVenuesPage(
      venues: list,
      total: json['total'] as int? ?? list.length,
      page: json['page'] as int? ?? 1,
      pages: json['pages'] as int? ?? 1,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrev: json['hasPrev'] as bool? ?? false,
    );
  }
}

class AdminOffer {
  final String id;
  final String title;
  final String type;
  final String venueName;
  final String venueId;
  final bool isActive;
  final int redemptionCount;
  final int maxRedemptions;
  final DateTime createdAt;
  final DateTime expiresAt;

  const AdminOffer({
    required this.id,
    required this.title,
    required this.type,
    required this.venueName,
    required this.venueId,
    required this.isActive,
    required this.redemptionCount,
    required this.maxRedemptions,
    required this.createdAt,
    required this.expiresAt,
  });

  factory AdminOffer.fromJson(Map<String, dynamic> json) => AdminOffer(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        type: json['type']?.toString() ?? json['offerType']?.toString() ?? '',
        venueName: json['venueName']?.toString() ??
            json['venue']?['name']?.toString() ?? '',
        venueId: json['venueId']?.toString() ??
            json['venue']?['id']?.toString() ?? '',
        isActive: json['isActive'] as bool? ?? false,
        redemptionCount: json['redemptionCount'] as int? ?? 0,
        maxRedemptions: json['maxRedemptions'] as int? ?? 0,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'].toString())
            : DateTime.now(),
      );
}

class AdminOffersPage {
  final List<AdminOffer> offers;
  final int total;
  final int page;
  final int pages;
  final bool hasNext;
  final bool hasPrev;

  const AdminOffersPage({
    required this.offers,
    required this.total,
    required this.page,
    required this.pages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory AdminOffersPage.fromJson(Map<String, dynamic> json) {
    final list = (json['offers'] as List? ?? [])
        .map((e) => AdminOffer.fromJson(e as Map<String, dynamic>))
        .toList();
    return AdminOffersPage(
      offers: list,
      total: json['total'] as int? ?? list.length,
      page: json['page'] as int? ?? 1,
      pages: json['pages'] as int? ?? 1,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrev: json['hasPrev'] as bool? ?? false,
    );
  }
}

class AdminRedemption {
  final String id;
  final String userName;
  final String userId;
  final String venueName;
  final String venueId;
  final String offerTitle;
  final String offerId;
  final String voucherCode;
  final String transactionId;
  final String status;
  final num savingValue;
  final String currency;
  final DateTime? redeemedAt;
  final DateTime createdAt;

  const AdminRedemption({
    required this.id,
    required this.userName,
    required this.userId,
    required this.venueName,
    required this.venueId,
    required this.offerTitle,
    required this.offerId,
    required this.voucherCode,
    required this.transactionId,
    required this.status,
    required this.savingValue,
    required this.currency,
    this.redeemedAt,
    required this.createdAt,
  });

  factory AdminRedemption.fromJson(Map<String, dynamic> json) =>
      AdminRedemption(
        id: json['id']?.toString() ?? '',
        userName: json['userName']?.toString() ??
            json['user']?['fullName']?.toString() ??
            json['user']?['name']?.toString() ?? '',
        userId: json['userId']?.toString() ??
            json['user']?['id']?.toString() ?? '',
        venueName: json['venueName']?.toString() ??
            json['venue']?['name']?.toString() ?? '',
        venueId: json['venueId']?.toString() ??
            json['venue']?['id']?.toString() ?? '',
        offerTitle: json['offerTitle']?.toString() ??
            json['offer']?['title']?.toString() ?? '',
        offerId: json['offerId']?.toString() ??
            json['offer']?['id']?.toString() ?? '',
        voucherCode: json['voucherCode']?.toString() ?? '',
        transactionId: json['transactionId']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        savingValue: json['savingValue'] as num? ?? 0,
        currency: json['currency']?.toString() ?? 'GBP',
        redeemedAt: json['redeemedAt'] != null
            ? DateTime.tryParse(json['redeemedAt'].toString())
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
      );
}

class AdminRedemptionsPage {
  final List<AdminRedemption> redemptions;
  final int total;
  final int page;
  final int pages;
  final bool hasNext;
  final bool hasPrev;

  const AdminRedemptionsPage({
    required this.redemptions,
    required this.total,
    required this.page,
    required this.pages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory AdminRedemptionsPage.fromJson(Map<String, dynamic> json) {
    final list = (json['redemptions'] as List? ?? [])
        .map((e) => AdminRedemption.fromJson(e as Map<String, dynamic>))
        .toList();
    return AdminRedemptionsPage(
      redemptions: list,
      total: json['total'] as int? ?? list.length,
      page: json['page'] as int? ?? 1,
      pages: json['pages'] as int? ?? 1,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrev: json['hasPrev'] as bool? ?? false,
    );
  }
}

class UserActivityRedemption {
  final String id;
  final String voucherCode;
  final String status;
  final String transactionId;
  final String savingValue;
  final String currency;
  final DateTime? redeemedAt;
  final DateTime createdAt;
  final String offerTitle;
  final String offerType;
  final String venueName;
  final String venueAddress;

  const UserActivityRedemption({
    required this.id,
    required this.voucherCode,
    required this.status,
    required this.transactionId,
    required this.savingValue,
    required this.currency,
    this.redeemedAt,
    required this.createdAt,
    required this.offerTitle,
    required this.offerType,
    required this.venueName,
    required this.venueAddress,
  });

  factory UserActivityRedemption.fromJson(Map<String, dynamic> json) =>
      UserActivityRedemption(
        id: json['id']?.toString() ?? '',
        voucherCode: json['voucherCode']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        transactionId: json['transactionId']?.toString() ?? '',
        savingValue: json['savingValue']?.toString() ?? '0.00',
        currency: json['currency']?.toString() ?? 'GBP',
        redeemedAt: json['redeemedAt'] != null
            ? DateTime.tryParse(json['redeemedAt'].toString())
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
        offerTitle: json['offer']?['title']?.toString() ?? '',
        offerType: json['offer']?['type']?.toString() ?? '',
        venueName: json['venue']?['name']?.toString() ?? '',
        venueAddress: json['venue']?['address']?.toString() ?? '',
      );
}

class UserActivityData {
  final String id;
  final String? email;
  final String name;
  final String role;
  final DateTime createdAt;
  final List<UserActivityRedemption> redemptions;
  final int totalRedemptions;

  const UserActivityData({
    required this.id,
    this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.redemptions,
    required this.totalRedemptions,
  });

  factory UserActivityData.fromJson(Map<String, dynamic> json) {
    final u = json['user'] as Map<String, dynamic>? ?? {};
    return UserActivityData(
      id: u['id']?.toString() ?? '',
      email: u['email']?.toString(),
      name: u['name']?.toString() ?? '',
      role: u['role']?.toString() ?? '',
      createdAt: u['createdAt'] != null
          ? DateTime.parse(u['createdAt'].toString())
          : DateTime.now(),
      redemptions: (json['redemptions'] as List? ?? [])
          .map((e) =>
              UserActivityRedemption.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalRedemptions: json['totalRedemptions'] as int? ?? 0,
    );
  }
}

class VenueLogDetails {
  final String? busyness;
  final int? percentage;
  final List<String> vibes;
  final String? name;

  const VenueLogDetails({
    this.busyness,
    this.percentage,
    this.vibes = const [],
    this.name,
  });

  factory VenueLogDetails.fromJson(Map<String, dynamic> json) => VenueLogDetails(
        busyness: json['busyness']?.toString(),
        percentage: json['percentage'] as int?,
        vibes: (json['vibes'] as List? ?? []).map((e) => e.toString()).toList(),
        name: json['name']?.toString(),
      );
}

class VenueLog {
  final String id;
  final String actorId;
  final String actorRole;
  final String action;
  final String target;
  final String targetId;
  final VenueLogDetails details;
  final DateTime createdAt;

  const VenueLog({
    required this.id,
    required this.actorId,
    required this.actorRole,
    required this.action,
    required this.target,
    required this.targetId,
    required this.details,
    required this.createdAt,
  });

  factory VenueLog.fromJson(Map<String, dynamic> json) => VenueLog(
        id: json['id']?.toString() ?? '',
        actorId: json['actorId']?.toString() ?? '',
        actorRole: json['actorRole']?.toString() ?? '',
        action: json['action']?.toString() ?? '',
        target: json['target']?.toString() ?? '',
        targetId: json['targetId']?.toString() ?? '',
        details: json['details'] is Map<String, dynamic>
            ? VenueLogDetails.fromJson(json['details'] as Map<String, dynamic>)
            : const VenueLogDetails(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
      );
}

class VenueLogsData {
  final List<VenueLog> logs;
  final int count;

  const VenueLogsData({required this.logs, required this.count});

  factory VenueLogsData.fromJson(Map<String, dynamic> json) {
    final list = (json['logs'] as List? ?? [])
        .map((e) => VenueLog.fromJson(e as Map<String, dynamic>))
        .toList();
    return VenueLogsData(
      logs: list,
      count: json['count'] as int? ?? list.length,
    );
  }
}

class AdminNotification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String? venueId;
  final String? offerId;
  final bool isRead;
  final DateTime createdAt;

  const AdminNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.venueId,
    this.offerId,
    required this.isRead,
    required this.createdAt,
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) =>
      AdminNotification(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        venueId: json['venueId']?.toString(),
        offerId: json['offerId']?.toString(),
        isRead: json['isRead'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
      );
}

class AdminNotificationsPage {
  final List<AdminNotification> notifications;
  final int total;
  final int page;
  final int pages;
  final bool hasNext;
  final bool hasPrev;

  const AdminNotificationsPage({
    required this.notifications,
    required this.total,
    required this.page,
    required this.pages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory AdminNotificationsPage.fromJson(Map<String, dynamic> json) {
    final list = (json['notifications'] as List? ?? [])
        .map((e) => AdminNotification.fromJson(e as Map<String, dynamic>))
        .toList();
    return AdminNotificationsPage(
      notifications: list,
      total: json['total'] as int? ?? list.length,
      page: json['page'] as int? ?? 1,
      pages: json['pages'] as int? ?? 1,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrev: json['hasPrev'] as bool? ?? false,
    );
  }
}

class ActivityLog {
  final String id;
  final String actorId;
  final String actorRole;
  final String action;
  final String target;
  final String targetId;
  final Map<String, dynamic>? details;
  final DateTime createdAt;

  const ActivityLog({
    required this.id,
    required this.actorId,
    required this.actorRole,
    required this.action,
    required this.target,
    required this.targetId,
    this.details,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) => ActivityLog(
        id: json['id']?.toString() ?? '',
        actorId: json['actorId']?.toString() ?? '',
        actorRole: json['actorRole']?.toString() ?? '',
        action: json['action']?.toString() ?? '',
        target: json['target']?.toString() ?? '',
        targetId: json['targetId']?.toString() ?? '',
        details: json['details'] is Map<String, dynamic>
            ? json['details'] as Map<String, dynamic>
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
      );
}

class ActivityLogsPage {
  final List<ActivityLog> logs;
  final int total;
  final int page;
  final int pages;
  final bool hasNext;
  final bool hasPrev;

  const ActivityLogsPage({
    required this.logs,
    required this.total,
    required this.page,
    required this.pages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory ActivityLogsPage.fromJson(Map<String, dynamic> json) {
    final list = (json['logs'] as List? ?? [])
        .map((e) => ActivityLog.fromJson(e as Map<String, dynamic>))
        .toList();
    return ActivityLogsPage(
      logs: list,
      total: json['total'] as int? ?? list.length,
      page: json['page'] as int? ?? 1,
      pages: json['pages'] as int? ?? 1,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrev: json['hasPrev'] as bool? ?? false,
    );
  }
}
