import '../../domain/entities/role_request.dart';
import '../repositories/role_request_repository.dart';

class RoleRequestUseCases {
  final RoleRequestRepository repository;

  RoleRequestUseCases(this.repository);

  Future<void> createRoleRequest() async {
    return await repository.createRoleRequest();
  }

  /// Get role requests
  Future<List<RoleRequest>> getRoleRequests() async {
    return await repository.getRoleRequests();
  }
}