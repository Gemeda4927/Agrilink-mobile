// create_product.dart
import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:agrilink/features/product/data/model/product_model.dart';
import '../repository/product_repository.dart';

class CreateProduct {
  final ProductRepository repository;

  CreateProduct(this.repository);

  Future<Either<String, ProductModel>> call({
    required String name,
    required int amount,
    required int price,
    required String description,
    required String subCategoryId,
    required File image,
  }) async {
    try {
      final product = await repository.createProduct(
        name: name,
        amount: amount,
        price: price,
        description: description,
        subCategoryId: subCategoryId,
        image: image,
      );
      return Right(product);  // Return Right with ProductModel
    } catch (e) {
      return Left(e.toString());  // Return Left with error message
    }
  }
}