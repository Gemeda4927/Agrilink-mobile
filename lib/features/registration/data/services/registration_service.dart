import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_constants.dart';

class RegistrationService {
  final DioClient dioClient;

  RegistrationService({required this.dioClient});

  /// ================= REGISTER USER =================
  Future<dynamic> registerUser(Map<String, dynamic> data) async {
    print("📤 REGISTER USER REQUEST");
    print("URL: ${ApiConstants.register}");
    print("DATA: $data");

    final response = await dioClient.post(ApiConstants.register, data: data);

    print("✅ REGISTER RESPONSE:");
    print(response.data);

    return response.data;
  }

  /// ================= GET REGIONS =================
  Future<dynamic> getRegions() async {
    print("📤 GET REGIONS REQUEST");
    print("URL: ${ApiConstants.regions}");

    final response = await dioClient.get(ApiConstants.regions);

    print("✅ REGIONS RESPONSE:");
    print(response.data);

    return response.data;
  }

  /// ================= GET ZONES BY REGION =================
  Future<dynamic> getZones(String regionId) async {
    final url = "${ApiConstants.zonesByRegion}/$regionId";

    print("📤 GET ZONES REQUEST");
    print("URL: $url");

    final response = await dioClient.get(url);

    print("✅ ZONES RESPONSE:");
    print(response.data);

    return response.data;
  }

  /// ================= GET WOREDAS BY ZONE =================
  Future<dynamic> getWoredas(String zoneId) async {
    final url = "${ApiConstants.woredasByZone}/$zoneId";

    print("📤 GET WOREDAS REQUEST");
    print("URL: $url");

    final response = await dioClient.get(url);

    print("✅ WOREDAS RESPONSE:");
    print(response.data);

    return response.data;
  }

  /// ================= GET KEBELES BY WOREDA =================
  Future<dynamic> getKebeles(String woredaId) async {
    final url = "${ApiConstants.kebelesByWoreda}/$woredaId";

    print("📤 GET KEBELES REQUEST");
    print("URL: $url");

    final response = await dioClient.get(url);

    print("✅ KEBELES RESPONSE:");
    print(response.data);

    return response.data;
  }
}
