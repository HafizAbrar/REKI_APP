class VenueReview {
  final String id;
  final String venueId;
  final String userName;
  final String? userAvatarUrl;
  final int rating;
  final String text;
  final bool vibeAccurate;
  final DateTime createdAt;
  final bool isMine;

  const VenueReview({
    required this.id,
    required this.venueId,
    required this.userName,
    this.userAvatarUrl,
    required this.rating,
    required this.text,
    required this.vibeAccurate,
    required this.createdAt,
    this.isMine = false,
  });

  factory VenueReview.fromJson(Map<String, dynamic> json) => VenueReview(
        id: (json['id'] ?? json['reviewId'] ?? '').toString(),
        venueId: (json['venueId'] ?? '').toString(),
        userName: (json['userName'] ?? json['user']?['name'] ?? 'REKI user')
            .toString(),
        userAvatarUrl:
            (json['userAvatarUrl'] ?? json['user']?['avatar'])?.toString(),
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        text: (json['text'] ?? json['comment'] ?? '').toString(),
        vibeAccurate: json['vibeAccurate'] == true,
        createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
            DateTime.now(),
        isMine: json['isMine'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'venueId': venueId,
        'userName': userName,
        'userAvatarUrl': userAvatarUrl,
        'rating': rating,
        'text': text,
        'vibeAccurate': vibeAccurate,
        'createdAt': createdAt.toIso8601String(),
        'isMine': isMine,
      };
}

class VenueReviewSummary {
  final double averageRating;
  final int totalReviews;
  final double vibeAccuracyPercentage;

  const VenueReviewSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.vibeAccuracyPercentage,
  });

  factory VenueReviewSummary.fromJson(Map<String, dynamic> json) =>
      VenueReviewSummary(
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
        totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
        vibeAccuracyPercentage:
            (json['vibeAccuracyPercentage'] as num?)?.toDouble() ?? 0,
      );
}

class VenueReviewFeed {
  final List<VenueReview> reviews;
  final VenueReviewSummary summary;

  const VenueReviewFeed({required this.reviews, required this.summary});

  factory VenueReviewFeed.fromReviews(List<VenueReview> reviews) {
    final average = reviews.isEmpty
        ? 0.0
        : reviews.fold<int>(0, (sum, item) => sum + item.rating) /
            reviews.length;
    final accurate = reviews.where((item) => item.vibeAccurate).length;
    return VenueReviewFeed(
      reviews: reviews,
      summary: VenueReviewSummary(
        averageRating: average,
        totalReviews: reviews.length,
        vibeAccuracyPercentage:
            reviews.isEmpty ? 0 : accurate / reviews.length * 100,
      ),
    );
  }
}

class VenueCheckIn {
  final String id;
  final String venueId;
  final String venueName;
  final DateTime checkedInAt;
  final int pointsAwarded;

  const VenueCheckIn({
    required this.id,
    required this.venueId,
    required this.venueName,
    required this.checkedInAt,
    this.pointsAwarded = 0,
  });

  factory VenueCheckIn.fromJson(Map<String, dynamic> json) => VenueCheckIn(
        id: (json['id'] ?? json['checkInId'] ?? '').toString(),
        venueId: (json['venueId'] ?? json['venue']?['id'] ?? '').toString(),
        venueName:
            (json['venueName'] ?? json['venue']?['name'] ?? 'Venue').toString(),
        checkedInAt: DateTime.tryParse(
                (json['checkedInAt'] ?? json['createdAt'] ?? '').toString()) ??
            DateTime.now(),
        pointsAwarded: (json['pointsAwarded'] as num?)?.toInt() ?? 0,
      );
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int progress;
  final int target;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    required this.target,
    this.unlockedAt,
  });

  bool get isUnlocked => progress >= target;
  double get fraction => target == 0 ? 0 : (progress / target).clamp(0, 1);

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? 'Achievement').toString(),
        description: (json['description'] ?? '').toString(),
        icon: (json['icon'] ?? 'trophy').toString(),
        progress: (json['progress'] as num?)?.toInt() ?? 0,
        target: (json['target'] as num?)?.toInt() ?? 1,
        unlockedAt: DateTime.tryParse((json['unlockedAt'] ?? '').toString()),
      );
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final int points;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.points,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        rank: (json['rank'] as num?)?.toInt() ?? 0,
        name: (json['name'] ?? json['user']?['name'] ?? 'REKI user').toString(),
        points: (json['points'] as num?)?.toInt() ?? 0,
        isCurrentUser: json['isCurrentUser'] == true,
      );
}
