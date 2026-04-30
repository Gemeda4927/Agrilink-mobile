import 'dart:io';
import 'package:agrilink/features/product/data/model/product_model.dart';

abstract class ProductRepository {
  // GET /product - Get all products
  Future<List<ProductModel>> getProducts({
    int? page,
    int? limit,
    String? category,
    String? search,
  });

  // POST /product - Create a new product
  Future<ProductModel> createProduct({
    required String name,
    required int amount,
    required int price,
    required String description,
    required String subCategoryId,
    required File image,
  });

  // GET /product/my-products - Get current user's products
  Future<List<ProductModel>> getMyProducts({
    int? page,
    int? limit,
    String? status,
  });

  // GET /product/{id} - Get product by ID
  Future<ProductModel> getProductById(String id);

  // PATCH /product/{id} - Update product
  Future<ProductModel> updateProduct({
    required String id,
    String? name,
    int? amount,
    int? price,
    String? description,
    String? subCategoryId,
    
    File? image,
  });

  // DELETE /product/{id} - Delete product
  Future<void> deleteProduct(String id);

  // Additional helper methods
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  Future<List<ProductModel>> searchProducts(String query);
}
