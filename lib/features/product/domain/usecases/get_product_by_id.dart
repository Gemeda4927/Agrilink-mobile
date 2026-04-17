
import 'package:dartz/dartz.dart';
import '../../data/model/product_model.dart';
import '../repository/product_repository.dart';

class GetProductByIdUseCase {
  final ProductRepository repository;

  GetProductByIdUseCase(this.repository);

  Future<Either<String, ProductModel>> call(String id) async {
    try {
      final product = await repository.getProductById(id);
      return Right(product);
    } catch (e) {
      return Left(e.toString());
    }
  }
}