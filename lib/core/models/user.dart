class User {
  final String id;
  final String email;
  final String name;
  final UserType type;
  final List<String> preferences;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.type,
    required this.preferences,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'type': type.toString(),
    'preferences': preferences,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id']?.toString() ?? '',
    email: json['email'] ?? '',
    name: json['name'] ?? '',
    type: json['type'] is String 
        ? (json['type'] == 'business' ? UserType.business : UserType.customer)
        : UserType.customer,
    preferences: json['preferences'] != null 
        ? List<String>.from(json['preferences']) 
        : [],
  );
}

enum UserType { customer, business }