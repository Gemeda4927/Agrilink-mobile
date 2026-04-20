abstract class RoleRequestEvent {}

class CreateRoleRequestEvent extends RoleRequestEvent {
  final String kebeleId;
  final bool experienceInAgriculture;
  final String currentRole;
  final String educationLevel;
  final bool digitalSkills;
  final bool governmentAssigned;
  final List<String>? filePaths;

  CreateRoleRequestEvent({
    required this.kebeleId,
    required this.experienceInAgriculture,
    required this.currentRole,
    required this.educationLevel,
    required this.digitalSkills,
    required this.governmentAssigned,
    this.filePaths,
  });
}

class GetMyRoleRequestsEvent extends RoleRequestEvent {}