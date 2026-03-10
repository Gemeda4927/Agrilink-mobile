import 'package:agrilink/features/registration/data/models/user_model.dart';
import '../../domain/repositories/registration_repository.dart';
import '../services/registration_service.dart';

class RegistrationRepositoryImpl implements RegistrationRepository {
  final RegistrationService service;

  RegistrationRepositoryImpl(this.service);

  @override
  Future<UserModel> registerUser(Map<String, dynamic> data) async {
    final response = await service.registerUser(data);

    // response is already JSON
    return UserModel.fromJson(response);
  }

  @override
  Future<List<dynamic>> getRegions() async {
    final response = await service.getRegions();

    return response; // ❌ remove .data
  }

  @override
  Future<List<dynamic>> getZones(String regionId) async {
    final response = await service.getZones(regionId);

    return response; // ❌ remove .data
  }

  @override
  Future<List<dynamic>> getWoredas(String zoneId) async {
    final response = await service.getWoredas(zoneId);

    return response; // ❌ remove .data
  }

  @override
  Future<List<dynamic>> getKebeles(String woredaId) async {
    final response = await service.getKebeles(woredaId);

    return response; // ❌ remove .data
  }
}