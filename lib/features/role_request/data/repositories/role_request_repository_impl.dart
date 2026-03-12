import 'package:agrilink/features/role_request/data/service/role_request_service.dart';

import '../../domain/entities/role_request.dart';
import '../../domain/repositories/role_request_repository.dart';

class RoleRequestRepositoryImpl implements RoleRequestRepository {
  final RoleRequestService service;

  RoleRequestRepositoryImpl(this.service);

  @override
  Future<void> createRoleRequest() async {
    await service.createRoleRequest();
  }

  @override
  Future<List<RoleRequest>> getRoleRequests() async {
    final models = await service.getRoleRequests();
    return models.map((model) => model.toEntity()).toList();
  }
}
