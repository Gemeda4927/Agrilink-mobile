// lib/features/order/presentation/bloc/order_state.dart

import '../../domain/entities/order.dart' as order_entity;

abstract class OrderState {
  const OrderState();
}

// ================= INITIAL & LOADING STATES =================

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

// ================= ORDER LIST STATES =================

class OrdersLoaded extends OrderState {
  final List<order_entity.Order> orders;
  const OrdersLoaded({required this.orders});
}

class EmptyOrders extends OrderState {}

class FarmerOrdersLoaded extends OrderState {
  final List<order_entity.Order> orders;
  const FarmerOrdersLoaded({required this.orders});
}

class PendingFarmerOrdersLoaded extends OrderState {
  final List<order_entity.Order> orders;
  const PendingFarmerOrdersLoaded({required this.orders});
}

// ================= SINGLE ORDER STATES =================

class OrderDetailsLoaded extends OrderState {
  final order_entity.Order order;
  const OrderDetailsLoaded({required this.order});
}

class FarmerOrderDetailsLoaded extends OrderState {
  final order_entity.Order order;
  const FarmerOrderDetailsLoaded({required this.order});
}

// ================= ORDER COUNTS STATES =================

class OrderCountsLoaded extends OrderState {
  final Map<String, int> counts;
  const OrderCountsLoaded({required this.counts});
}

class FarmerOrderCountsLoaded extends OrderState {
  final Map<String, int> counts;
  const FarmerOrderCountsLoaded({required this.counts});
}

// ================= ACTION SUCCESS STATES =================

class OrderCancelled extends OrderState {
  final String orderId;
  final String message;
  const OrderCancelled({
    required this.orderId,
    this.message = 'Order cancelled successfully',
  });
}

class OrderCompleted extends OrderState {
  final String orderId;
  final String message;
  const OrderCompleted({
    required this.orderId,
    this.message = 'Order completed successfully',
  });
}

class OrderAccepted extends OrderState {
  final String orderId;
  final String message;
  const OrderAccepted({
    required this.orderId,
    this.message = 'Order accepted successfully',
  });
}

class OrderRejected extends OrderState {
  final String orderId;
  final String message;
  const OrderRejected({
    required this.orderId,
    this.message = 'Order rejected successfully',
  });
}

class OrderDelivered extends OrderState {
  final String orderId;
  final String message;
  const OrderDelivered({
    required this.orderId,
    this.message = 'Order marked as delivered',
  });
}

class OrderStatusUpdated extends OrderState {
  final String orderId;
  final String status;
  final String message;
  const OrderStatusUpdated({
    required this.orderId,
    required this.status,
    this.message = 'Order status updated successfully',
  });
}

// ================= CHECKOUT STATES =================

class CheckoutSuccess extends OrderState {
  final Map<String, dynamic> checkoutData;
  const CheckoutSuccess({required this.checkoutData});
}

class OrderVerified extends OrderState {
  final order_entity.Order order;
  const OrderVerified({required this.order});
}

// ================= ERROR STATE =================

class OrderError extends OrderState {
  final String message;
  const OrderError({required this.message});
}