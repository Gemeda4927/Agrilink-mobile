import 'package:agrilink/features/order/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';
import '../entities/order.dart' as order_entity;

class GetMyOrdersUseCase {
  final OrderRepository repository;

  GetMyOrdersUseCase(this.repository);

  Future<Either<String, List<order_entity.Order>>> execute() async {
    try {
      final orders = await repository.getMyOrders();
      return Right(orders);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
