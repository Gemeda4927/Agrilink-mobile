import 'package:agrilink/features/role_request/data/models/role_request_model.dart';
import 'package:agrilink/features/role_request/domain/usecases/create_role_request_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'role_request_event.dart';
import 'role_request_state.dart';

class RoleRequestBloc extends Bloc<RoleRequestEvent, RoleRequestState> {
  final RoleRequestUseCases useCases;

  RoleRequestBloc(this.useCases) : super(RoleRequestInitial()) {
    // Create a new role request (Become Agent)
    on<CreateRoleRequestEvent>((event, emit) async {
      emit(RoleRequestLoading());
      try {
        await useCases.createRoleRequest();

        final requests = await useCases.getRoleRequests();

        if (requests.isNotEmpty) {
          final latestRequest = requests.last;
          emit(RoleRequestSuccess(latestRequest.status));
        } else {
          emit(RoleRequestError('No request found'));
        }
      } catch (e) {
        emit(RoleRequestError(e.toString()));
      }
    });

    // Fetch all role requests
    on<GetRoleRequestsEvent>((event, emit) async {
      emit(RoleRequestLoading());
      try {
        final requests = await useCases.getRoleRequests();
        emit(RoleRequestListLoaded(requests.cast<RoleRequestModel>()));
      } catch (e) {
        emit(RoleRequestError(e.toString()));
      }
    });
  }
}
