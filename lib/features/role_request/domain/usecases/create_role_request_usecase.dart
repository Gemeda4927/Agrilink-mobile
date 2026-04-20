import '../../domain/entities/role_request.dart';
import '../repositories/role_request_repository.dart';

class RoleRequestUseCases {
  final RoleRequestRepository repository;

  RoleRequestUseCases(this.repository);

  Future<RoleRequest> createRoleRequest({
    required String kebeleId,
    required bool experienceInAgriculture,
    required String currentRole,
    required String educationLevel,
    required bool digitalSkills,
    required bool governmentAssigned,
    List<String>? filePaths,
  }) async {
    return await repository.createRoleRequest(
      kebeleId: kebeleId,
      experienceInAgriculture: experienceInAgriculture,
      currentRole: currentRole,
      educationLevel: educationLevel,
      digitalSkills: digitalSkills,
      governmentAssigned: governmentAssigned,
      filePaths: filePaths,
    );
  }
}
