class AdminStats {
  final int totalUsers;
  final int totalVenues;
  final int totalOffers;
  final int totalRedemptions;
  final int activeVenues;
  final int activeOffers;

  const AdminStats({
    required this.totalUsers,
    required this.totalVenues,
    required this.totalOffers,
    required this.totalRedemptions,
    required this.activeVenues,
    required this.activeOffers,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    final d = (json['data'] ?? json) as Map<String, dynamic>;
    return AdminStats(
      totalUsers: d['totalUsers'] ?? 0,
      totalVenues: d['totalVenues'] ?? 0,
      totalOffers: d['totalOffers'] ?? 0,
      totalRedemptions: d['totalRedemptions'] ?? 0,
      activeVenues: d['activeVenues'] ?? 0,
      activeOffers: d['activeOffers'] ?? 0,
    );
  }
}

class AdminUser {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  const AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        id: json['id']?.toString() ?? '',
        email: json['email'] ?? '',
        name: json['fullName'] ?? json['name'] ?? '',
        role: json['role'] ?? 'USER',
        isActive: json['isActive'] ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );
}

class AdminVenue {
  final String id;
  final String name;
  final String category;
  final String busyness;
  final String vibe;
  final bool isActive;
  final int activeOffersCount;

  const AdminVenue({
    required this.id,
    required this.name,
    required this.category,
    required this.busyness,
    required this.vibe,
    required this.isActive,
    required this.activeOffersCount,
  });

  factory AdminVenue.fromJson(Map<String, dynamic> json) => AdminVenue(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        category: json['category'] ?? json['type'] ?? '',
        busyness: json['busyness'] ?? 'QUIET',
        vibe: json['vibe'] ?? json['currentVibe'] ?? '',
        isActive: json['isActive'] ?? true,
        activeOffersCount: json['activeOffersCount'] ?? 0,
      );
}

class AdminOffer {
  final String id;
  final String title;
  final String type;
  final bool isActive;
  final int redemptionCount;
  final String venueName;

  const AdminOffer({
    required this.id,
    required this.title,
    required this.type,
    required this.isActive,
    required this.redemptionCount,
    required this.venueName,
  });

  factory AdminOffer.fromJson(Map<String, dynamic> json) => AdminOffer(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? '',
        type: json['offerType'] ?? json['type'] ?? '',
        isActive: json['isActive'] ?? false,
        redemptionCount: json['redemptionCount'] ?? 0,
        venueName: json['venue']?['name'] ?? '',
      );
}

class AdminRedemption {
  final String id;
  final String offerTitle;
  final String userName;
  final String venueName;
  final DateTime redeemedAt;

  const AdminRedemption({
    required this.id,
    required this.offerTitle,
    required this.userName,
    required this.venueName,
    required this.redeemedAt,
  });

  factory AdminRedemption.fromJson(Map<String, dynamic> json) =>
      AdminRedemption(
        id: json['id']?.toString() ?? '',
        offerTitle: json['offer']?['title'] ?? json['offerTitle'] ?? '',
        userName: json['user']?['fullName'] ??
            json['user']?['name'] ??
            json['userName'] ??
            '',
        venueName: json['venue']?['name'] ?? json['venueName'] ?? '',
        redeemedAt: json['redeemedAt'] != null
            ? DateTime.parse(json['redeemedAt'])
            : DateTime.now(),
      );
}

class ActivityLog {
  final String id;
  final String action;
  final String userId;
  final String? details;
  final DateTime createdAt;

  const ActivityLog({
    required this.id,
    required this.action,
    required this.userId,
    this.details,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) => ActivityLog(
        id: json['id']?.toString() ?? '',
        action: json['action'] ?? json['type'] ?? '',
        userId: json['userId']?.toString() ??
            json['user']?['id']?.toString() ??
            '',
        details: json['details']?.toString(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );
}
