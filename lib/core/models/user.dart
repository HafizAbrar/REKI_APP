class User {
  final String id;
  final String email;
  final String name;
  final UserType type;
  final UserRole role;
  final List<String> preferences;
  final bool isActive;
  final String? venueId;
  final String? venueName;
  final String? profilePicture;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.type,
    required this.role,
    required this.preferences,
    this.isActive = true,
    this.venueId,
    this.venueName,
    this.profilePicture,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'type': type.toString(),
    'role': role.toString(),
    'preferences': preferences,
    'isActive': isActive,
  };

  factory User.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role']?.toString().toUpperCase() ?? 'USER';
    // 'GUEST' role from API maps to UserRole.USER
    final normalizedRole = roleStr == 'GUEST' ? 'USER' : roleStr;
    final role = UserRole.values.firstWhere(
      (r) => r.name.toUpperCase() == normalizedRole,
      orElse: () => UserRole.USER,
    );
    
    List<String> preferencesList = [];
    if (json['preferences'] != null) {
      if (json['preferences'] is Map) {
        final prefs = json['preferences'] as Map<String, dynamic>;
        if (prefs['preferredCategories'] != null) {
          preferencesList.addAll(List<String>.from(prefs['preferredCategories']));
        }
      } else if (json['preferences'] is List) {
        preferencesList = List<String>.from(json['preferences']);
      }
    }

    // Extract venueId/venueName from venues array or direct fields
    String? venueId = json['venue']?['id']?.toString() ?? json['venueId']?.toString();
    String? venueName = json['venue']?['name']?.toString() ?? json['venueName']?.toString();
    if (venueId == null && json['venues'] is List && (json['venues'] as List).isNotEmpty) {
      final firstVenue = (json['venues'] as List).first as Map<String, dynamic>;
      venueId = firstVenue['id']?.toString();
      venueName = firstVenue['name']?.toString();
    }
    
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['fullName'] ?? json['name'] ?? json['email'] ?? '',
      type: role == UserRole.BUSINESS ? UserType.business : UserType.customer,
      role: role,
      preferences: preferencesList,
      isActive: json['isActive'] ?? true,
      venueId: venueId,
      venueName: venueName,
      profilePicture: json['profilePicture']?.toString() ?? json['picture']?.toString() ?? json['photoURL']?.toString() ?? json['avatar']?.toString() ?? json['photo']?.toString() ?? json['imageUrl']?.toString() ?? json['image']?.toString(),
    );
  }
}

enum UserType { customer, business }
enum UserRole { USER, BUSINESS, ADMIN }

extension UserGuest on User {
  bool get isGuest =>
      email == 'guest@reki.app' ||
      id.startsWith('guest_') ||
      (email.isEmpty && name == 'Guest');
}