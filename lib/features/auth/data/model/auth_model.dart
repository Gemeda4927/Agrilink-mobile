class AuthModel {
  final String id;
  final String phone;
  final String email;
  final String password;
  final Role role;
  final UserStatus status;
  final DateTime? lastLogin;
  final DateTime createdAt;

  AuthModel({
    required this.id,
    required this.phone,
    required this.email,
    required this.password,
    required this.role,
    required this.status,
    this.lastLogin,
    required this.createdAt,
  });

  // From JSON
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['id'],
      phone: json['phone'],
      email: json['email'],
      password: json['password'],
      role: Role.values.firstWhere((e) => e.name == json['role']),
      status: UserStatus.values.firstWhere((e) => e.name == json['status']),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'password': password,
      'role': role.name,
      'status': status.name,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

enum Role { FARMER, BUYER, AGENT, ADMIN }

enum UserStatus { ACTIVE, INACTIVE, PENDING }
