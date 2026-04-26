import 'package:flutter/material.dart';

class RoleRequest {
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

  // ✅ Remove 'const' keyword
  RoleRequest({
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

  // ✅ Create empty instance (without const)
  factory RoleRequest.empty() {
    return RoleRequest(
      id: '',
      userId: '',
      kebeleId: '',
      experienceInAgriculture: false,
      requestedRole: '',
      currentRole: '',
      educationLevel: '',
      digitalSkills: false,
      governmentAssigned: false,
      files: null,
      status: 'PENDING',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // ✅ Create from JSON
  factory RoleRequest.fromJson(Map<String, dynamic> json) {
    return RoleRequest(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      kebeleId: json['kebeleId']?.toString() ?? '',
      experienceInAgriculture: json['experienceInAgriculture'] ?? false,
      requestedRole: json['requestedRole']?.toString() ?? '',
      currentRole: json['currentRole']?.toString() ?? '',
      educationLevel: json['educationLevel']?.toString() ?? '',
      digitalSkills: json['digitalSkills'] ?? false,
      governmentAssigned: json['governmentAssigned'] ?? false,
      files: json['files'] != null
          ? List<String>.from(json['files'].map((e) => e.toString()))
          : null,
      status: json['status']?.toString()?.toUpperCase() ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  // ✅ Convert to JSON
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

  // ✅ Create a copy with updated fields
  RoleRequest copyWith({
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
    return RoleRequest(
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

  // ✅ Helper getters for status
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isApproved => status.toUpperCase() == 'APPROVED';
  bool get isRejected => status.toUpperCase() == 'REJECTED';
  bool get hasFiles => files != null && files!.isNotEmpty;
  bool get isComplete =>
      id.isNotEmpty && userId.isNotEmpty && kebeleId.isNotEmpty;

  // ✅ Display-friendly status with icon
  String get statusDisplay {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return '⏳ Pending Review';
      case 'APPROVED':
        return '✅ Approved';
      case 'REJECTED':
        return '❌ Rejected';
      default:
        return status;
    }
  }

  // ✅ Status color for UI
  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return const Color(0xFFFF9800); // Orange
      case 'APPROVED':
        return const Color(0xFF4CAF50); // Green
      case 'REJECTED':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  // ✅ Status icon for UI
  IconData get statusIcon {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'APPROVED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  // ✅ Education level display
  String get educationLevelDisplay {
    switch (educationLevel.toUpperCase()) {
      case 'NONE':
        return 'No Formal Education';
      case 'PRIMARY':
        return 'Primary School';
      case 'SECONDARY':
        return 'Secondary School';
      case 'DIPLOMA':
        return 'Diploma';
      case 'DEGREE':
        return 'Bachelor\'s Degree';
      case 'MASTERS':
        return 'Master\'s Degree';
      case 'PHD':
        return 'PhD';
      default:
        return educationLevel;
    }
  }

  // ✅ Role display names
  String get requestedRoleDisplay {
    switch (requestedRole.toUpperCase()) {
      case 'DATA_CONTRIBUTOR':
        return 'Data Contributor';
      case 'AGENT':
        return 'Agent';
      case 'ADMIN':
        return 'Admin';
      case 'FARMER':
        return 'Farmer';
      case 'BUYER':
        return 'Buyer';
      default:
        return requestedRole;
    }
  }

  String get currentRoleDisplay {
    switch (currentRole.toUpperCase()) {
      case 'DATA_CONTRIBUTOR':
        return 'Data Contributor';
      case 'AGENT':
        return 'Agent';
      case 'ADMIN':
        return 'Admin';
      case 'FARMER':
        return 'Farmer';
      case 'BUYER':
        return 'Buyer';
      default:
        return currentRole;
    }
  }

  // ✅ Format dates for display
  String get formattedCreatedAt {
    return _formatDate(createdAt);
  }

  String get formattedUpdatedAt {
    return _formatDate(updatedAt);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ✅ Time ago for display
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 7) return '${diff.inDays ~/ 7} weeks ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }

  @override
  String toString() {
    return 'RoleRequest(id: $id, userId: $userId, kebeleId: $kebeleId, '
        'requestedRole: $requestedRole, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoleRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
