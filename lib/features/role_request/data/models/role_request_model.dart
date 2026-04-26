import '../../domain/entities/role_request.dart';

class RoleRequestModel {
  final String id;
  final String userId;
  final String kebeleId;
  final bool experienceInAgriculture;
  final String requestedRole;
  final String currentRole;
  final String educationLevel;
  final bool digitalSkills;
  final bool governmentAssigned;
  final List<String>? files;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoleRequestModel({
    required this.id,
    required this.userId,
    required this.kebeleId,
    required this.experienceInAgriculture,
    required this.requestedRole,
    required this.currentRole,
    required this.educationLevel,
    required this.digitalSkills,
    required this.governmentAssigned,
    this.files,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoleRequestModel.fromJson(Map<String, dynamic> json) {
    return RoleRequestModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      kebeleId: json['kebeleId']?.toString() ?? '',
      experienceInAgriculture: json['experienceInAgriculture'] ?? false,
      requestedRole: json['requestedRole']?.toString() ?? 'AGENT',
      currentRole: json['currentRole']?.toString() ?? 'DA_OFFICER',
      educationLevel: json['educationLevel']?.toString() ?? 'NONE',
      digitalSkills: json['digitalSkills'] ?? false,
      governmentAssigned: json['governmentAssigned'] ?? false,
      files: json['files'] != null
          ? List<String>.from(json['files'].map((e) => e.toString()))
          : null,
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'kebeleId': kebeleId,
      'experienceInAgriculture': experienceInAgriculture,
      'requestedRole': requestedRole,
      'currentRole': currentRole,
      'educationLevel': educationLevel,
      'digitalSkills': digitalSkills,
      'governmentAssigned': governmentAssigned,
      if (files != null && files!.isNotEmpty) 'files': files,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForRequest() {
    return {
      'kebeleId': kebeleId,
      'experienceInAgriculture': experienceInAgriculture,
      'requestedRole': requestedRole,
      'currentRole': currentRole,
      'educationLevel': educationLevel,
      'digitalSkills': digitalSkills,
      'governmentAssigned': governmentAssigned,
      if (files != null && files!.isNotEmpty) 'files': files,
    };
  }

  RoleRequest toEntity() {
    return RoleRequest(
      id: id,
      userId: userId,
      kebeleId: kebeleId,
      experienceInAgriculture: experienceInAgriculture,
      requestedRole: requestedRole,
      currentRole: currentRole,
      educationLevel: educationLevel,
      digitalSkills: digitalSkills,
      governmentAssigned: governmentAssigned,
      files: files,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory RoleRequestModel.empty() {
    return RoleRequestModel(
      id: '',
      userId: '',
      kebeleId: '',
      experienceInAgriculture: false,
      requestedRole: 'AGENT',
      currentRole: 'DA_OFFICER',
      educationLevel: 'NONE',
      digitalSkills: false,
      governmentAssigned: false,
      files: null,
      status: 'PENDING',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  RoleRequestModel copyWith({
    String? id,
    String? userId,
    String? kebeleId,
    bool? experienceInAgriculture,
    String? requestedRole,
    String? currentRole,
    String? educationLevel,
    bool? digitalSkills,
    bool? governmentAssigned,
    List<String>? files,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoleRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      kebeleId: kebeleId ?? this.kebeleId,
      experienceInAgriculture:
          experienceInAgriculture ?? this.experienceInAgriculture,
      requestedRole: requestedRole ?? this.requestedRole,
      currentRole: currentRole ?? this.currentRole,
      educationLevel: educationLevel ?? this.educationLevel,
      digitalSkills: digitalSkills ?? this.digitalSkills,
      governmentAssigned: governmentAssigned ?? this.governmentAssigned,
      files: files ?? this.files,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
