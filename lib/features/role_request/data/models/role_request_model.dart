import '../../domain/entities/role_request.dart';

class RoleRequestModel {
  final String? id;
  final String? userId;
  final String kebeleId;
  final bool experienceInAgriculture;
  final String currentRole;
  final String educationLevel;
  final bool digitalSkills;
  final bool governmentAssigned;
  final List<String>? files;
  final String? requestedRole;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RoleRequestModel({
    this.id,
    this.userId,
    required this.kebeleId,
    required this.experienceInAgriculture,
    required this.currentRole,
    required this.educationLevel,
    required this.digitalSkills,
    required this.governmentAssigned,
    this.files,
    this.requestedRole,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleRequestModel.fromJson(Map<String, dynamic> json) {
    return RoleRequestModel(
      id: json['id'],
      userId: json['userId'],
      kebeleId: json['kebeleId'],
      experienceInAgriculture: json['experienceInAgriculture'],
      currentRole: json['currentRole'],
      educationLevel: json['educationLevel'],
      digitalSkills: json['digitalSkills'],
      governmentAssigned: json['governmentAssigned'],
      files: json['files'] != null ? List<String>.from(json['files']) : null,
      requestedRole: json['requestedRole'],
      status: json['status'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJsonForRequest() {
    return {
      'kebeleId': kebeleId,
      'experienceInAgriculture': experienceInAgriculture,
      'currentRole': currentRole,
      'educationLevel': educationLevel,
      'digitalSkills': digitalSkills,
      'governmentAssigned': governmentAssigned,
    };
  }

  RoleRequest toEntity() {
    return RoleRequest(
      id: id ?? '',
      userId: userId ?? '',
      kebeleId: kebeleId,
      experienceInAgriculture: experienceInAgriculture,
      currentRole: currentRole,
      educationLevel: educationLevel,
      digitalSkills: digitalSkills,
      governmentAssigned: governmentAssigned,
      files: files,
      requestedRole: requestedRole,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}