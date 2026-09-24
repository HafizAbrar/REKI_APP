import 'dart:convert';

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

  factory User.fromJson(Map<String, dynamic> json, {String? accessToken}) {
    final normalizedRole = resolveRoleName(json, accessToken: accessToken);
    final role = UserRole.values.firstWhere(
      (r) => r.name.toUpperCase() == normalizedRole,
      orElse: () => UserRole.USER,
    );

    List<String> preferencesList = [];
    if (json['preferences'] != null) {
      if (json['preferences'] is Map) {
        final prefs = json['preferences'] as Map<String, dynamic>;
        if (prefs['preferredCategories'] != null) {
          preferencesList
              .addAll(List<String>.from(prefs['preferredCategories']));
        }
      } else if (json['preferences'] is List) {
        preferencesList = List<String>.from(json['preferences']);
      }
    }

    // Extract venueId/venueName from venues array or direct fields
    String? venueId =
        json['venue']?['id']?.toString() ?? json['venueId']?.toString();
    String? venueName =
        json['venue']?['name']?.toString() ?? json['venueName']?.toString();
    if (venueId == null &&
        json['venues'] is List &&
        (json['venues'] as List).isNotEmpty) {
      final firstVenue = (json['venues'] as List).first as Map<String, dynamic>;
      venueId = firstVenue['id']?.toString();
      venueName = firstVenue['name']?.toString();
    }

    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['fullName'] ?? json['name'] ?? json['email'] ?? '',
      type: (role == UserRole.BUSINESS || role == UserRole.WORKER)
          ? UserType.business
          : UserType.customer,
      role: role,
      preferences: preferencesList,
      isActive: json['isActive'] ?? true,
      venueId: venueId,
      venueName: venueName,
      profilePicture: json['profilePicture']?.toString() ??
          json['picture']?.toString() ??
          json['photoURL']?.toString() ??
          json['avatar']?.toString() ??
          json['photo']?.toString() ??
          json['imageUrl']?.toString() ??
          json['image']?.toString(),
    );
  }

  static String resolveRoleName(Map<String, dynamic> json,
      {String? accessToken}) {
    final values = <String>[];
    const roleKeys = {
      'role',
      'userrole',
      'accountrole',
      'businessrole',
      'staffrole',
      'usertype',
      'accounttype',
      'type',
    };
    void collect(dynamic value, [int depth = 0]) {
      if (depth > 4 || value is! Map) return;
      for (final entry in value.entries) {
        final key = entry.key.toString().toLowerCase().replaceAll('_', '');
        if (roleKeys.contains(key) && entry.value != null) {
          final item = entry.value;
          values.addAll(item is List
              ? item.map((element) => element.toString())
              : [item.toString()]);
        }
        if (entry.value is Map) collect(entry.value, depth + 1);
      }
    }

    collect(json);
    final claims = _jwtClaims(accessToken);
    if (claims != null) collect(claims);
    final roles = values
        .map((value) => value.trim().toUpperCase().split('.').last)
        .toSet();
    if (roles.any(const {'WORKER', 'STAFF', 'VENUE_STAFF'}.contains)) {
      return 'WORKER';
    }
    if (roles.contains('ADMIN')) return 'ADMIN';
    if (roles.any(const {'BUSINESS', 'OWNER', 'MANAGER'}.contains)) {
      return 'BUSINESS';
    }
    return 'USER';
  }

  static Map<String, dynamic>? _jwtClaims(String? token) {
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final value = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      return value is Map<String, dynamic> ? value : null;
    } catch (_) {
      return null;
    }
  }
}

enum UserType { customer, business }

// Preserve existing role identifiers used throughout the API integration.
// ignore: constant_identifier_names
enum UserRole { USER, BUSINESS, WORKER, ADMIN }

extension UserGuest on User {
  bool get isGuest =>
      email == 'guest@reki.app' ||
      id.startsWith('guest_') ||
      (email.isEmpty && name == 'Guest');
}
