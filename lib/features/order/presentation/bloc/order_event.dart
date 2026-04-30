
abstract class OrderEvent {
  const OrderEvent();
}

// ================= BUYER ORDER EVENTS =================

class GetMyOrdersEvent extends OrderEvent {}

class GetOrderByIdEvent extends OrderEvent {
  final String orderId;
  const GetOrderByIdEvent({required this.orderId});
}

class CancelOrderEvent extends OrderEvent {
  final String orderId;
  const CancelOrderEvent({required this.orderId});
}

class CompleteOrderEvent extends OrderEvent {
  final String orderId;
  const CompleteOrderEvent({required this.orderId});
}

class GetOrderCountsEvent extends OrderEvent {}

// ================= FARMER/SELLER ORDER EVENTS =================

class GetFarmerOrdersEvent extends OrderEvent {}

class GetPendingFarmerOrdersEvent extends OrderEvent {}

class GetFarmerOrderByIdEvent extends OrderEvent {
  final String orderId;
  const GetFarmerOrderByIdEvent({required this.orderId});
}

class UpdateOrderStatusEvent extends OrderEvent {
  final String orderId;
  final String status;
  const UpdateOrderStatusEvent({
    required this.orderId,
    required this.status,
  });
}

class AcceptOrderEvent extends OrderEvent {
  final String orderId;
  const AcceptOrderEvent({required this.orderId});
}

class RejectOrderEvent extends OrderEvent {
  final String orderId;
  final String? reason;
  const RejectOrderEvent({
    required this.orderId,
    this.reason,
  });
}

class MarkAsDeliveredEvent extends OrderEvent {
  final String orderId;
  const MarkAsDeliveredEvent({required this.orderId});
}

class GetFarmerOrderCountsEvent extends OrderEvent {}

// ================= CHECKOUT EVENTS =================

class CheckoutEvent extends OrderEvent {
  final String addressId;
  final String paymentMethod;
  const CheckoutEvent({
    required this.addressId,
    required this.paymentMethod,
  });
}

class VerifyOrderEvent extends OrderEvent {
  final String orderId;
  const VerifyOrderEvent({required this.orderId});
}

// ================= REFRESH EVENTS =================

class RefreshOrdersEvent extends OrderEvent {
  final String? orderType; // 'buyer' or 'farmer'
  const RefreshOrdersEvent({this.orderType});
}

class ResetOrderStateEvent extends OrderEvent {}

class ToggleOrderViewEvent extends OrderEvent {
  final bool showFarmerView;
  const ToggleOrderViewEvent({required this.showFarmerView});
}