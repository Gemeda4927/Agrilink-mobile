import 'package:agrilink/features/role_request/domain/entities/role_request.dart';

abstract class RoleRequestRepository {
  Future<List<RoleRequest>> getRoleRequests();
  Future<void> createRoleRequest();
}
