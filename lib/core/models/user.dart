class User {
  final String id;
  final String email;
  final String name;
  final UserType type;
  final UserRole role;
  final List<String> preferences;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.type,
    required this.role,
    required this.preferences,
    this.isActive = true,
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
    final role = UserRole.values.firstWhere(
      (r) => r.name.toUpperCase() == roleStr,
      orElse: () => UserRole.USER,
    );
    
    List<String> preferencesList = [];
    if (json['preferences'] != null) {
      if (json['preferences'] is Map) {
        // Preferences is an object, extract relevant fields
        final prefs = json['preferences'] as Map<String, dynamic>;
        if (prefs['preferredCategories'] != null) {
          preferencesList.addAll(List<String>.from(prefs['preferredCategories']));
        }
      } else if (json['preferences'] is List) {
        preferencesList = List<String>.from(json['preferences']);
      }
    }
    
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? json['email'] ?? '',
      type: role == UserRole.BUSINESS ? UserType.business : UserType.customer,
      role: role,
      preferences: preferencesList,
      isActive: json['isActive'] ?? true,
    );
  }
}

enum UserType { customer, business }
enum UserRole { USER, BUSINESS, ADMIN }