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

      // ✅ Since API returns {success, message}, create a RoleRequest entity
      return RoleRequest(
        id: '', // ID will be assigned by server
        userId: '', // User ID from auth
        kebeleId: kebeleId,
        experienceInAgriculture: experienceInAgriculture,
        requestedRole: requestedRole,
        currentRole: currentRole,
        educationLevel: educationLevel,
        digitalSkills: digitalSkills,
        governmentAssigned: governmentAssigned,
        files: filePaths,
        status: 'PENDING', // Default status for new requests
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
      // If you have an endpoint to fetch request status
      // final response = await service.getRoleRequestStatus(userId);
      // return response.toEntity();

      // For now, return from local storage
      final hasSubmitted = service.hasSubmittedRequest();
      final status = service.getRequestStatus();
      final requestDate = service.getRequestDate();

      if (!hasSubmitted) {
        throw Exception('No role request found for this user');
      }

      return RoleRequest(
        id: '',
        userId: userId,
        kebeleId: '',
        experienceInAgriculture: false,
        requestedRole: '',
        currentRole: '',
        educationLevel: '',
        digitalSkills: false,
        governmentAssigned: false,
        status: status,
        createdAt: requestDate != null
            ? DateTime.parse(requestDate)
            : DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get role request status: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasPendingRequest(String userId) async {
    try {
      final hasSubmitted = service.hasSubmittedRequest();
      final status = service.getRequestStatus();

      return hasSubmitted && status == 'PENDING';
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearRequestStatus() async {
    try {
      await service.clearRequestStatus();
    } catch (e) {
      throw Exception('Failed to clear request status: ${e.toString()}');
    }
  }
}
