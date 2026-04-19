import 'package:agrilink/features/registration/data/models/user_model.dart';

abstract class RegistrationRepository {
  Future<CreateFarmerResponse> createFarmer({
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
    String role = "BUYER",
  });

  Future<UserModel> registerUser(Map<String, dynamic> data);

  Future<List<dynamic>> getRegions();

  Future<List<dynamic>> getZones(String regionId);

  Future<List<dynamic>> getWoredas(String zoneId);

  Future<List<dynamic>> getKebeles(String woredaId);
}