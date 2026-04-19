abstract class RegistrationState {}

class RegistrationInitial extends RegistrationState {}

class RegistrationLoading extends RegistrationState {}

class RegionsLoaded extends RegistrationState {
  final List regions;
  RegionsLoaded(this.regions);
}

class ZonesLoaded extends RegistrationState {
  final List zones;
  ZonesLoaded(this.zones);
}

class WoredasLoaded extends RegistrationState {
  final List woredas;
  WoredasLoaded(this.woredas);
}

class KebelesLoaded extends RegistrationState {
  final List kebeles;
  KebelesLoaded(this.kebeles);
}

class RegistrationSuccess extends RegistrationState {}

class CreateFarmerSuccess extends RegistrationState {
  final String message;
  CreateFarmerSuccess({required this.message});
}

class RegistrationError extends RegistrationState {
  final String message;
  RegistrationError(this.message);
}