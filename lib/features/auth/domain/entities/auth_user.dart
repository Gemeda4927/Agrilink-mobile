class AuthUserEntity {
  final String id;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String? firebaseUid;
  final DateTime createdAt;

  AuthUserEntity({
    required this.id,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.firebaseUid,
    required this.createdAt,
  });
}