// lib/features/product/domain/usecases/update_product.dart
import 'package:dartz/dartz.dart';
import 'dart:io';
import '../../data/model/product_model.dart';
import '../repository/product_repository.dart';

class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  Future<Either<String, ProductModel>> call({
    required String id,
    String? name,
    int? amount,
    int? price,
    String? description,
    String? subCategoryId,
    File? image,
  }) async {
    try {
      final product = await repository.updateProduct(
        id: id,
        name: name,
        amount: amount,
        price: price,
        description: description,
        subCategoryId: subCategoryId,
        image: image,
      );
      return Right(product);
    } catch (e) {
      return Left(e.toString());
    }
  }
}