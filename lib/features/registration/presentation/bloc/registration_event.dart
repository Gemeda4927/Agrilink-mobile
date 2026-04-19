abstract class RegistrationEvent {}

class LoadRegions extends RegistrationEvent {}

class LoadZones extends RegistrationEvent {
  final String regionId;
  LoadZones(this.regionId);
}

class LoadWoredas extends RegistrationEvent {
  final String zoneId;
  LoadWoredas(this.zoneId);
}

class LoadKebeles extends RegistrationEvent {
  final String woredaId;
  LoadKebeles(this.woredaId);
}

class RegisterUser extends RegistrationEvent {
  final Map<String, dynamic> data;
  RegisterUser(this.data);
}

// Create Farmer Event
class CreateFarmer extends RegistrationEvent {
  final String email;
  final String password;
  final String confirmPassword;
  final String phone;
  final String role;

  CreateFarmer({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phone,
    this.role = "BUYER",
  });
}