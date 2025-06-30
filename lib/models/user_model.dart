class User {
  final int? id;
  final String username;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  User({
    this.id,
    required this.username,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, isActive: $isActive}';
  }
}