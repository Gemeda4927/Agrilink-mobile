import '../../domain/entities/role_request.dart';

abstract class RoleRequestState {}

class RoleRequestInitial extends RoleRequestState {}

class RoleRequestCreating extends RoleRequestState {}

class RoleRequestSuccess extends RoleRequestState {
  final RoleRequest? roleRequest;
  final String message;

  RoleRequestSuccess({
    this.roleRequest,
    required this.message,
  });
}

class RoleRequestError extends RoleRequestState {
  final String message;

  RoleRequestError(this.message);
}