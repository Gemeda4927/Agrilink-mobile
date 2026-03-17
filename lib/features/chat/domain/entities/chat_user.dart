class User {
  final String id;
  final String? phone;
  final String email;
  final String? fullName;

  User({
    required this.id,
    this.phone,
    required this.email,
    this.fullName,
  });
}