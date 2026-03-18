import 'package:agrilink/features/profile/data/model/ProfileModel.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

/// Profile loaded successfully with data
class ProfileLoaded extends ProfileState {
  final GetProfileModel profile;
  ProfileLoaded(this.profile);
}

class ProfileNotFound extends ProfileState {
  final String message;
  ProfileNotFound([this.message = 'No profile found for this user']);
}

/// Profile created successfully
class ProfileCreated extends ProfileState {
  final CreateProfileModel profile;
  ProfileCreated(this.profile);
}

/// Profile updated successfully
class ProfileUpdated extends ProfileState {
  final UpdateProfileModel profile;
  ProfileUpdated(this.profile);
}

/// Error occurred during any profile operation
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
