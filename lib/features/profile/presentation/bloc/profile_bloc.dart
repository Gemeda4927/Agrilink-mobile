import 'package:agrilink/features/profile/domain/usecases/profile_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final CreateProfileUseCase createUseCase;
  final UpdateProfileUseCase updateUseCase;
  final GetProfileUseCase getUseCase;

  ProfileBloc({
    required this.createUseCase,
    required this.updateUseCase,
    required this.getUseCase,
  }) : super(ProfileInitial()) {
    on<LoadProfile>((event, emit) async {
      print('📱 ===== LOAD PROFILE =====');

      emit(ProfileLoading());
      try {
        final profile = await getUseCase.execute(event.userId);

        if (profile.profile == null) {
          emit(ProfileNotFound());
        } else {
          emit(ProfileLoaded(profile));
        }
      } catch (e, stackTrace) {
        print('❌ Error: $e');
        print(stackTrace);
        emit(ProfileError(e.toString()));
      }
    });

    on<CreateProfile>((event, emit) async {
      print('📱 ===== CREATE PROFILE =====');

      emit(ProfileLoading());
      try {
        final profile = await createUseCase.execute(
          CreateProfileParams(
            fullName: event.fullName.trim(),
            kebeleId: event.kebeleId,
            image: event.image,
          ),
        );

        emit(ProfileCreated(profile));
      } catch (e, stackTrace) {
        print('❌ Error: $e');
        print(stackTrace);
        emit(ProfileError(e.toString()));
      }
    });

    on<UpdateProfile>((event, emit) async {
      print('📱 ===== UPDATE PROFILE =====');

      emit(ProfileLoading());
      try {
        final profile = await updateUseCase.execute(
          UpdateProfileParams(
            fullName: event.fullName.trim(),
            kebeleId: event.kebeleId,
            image: event.image,
          ),
        );

        emit(ProfileUpdated(profile));
      } catch (e, stackTrace) {
        print('❌ Error: $e');
        print(stackTrace);
        emit(ProfileError(e.toString()));
      }
    });
  }
}