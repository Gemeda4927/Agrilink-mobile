// lib/features/order/presentation/bloc/order_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_my_orders.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  // Buyer order use cases
  final GetMyOrdersUseCase2 getMyOrdersUseCase;
  final GetOrderByIdUseCase2 getOrderByIdUseCase;
  final CancelOrderUseCase2 cancelOrderUseCase;
  final CompleteOrderUseCase2 completeOrderUseCase;
  final GetOrderCountsUseCase2 getOrderCountsUseCase;

  // Farmer order use cases
  final GetFarmerOrdersUseCase2 getFarmerOrdersUseCase;
  final GetPendingFarmerOrdersUseCase2 getPendingFarmerOrdersUseCase;
  final GetFarmerOrderByIdUseCase2 getFarmerOrderByIdUseCase;
  final UpdateOrderStatusUseCase2 updateOrderStatusUseCase;
  final AcceptOrderUseCase2 acceptOrderUseCase;
  final RejectOrderUseCase2 rejectOrderUseCase;
  final MarkAsDeliveredUseCase2 markAsDeliveredUseCase;
  final GetFarmerOrderCountsUseCase2 getFarmerOrderCountsUseCase;

  // Checkout use cases
  final CheckoutUseCase2 checkoutUseCase;
  final VerifyOrderUseCase2 verifyOrderUseCase;

  OrderBloc({
    required this.getMyOrdersUseCase,
    required this.getOrderByIdUseCase,
    required this.cancelOrderUseCase,
    required this.completeOrderUseCase,
    required this.getOrderCountsUseCase,
    required this.getFarmerOrdersUseCase,
    required this.getPendingFarmerOrdersUseCase,
    required this.getFarmerOrderByIdUseCase,
    required this.updateOrderStatusUseCase,
    required this.acceptOrderUseCase,
    required this.rejectOrderUseCase,
    required this.markAsDeliveredUseCase,
    required this.getFarmerOrderCountsUseCase,
    required this.checkoutUseCase,
    required this.verifyOrderUseCase,
  }) : super(OrderInitial()) {
    // Buyer order event handlers
    on<GetMyOrdersEvent>(_onGetMyOrders);
    on<GetOrderByIdEvent>(_onGetOrderById);
    on<CancelOrderEvent>(_onCancelOrder);
    on<CompleteOrderEvent>(_onCompleteOrder);
    on<GetOrderCountsEvent>(_onGetOrderCounts);

    // Farmer order event handlers
    on<GetFarmerOrdersEvent>(_onGetFarmerOrders);
    on<GetPendingFarmerOrdersEvent>(_onGetPendingFarmerOrders);
    on<GetFarmerOrderByIdEvent>(_onGetFarmerOrderById);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<AcceptOrderEvent>(_onAcceptOrder);
    on<RejectOrderEvent>(_onRejectOrder);
    on<MarkAsDeliveredEvent>(_onMarkAsDelivered);
    on<GetFarmerOrderCountsEvent>(_onGetFarmerOrderCounts);
    on<ToggleOrderViewEvent>(_onToggleOrderView);

    // Checkout event handlers
    on<CheckoutEvent>(_onCheckout);
    on<VerifyOrderEvent>(_onVerifyOrder);

    // Refresh and reset handlers
    on<RefreshOrdersEvent>(_onRefreshOrders);
    on<ResetOrderStateEvent>(_onResetState);
  }

  // ================= BUYER ORDER HANDLERS =================

  Future<void> _onGetMyOrders(
    GetMyOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await getMyOrdersUseCase(const NoParams());

    result.fold((error) => emit(OrderError(message: error)), (orders) {
      if (orders.isEmpty) {
        emit(EmptyOrders());
      } else {
        emit(OrdersLoaded(orders: orders));
      }
    });
  }

  Future<void> _onGetOrderById(
    GetOrderByIdEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await getOrderByIdUseCase(event.orderId);

    result.fold(
      (error) => emit(OrderError(message: error)),
      (order) => emit(OrderDetailsLoaded(order: order)),
    );
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await cancelOrderUseCase(event.orderId);

    result.fold(
      (error) => emit(OrderError(message: error)),
      (order) => emit(OrderCancelled(orderId: order.id)),
    );
  }

  Future<void> _onCompleteOrder(
    CompleteOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await completeOrderUseCase(event.orderId);

    result.fold(
      (error) => emit(OrderError(message: error)),
      (order) => emit(OrderCompleted(orderId: order.id)),
    );
  }

  Future<void> _onGetOrderCounts(
    GetOrderCountsEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await getOrderCountsUseCase(const NoParams());

    result.fold(
      (error) => emit(OrderError(message: error)),
      (counts) => emit(OrderCountsLoaded(counts: counts)),
    );
  }

  // ================= FARMER ORDER HANDLERS =================

  Future<void> _onGetFarmerOrders(
    GetFarmerOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await getFarmerOrdersUseCase(const NoParams());

    result.fold((error) => emit(OrderError(message: error)), (orders) {
      if (orders.isEmpty) {
        emit(EmptyOrders());
      } else {
        emit(FarmerOrdersLoaded(orders: orders));
      }
    });
  }

  Future<void> _onGetPendingFarmerOrders(
    GetPendingFarmerOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await getPendingFarmerOrdersUseCase(const NoParams());

    result.fold((error) => emit(OrderError(message: error)), (orders) {
      if (orders.isEmpty) {
        emit(EmptyOrders());
      } else {
        emit(PendingFarmerOrdersLoaded(orders: orders));
      }
    });
  }

  Future<void> _onGetFarmerOrderById(
    GetFarmerOrderByIdEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await getFarmerOrderByIdUseCase(event.orderId);

    result.fold(
      (error) => emit(OrderError(message: error)),
      (order) => emit(FarmerOrderDetailsLoaded(order: order)),
    );
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    // FIXED: Changed to UpdateOrderStatusParams2
    final result = await updateOrderStatusUseCase(
      UpdateOrderStatusParams2(orderId: event.orderId, status: event.status),
    );

    result.fold(
      (error) => emit(OrderError(message: error)),
      (order) =>
          emit(OrderStatusUpdated(orderId: order.id, status: order.status)),
    );
  }

  Future<void> _onAcceptOrder(
    AcceptOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await acceptOrderUseCase(event.orderId);

    result.fold(
      (error) => emit(OrderError(message: error)),
      (order) => emit(OrderAccepted(orderId: order.id)),
    );
  }

  Future<void> _onRejectOrder(
    RejectOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    // FIXED: Changed to RejectOrderParams2
    final result = await rejectOrderUseCase(
      RejectOrderParams2(orderId: event.orderId, reason: event.reason),
    );

    result.fold(
      (error) => emit(OrderError(message: error)),
      (order) => emit(OrderRejected(orderId: order.id)),
    );
  }

  Future<void> _onMarkAsDelivered(
    MarkAsDeliveredEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await markAsDeliveredUseCase(event.orderId);

    result.fold(
      (error) => emit(OrderError(message: error)),
      (order) => emit(OrderDelivered(orderId: order.id)),
    );
  }

  Future<void> _onGetFarmerOrderCounts(
    GetFarmerOrderCountsEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await getFarmerOrderCountsUseCase(const NoParams());

    result.fold(
      (error) => emit(OrderError(message: error)),
      (counts) => emit(FarmerOrderCountsLoaded(counts: counts)),
    );
  }

  // ================= CHECKOUT HANDLERS =================

  Future<void> _onCheckout(
    CheckoutEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    // FIXED: Changed to CheckoutParams2
    final result = await checkoutUseCase(
      CheckoutParams2(
        addressId: event.addressId,
        paymentMethod: event.paymentMethod,
      ),
    );

    result.fold(
      (error) => emit(OrderError(message: error)),
      (checkoutData) => emit(CheckoutSuccess(checkoutData: checkoutData)),
    );
  }

  Future<void> _onVerifyOrder(
    VerifyOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await verifyOrderUseCase(event.orderId);

    result.fold(
      (error) => emit(OrderError(message: error)),
      (order) => emit(OrderVerified(order: order)),
    );
  }

  // ================= REFRESH & RESET HANDLERS =================

  Future<void> _onRefreshOrders(
    RefreshOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (event.orderType == 'farmer') {
      add(GetFarmerOrdersEvent());
    } else {
      add(GetMyOrdersEvent());
    }
  }

  Future<void> _onToggleOrderView(
    ToggleOrderViewEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (event.showFarmerView) {
      add(GetFarmerOrdersEvent());
    } else {
      add(GetMyOrdersEvent());
    }
  }

  Future<void> _onResetState(
    ResetOrderStateEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderInitial());
  }
}