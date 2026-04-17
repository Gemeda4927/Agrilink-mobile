// lib/features/product/domain/usecases/get_my_products.dart
import 'package:dartz/dartz.dart';
import '../../data/model/product_model.dart';
import '../repository/product_repository.dart';

class GetMyProductsUseCase {
  final ProductRepository repository;

  GetMyProductsUseCase(this.repository);

  Future<Either<String, List<ProductModel>>> call({
    int? page,
    int? limit,
    String? status,
  }) async {
    try {
      final products = await repository.getMyProducts(
        page: page,
        limit: limit,
        status: status,
      );
      return Right(products);
    } catch (e) {
      return Left(e.toString());
    }
  }
}