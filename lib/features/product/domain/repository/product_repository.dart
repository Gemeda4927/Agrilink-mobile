import 'dart:io';
import 'package:agrilink/features/product/data/model/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts();

  Future<void> createProduct({
    required String name,
    required int amount,
    required int price,
    required String description,
    required String subCategoryId,
    required File image,
  });
}
