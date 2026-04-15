import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../services/order_service.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderService orderService;

  OrderRepositoryImpl({required this.orderService});

  @override
  Future<List<Order>> getMyOrders() async {
    try {
      final orderModels = await orderService.getMyOrders();
      return orderModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }
}
