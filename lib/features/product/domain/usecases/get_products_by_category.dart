import 'package:dartz/dartz.dart';
import '../../data/model/product_model.dart';
import '../repository/product_repository.dart';

class GetProductsByCategoryUseCase {
  final ProductRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  Future<Either<String, List<ProductModel>>> call(String categoryId) async {
    try {
      final products = await repository.getProductsByCategory(categoryId);
      return Right(products);
    } catch (e) {
      return Left(e.toString());
    }
  }
}