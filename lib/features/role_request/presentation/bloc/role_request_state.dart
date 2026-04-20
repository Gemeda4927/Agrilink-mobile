import '../../domain/entities/role_request.dart';

/// Base state for role requests
abstract class RoleRequestState {}

/// Initial state when bloc is first created
class RoleRequestInitial extends RoleRequestState {}

/// Loading state for both fetching and creating (backward compatibility)
class RoleRequestLoading extends RoleRequestState {}

/// Loading state when fetching role requests list
class RoleRequestFetching extends RoleRequestState {}

/// Loading state when creating a new role request
class RoleRequestCreating extends RoleRequestState {}

/// Success state after creating a role request
class RoleRequestSuccess extends RoleRequestState {
  final RoleRequest roleRequest;
  final String message;

  RoleRequestSuccess(
    this.roleRequest, {
    this.message = 'Request submitted successfully',
  });
}

/// State when role requests list is successfully loaded
class RoleRequestListLoaded extends RoleRequestState {
  final List<RoleRequest> requests;

  RoleRequestListLoaded(this.requests);
}

/// Error state with descriptive message
class RoleRequestError extends RoleRequestState {
  final String message;

  RoleRequestError(this.message);
}

/// State when request is being updated
class RoleRequestUpdating extends RoleRequestState {
  final String requestId;

  RoleRequestUpdating(this.requestId);
}

/// State when a specific request is loaded
class RoleRequestDetailLoaded extends RoleRequestState {
  final RoleRequest request;

  RoleRequestDetailLoaded(this.request);
}