import 'package:agrilink/features/chat/domain/entities/chat_user.dart';

class UserModel {
  final String id;
  final String? phone;
  final String email;
  final String? fullName;

  UserModel({required this.id, this.phone, required this.email, this.fullName});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['phone'],
      email: json['email'],
      fullName: json['profile'] != null ? json['profile']['fullName'] : null,
    );
  }

  User toEntity() {
    return User(id: id, phone: phone, email: email, fullName: fullName);
  }
}
