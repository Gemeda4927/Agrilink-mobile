import 'package:agrilink/features/role_request/data/service/role_request_service.dart';
import '../../domain/entities/role_request.dart';
import '../../domain/repositories/role_request_repository.dart';

class RoleRequestRepositoryImpl implements RoleRequestRepository {
  final RoleRequestService service;

  RoleRequestRepositoryImpl(this.service);

  @override
  Future<RoleRequest> createRoleRequest({
    required String kebeleId,
    required bool experienceInAgriculture,
    required String requestedRole,
    required String currentRole,
    required String educationLevel,
    required bool digitalSkills,
    required bool governmentAssigned,
    List<String>? filePaths,
  }) async {
    final model = await service.createRoleRequest(
      kebeleId: kebeleId,
      experienceInAgriculture: experienceInAgriculture,
      requestedRole: requestedRole,
      currentRole: currentRole,
      educationLevel: educationLevel,
      digitalSkills: digitalSkills,
      governmentAssigned: governmentAssigned,
      filePaths: filePaths,
    );
    return model.toEntity();
  }
}