import 'dart:io';
import 'package:agrilink/core/network/api_constants.dart';
import 'package:agrilink/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class ProductService {
  final DioClient dioClient;

  ProductService({required this.dioClient});

  // GET /product - Get all products
  Future<List<dynamic>> getProducts({
    int? page,
    int? limit,
    String? category,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (category != null) queryParams['category'] = category;
    if (search != null) queryParams['search'] = search;

    final response = await dioClient.get(
      ApiConstants.product,
      queryParameters: queryParams,
    );
    return List.from(response.data);
  }

  // POST /product - Create a new product
  Future<Map<String, dynamic>> createProduct({
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

    final response = await dioClient.post(ApiConstants.product, data: formData);
    return response.data;
  }

  // GET /product/my-products - Get current user's products
  Future<List<dynamic>> getMyProducts({
    int? page,
    int? limit,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (status != null) queryParams['status'] = status;

    final response = await dioClient.get(
      ApiConstants.myProducts,
      queryParameters: queryParams,
    );
    return List.from(response.data);
  }

  // GET /product/{id} - Get product by ID
  Future<Map<String, dynamic>> getProductById(String id) async {
    final response = await dioClient.get(ApiConstants.getProductById(id));
    return response.data;
  }

  // PATCH /product/{id} - Update product
  Future<Map<String, dynamic>> updateProduct({
    required String id,
    String? name,
    int? amount,
    int? price,
    String? description,
    String? subCategoryId,
    File? image,
  }) async {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (amount != null) data['amount'] = amount;
    if (price != null) data['price'] = price;
    if (description != null) data['description'] = description;
    if (subCategoryId != null) data['subCategoryId'] = subCategoryId;

    if (image != null) {
      FormData formData = FormData.fromMap({
        ...data,
        "image": await MultipartFile.fromFile(image.path),
      });
      final response = await dioClient.patch(
        ApiConstants.updateProduct(id),
        data: formData,
      );
      return response.data;
    } else {
      final response = await dioClient.patch(
        ApiConstants.updateProduct(id),
        data: data,
      );
      return response.data;
    }
  }

  // DELETE /product/{id} - Delete product
  Future<void> deleteProduct(String id) async {
    await dioClient.delete(ApiConstants.deleteProduct(id));
  }

  // Additional helper methods
  Future<List<dynamic>> getProductsByCategory(String categoryId) async {
    final response = await dioClient.get(
      ApiConstants.product,
      queryParameters: {'categoryId': categoryId},
    );
    return List.from(response.data);
  }

  Future<List<dynamic>> searchProducts(String query) async {
    final response = await dioClient.get(
      ApiConstants.product,
      queryParameters: {'search': query},
    );
    return List.from(response.data);
  }
}
