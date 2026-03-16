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
    /// ================= LOAD PROFILE =================
    on<LoadProfile>((event, emit) async {
      print('📱 [ProfileBloc] ===== LOAD PROFILE EVENT =====');
      print('📱 [ProfileBloc] Loading profile for userId: ${event.userId}');

      emit(ProfileLoading());
      try {
        final profile = await getUseCase.execute(event.userId);

        // Check if profile exists
        if (profile.profile == null) {
          print('📱 [ProfileBloc] No profile found for user');
          emit(ProfileNotFound()); // Emit ProfileNotFound state
        } else {
          print('✅ [ProfileBloc] Profile loaded successfully');
          emit(ProfileLoaded(profile));
        }
      } catch (e, stackTrace) {
        print('❌ [ProfileBloc] Failed to load profile: $e');
        print('❌ [ProfileBloc] Stack trace: $stackTrace');
        emit(ProfileError(e.toString()));
      }
      print('📱 [ProfileBloc] ===== LOAD PROFILE EVENT ENDED =====');
    });

    /// ================= CREATE PROFILE =================
    on<CreateProfile>((event, emit) async {
      print('📱 [ProfileBloc] ===== CREATE PROFILE EVENT =====');
      print('📱 [ProfileBloc] Creating profile with:');
      print('📱 [ProfileBloc]   - fullName: ${event.fullName}');
      print('📱 [ProfileBloc]   - kebeleld: ${event.kebeleld}');
      print(
        '📱 [ProfileBloc]   - image: ${event.image != null ? event.image!.path : 'No image'}',
      );

      emit(ProfileLoading());
      try {
        final profile = await createUseCase.execute(
          CreateProfileParams(
            fullName: event.fullName,
            kebeleld: event.kebeleld,
            image: event.image,
          ),
        );
        print('✅ [ProfileBloc] Profile created successfully');
        emit(ProfileCreated(profile));
      } catch (e, stackTrace) {
        print('❌ [ProfileBloc] Failed to create profile: $e');
        print('❌ [ProfileBloc] Stack trace: $stackTrace');
        emit(ProfileError(e.toString()));
      }
      print('📱 [ProfileBloc] ===== CREATE PROFILE EVENT ENDED =====');
    });

    /// ================= UPDATE PROFILE =================
    on<UpdateProfile>((event, emit) async {
      print('📱 [ProfileBloc] ===== UPDATE PROFILE EVENT =====');
      print('📱 [ProfileBloc] Updating profile with:');
      print('📱 [ProfileBloc]   - fullName: ${event.fullName}');
      print('📱 [ProfileBloc]   - kebeleld: ${event.kebeleld}');
      print(
        '📱 [ProfileBloc]   - image: ${event.image != null ? event.image!.path : 'No image'}',
      );

      emit(ProfileLoading());
      try {
        final profile = await updateUseCase.execute(
          UpdateProfileParams(
            fullName: event.fullName,
            kebeleld: event.kebeleld,
            image: event.image,
          ),
        );
        print('✅ [ProfileBloc] Profile updated successfully');
        emit(ProfileUpdated(profile));
      } catch (e, stackTrace) {
        print('❌ [ProfileBloc] Failed to update profile: $e');
        print('❌ [ProfileBloc] Stack trace: $stackTrace');
        emit(ProfileError(e.toString()));
      }
      print('📱 [ProfileBloc] ===== UPDATE PROFILE EVENT ENDED =====');
    });
  }
}
