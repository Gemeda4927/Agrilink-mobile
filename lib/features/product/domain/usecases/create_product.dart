import 'dart:io';
import 'package:agrilink/features/product/domain/repository/product_repository.dart';

class CreateProduct {
  final ProductRepository repository;

  CreateProduct(this.repository);

  Future<void> call({
    required String name,
    required int amount,
    required int price,
    required String description,
    required String subCategoryId,
    required File image,
  }) async {
    await repository.createProduct(
      name: name,
      amount: amount,
      price: price,
      description: description,
      subCategoryId: subCategoryId,
      image: image,
    );
  }
}
