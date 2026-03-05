import 'package:agrilink/features/auth/domain/entities/auth_user.dart';

class AuthResponseEntity {
  final AuthUserEntity user;
  final String token;

  AuthResponseEntity({required this.user, required this.token});
}
