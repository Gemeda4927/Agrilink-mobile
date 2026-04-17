import 'package:dartz/dartz.dart';
import '../../data/model/product_model.dart';
import '../repository/product_repository.dart';

class SearchProductsUseCase {
  final ProductRepository repository;

  SearchProductsUseCase(this.repository);

  Future<Either<String, List<ProductModel>>> call(String query) async {
    try {
      final products = await repository.searchProducts(query);
      return Right(products);
    } catch (e) {
      return Left(e.toString());
    }
  }
}