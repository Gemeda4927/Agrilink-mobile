import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/role_request_model.dart';

class RoleRequestService {
  final DioClient client;

  RoleRequestService(this.client);

  /// Create Role Request (Become AGENT)
  Future<void> createRoleRequest() async {
    await client.post(
      ApiConstants.roleRequest,
      data: {},
    );
  }

  /// Get All Role Requests
  Future<List<RoleRequestModel>> getRoleRequests() async {
    final Response response = await client.get(
      ApiConstants.roleRequest,
    );

    final List data = response.data;

    return data
        .map((json) => RoleRequestModel.fromJson(json))
        .toList();
  }
}