import 'package:agrilink/features/role_request/domain/usecases/create_role_request_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'role_request_event.dart';
import 'role_request_state.dart';

class RoleRequestBloc extends Bloc<RoleRequestEvent, RoleRequestState> {
  final RoleRequestUseCases useCases;

  RoleRequestBloc({required this.useCases}) : super(RoleRequestInitial()) {
    on<CreateRoleRequestEvent>(_onCreateRoleRequest);
    on<ClearRoleRequestErrorEvent>(_onClearError);
  }

  Future<void> _onCreateRoleRequest(
    CreateRoleRequestEvent event,
    Emitter<RoleRequestState> emit,
  ) async {
    emit(RoleRequestCreating());

    try {
      final roleRequest = await useCases.createRoleRequest(
        kebeleId: event.kebeleId,
        experienceInAgriculture: event.experienceInAgriculture,
        requestedRole: event.requestedRole,
        currentRole: event.currentRole,
        educationLevel: event.educationLevel,
        digitalSkills: event.digitalSkills,
        governmentAssigned: event.governmentAssigned,
        filePaths: event.filePaths,
      );

      emit(
        RoleRequestSuccess(
          roleRequest: roleRequest,
          message: 'Role request submitted successfully',
        ),
      );
    } catch (e) {
      emit(RoleRequestError(_getErrorMessage(e)));
    }
  }

  void _onClearError(
    ClearRoleRequestErrorEvent event,
    Emitter<RoleRequestState> emit,
  ) {
    if (state is RoleRequestError) {
      emit(RoleRequestInitial());
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('network') || errorStr.contains('socket')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorStr.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorStr.contains('401') || errorStr.contains('unauthorized')) {
      return 'Session expired. Please login again.';
    } else if (errorStr.contains('403') || errorStr.contains('forbidden')) {
      return 'You do not have permission to perform this action.';
    } else if (errorStr.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (errorStr.contains('already') || errorStr.contains('duplicate')) {
      return 'You have already submitted a role request. Please wait for admin approval.';
    }

    return error.toString().replaceAll('Exception:', '').trim();
  }
}