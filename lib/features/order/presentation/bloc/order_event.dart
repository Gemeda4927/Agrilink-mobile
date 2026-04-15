abstract class OrderEvent {
  const OrderEvent();
}

class GetMyOrdersEvent extends OrderEvent {}

class RefreshOrdersEvent extends OrderEvent {}