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
    id: json['id'],
    email: json['email'],
    name: json['name'],
    type: UserType.values.firstWhere((e) => e.toString() == json['type']),
    preferences: List<String>.from(json['preferences']),
  );
}

enum UserType { customer, business }