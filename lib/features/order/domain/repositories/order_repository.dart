import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getMyOrders();
}