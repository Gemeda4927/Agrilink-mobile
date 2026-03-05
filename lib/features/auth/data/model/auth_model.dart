class AuthUser {
  final String id;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String? firebaseUid;
  final DateTime createdAt;

  AuthUser({
    required this.id,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.firebaseUid,
    required this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? 'active',
      firebaseUid: json['firebaseUid'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'role': role,
      'status': status,
      'firebaseUid': firebaseUid,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class AuthResponse {
  final AuthUser user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: AuthUser.fromJson(json['user'] ?? {}),
      token: json['token'] ?? json['accessToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
    };
  }
}