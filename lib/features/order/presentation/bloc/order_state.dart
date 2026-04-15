import 'package:agrilink/features/order/domain/entities/order.dart'
    as order_entity;

abstract class OrderState {
  const OrderState();
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<order_entity.Order> orders;
  const OrdersLoaded({required this.orders});
}

class OrderError extends OrderState {
  final String message;
  const OrderError({required this.message});
}

class EmptyOrders extends OrderState {}
