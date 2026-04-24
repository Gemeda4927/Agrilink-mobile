import 'package:agrilink/features/profile/data/model/ProfileModel.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final GetProfileModel profile;
  ProfileLoaded(this.profile);
}

class ProfileNotFound extends ProfileState {
  final String message;
  ProfileNotFound([this.message = 'No profile found for this user']);
}

class ProfileCreated extends ProfileState {
  final CreateProfileModel profile;
  ProfileCreated(this.profile);
}

class ProfileUpdated extends ProfileState {
  final UpdateProfileModel profile;
  ProfileUpdated(this.profile);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}