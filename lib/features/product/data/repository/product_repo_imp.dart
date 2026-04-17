import 'dart:io';
import 'package:agrilink/features/product/data/model/product_model.dart';
import 'package:agrilink/features/product/data/services/product_service.dart';
import 'package:agrilink/features/product/domain/repository/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductService productService;

  ProductRepositoryImpl(this.productService);

  @override
  Future<List<ProductModel>> getProducts({
    int? page,
    int? limit,
    String? category,
    String? search,
  }) async {
    final response = await productService.getProducts(
      page: page,
      limit: limit,
      category: category,
      search: search,
    );

    return response.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> createProduct({
    required String name,
    required int amount,
    required int price,
    required String description,
    required String subCategoryId,
    required File image,
  }) async {
    final response = await productService.createProduct(
      name: name,
      amount: amount,
      price: price,
      description: description,
      subCategoryId: subCategoryId,
      image: image,
    );
    
    return ProductModel.fromJson(response);
  }

  @override
  Future<List<ProductModel>> getMyProducts({
    int? page,
    int? limit,
    String? status,
  }) async {
    final response = await productService.getMyProducts(
      page: page,
      limit: limit,
      status: status,
    );

    return response.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final response = await productService.getProductById(id);
    return ProductModel.fromJson(response);
  }

  @override
  Future<ProductModel> updateProduct({
    required String id,
    String? name,
    int? amount,
    int? price,
    String? description,
    String? subCategoryId,
    File? image,
  }) async {
    final response = await productService.updateProduct(
      id: id,
      name: name,
      amount: amount,
      price: price,
      description: description,
      subCategoryId: subCategoryId,
      image: image,
    );
    
    return ProductModel.fromJson(response);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await productService.deleteProduct(id);
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    final response = await productService.getProductsByCategory(categoryId);
    return response.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await productService.searchProducts(query);
    return response.map((json) => ProductModel.fromJson(json)).toList();
  }
}