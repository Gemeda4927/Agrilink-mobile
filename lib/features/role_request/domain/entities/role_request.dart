class RoleRequest {
  final String id;
  final String userId;
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

  const RoleRequest({
    required this.id,
    required this.userId,
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
}