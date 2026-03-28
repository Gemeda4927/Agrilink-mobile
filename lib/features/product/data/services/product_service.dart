import 'dart:io';
import 'package:agrilink/core/network/api_constants.dart';
import 'package:agrilink/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class ProductService {
  final DioClient dioClient;

  ProductService({required this.dioClient});

  Future<List<dynamic>> getProducts() async {
    final response = await dioClient.get(ApiConstants.product);
    return List.from(response.data);
  }

  Future<void> createProduct({
    required String name,
    required int amount,
    required int price,
    required String description,
    required String subCategoryId,
    required File image,
  }) async {
    FormData formData = FormData.fromMap({
      "name": name,
      "amount": amount,
      "price": price,
      "description": description,
      "subCategoryId": subCategoryId,
      "image": await MultipartFile.fromFile(image.path),
    });

    await dioClient.post(ApiConstants.product, data: formData);
  }
}
