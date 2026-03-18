import 'package:agrilink/core/network/api_constants.dart';
import 'package:agrilink/core/network/dio_client.dart';

class ProductService {
  final DioClient dioClient;

  ProductService({required this.dioClient});

  Future<List<dynamic>> getProducts() async {
    final response = await dioClient.get(ApiConstants.product);

    return List.from(response.data);
  }
}
