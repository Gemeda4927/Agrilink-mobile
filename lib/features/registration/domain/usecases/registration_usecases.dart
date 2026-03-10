import 'package:agrilink/features/registration/data/models/user_model.dart';

import '../repositories/registration_repository.dart';

class RegistrationUseCases {
  final RegistrationRepository repository;

  RegistrationUseCases(this.repository);

  /// Register user
  Future<UserModel> registerUser(Map<String, dynamic> data) {
    return repository.registerUser(data);
  }

  /// Get all regions
  Future<List<dynamic>> getRegions() {
    return repository.getRegions();
  }

  /// Get zones by region
  Future<List<dynamic>> getZones(String regionId) {
    return repository.getZones(regionId);
  }

  /// Get woredas by zone
  Future<List<dynamic>> getWoredas(String zoneId) {
    return repository.getWoredas(zoneId);
  }

  /// Get kebeles by woreda
  Future<List<dynamic>> getKebeles(String woredaId) {
    return repository.getKebeles(woredaId);
  }
}
