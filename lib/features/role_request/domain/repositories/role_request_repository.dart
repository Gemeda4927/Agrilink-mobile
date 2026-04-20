import '../entities/role_request.dart';

abstract class RoleRequestRepository {
  Future<RoleRequest> createRoleRequest({
    required String kebeleId,
    required bool experienceInAgriculture,
    required String currentRole,
    required String educationLevel,
    required bool digitalSkills,
    required bool governmentAssigned,
    List<String>? filePaths,
  });
}
