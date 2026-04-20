import 'package:agrilink/features/role_request/domain/usecases/create_role_request_usecase.dart';
import 'package:agrilink/features/role_request/presentation/bloc/role_request_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'role_request_event.dart';

class RoleRequestBloc extends Bloc<RoleRequestEvent, RoleRequestState> {
  final RoleRequestUseCases useCases;

  RoleRequestBloc(this.useCases) : super(RoleRequestInitial()) {
    // Create a new role request (Become Agent/Farmer/DA_Officer)
    on<CreateRoleRequestEvent>((event, emit) async {
      emit(RoleRequestCreating());

      try {
        final roleRequest = await useCases.createRoleRequest(
          kebeleId: event.kebeleId,
          experienceInAgriculture: event.experienceInAgriculture,
          currentRole: event.currentRole,
          educationLevel: event.educationLevel,
          digitalSkills: event.digitalSkills,
          governmentAssigned: event.governmentAssigned,
          filePaths: event.filePaths,
        );

        emit(
          RoleRequestSuccess(
            roleRequest,
            message: 'Role request submitted successfully',
          ),
        );
      } catch (e) {
        // Handle duplicate request error
        if (_isDuplicateRequestError(e)) {
          emit(
            RoleRequestError(
              'You have already submitted a role request. Please wait for admin approval.',
            ),
          );
        } else {
          emit(RoleRequestError(_getErrorMessage(e)));
        }
      }
    });
  }

  /// Check if error indicates a duplicate request
  bool _isDuplicateRequestError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('400') ||
        errorStr.contains('already') ||
        errorStr.contains('exists') ||
        errorStr.contains('duplicate');
  }

  /// Extract user-friendly error messages
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorStr.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorStr.contains('401') || errorStr.contains('unauthorized')) {
      return 'Session expired. Please login again.';
    } else if (errorStr.contains('403') || errorStr.contains('forbidden')) {
      return 'You do not have permission to perform this action.';
    } else if (errorStr.contains('404')) {
      return 'Resource not found.';
    } else if (errorStr.contains('500')) {
      return 'Server error. Please try again later.';
    }

    // Return the original error message
    return error.toString().replaceAll('Exception:', '').trim();
  }
}
