import '../../domain/entities/role_request.dart';

class RoleRequestModel {
  final String id;
  final String userId;
  final String requestedRole;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoleRequestModel({
    required this.id,
    required this.userId,
    required this.requestedRole,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoleRequestModel.fromJson(Map<String, dynamic> json) {
    return RoleRequestModel(
      id: json['id'],
      userId: json['userId'],
      requestedRole: json['requestedRole'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  RoleRequest toEntity() {
    return RoleRequest(
      id: id,
      userId: userId,
      requestedRole: requestedRole,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}