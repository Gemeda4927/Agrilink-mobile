// role_request_state.dart
import 'package:agrilink/features/role_request/data/models/role_request_model.dart';

abstract class RoleRequestState {}

class RoleRequestInitial extends RoleRequestState {}

class RoleRequestLoading extends RoleRequestState {}

class RoleRequestSuccess extends RoleRequestState {
  final String status;
  RoleRequestSuccess(this.status);
}

class RoleRequestListLoaded extends RoleRequestState {
  final List<RoleRequestModel> requests;
  RoleRequestListLoaded(this.requests);
}

class RoleRequestError extends RoleRequestState {
  final String message;
  RoleRequestError(this.message);
}
