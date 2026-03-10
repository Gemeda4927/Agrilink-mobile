import 'package:agrilink/core/network/api_constants.dart';
import 'package:agrilink/core/network/dio_client.dart';

class CategoryService {
  final DioClient dioClient;

  CategoryService({required this.dioClient});

  Future<List<dynamic>> getCategories() async {
    final response = await dioClient.get(ApiConstants.category);

    return List.from(response.data);
  }

  Future<List<dynamic>> getSubCategories() async {
    final response = await dioClient.get(ApiConstants.subcategory);

    return List.from(response.data);
  }
}