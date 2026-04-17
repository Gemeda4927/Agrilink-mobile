
import 'package:dartz/dartz.dart';
import '../repository/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  Future<Either<String, void>> call(String id) async {
    try {
      await repository.deleteProduct(id);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}