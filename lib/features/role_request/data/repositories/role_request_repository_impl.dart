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
    try {
      final result = await service.createRoleRequest(
        kebeleId: kebeleId,
        experienceInAgriculture: experienceInAgriculture,
        requestedRole: requestedRole,
        currentRole: currentRole,
        educationLevel: educationLevel,
        digitalSkills: digitalSkills,
        governmentAssigned: governmentAssigned,
        filePaths: filePaths,
      );

      return RoleRequest(
        id: result['data']?['id']?.toString() ?? '',
        userId: result['data']?['userId']?.toString() ?? '',
        kebeleId: kebeleId,
        experienceInAgriculture: experienceInAgriculture,
        requestedRole: requestedRole,
        currentRole: currentRole,
        educationLevel: educationLevel,
        digitalSkills: digitalSkills,
        governmentAssigned: governmentAssigned,
        files: filePaths,
        status: result['data']?['status'] ?? 'PENDING',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to create role request: ${e.toString()}');
    }
  }

  @override
  Future<RoleRequest> getRoleRequestStatus(String userId) async {
    try {
      // ❗ You MUST get this from backend now
      throw UnimplementedError(
        'getRoleRequestStatus requires API endpoint implementation',
      );
    } catch (e) {
      throw Exception('Failed to get role request status: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasPendingRequest(String userId) async {
    try {
      // ❗ Should come from backend
      final request = await getRoleRequestStatus(userId);
      return request.status == 'PENDING';
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearRequestStatus() async {
    // ❌ Removed (no local storage anymore)
    return;
  }
}