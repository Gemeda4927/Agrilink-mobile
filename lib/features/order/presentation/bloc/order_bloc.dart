import 'package:agrilink/features/order/domain/usecases/get_my_orders.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetMyOrdersUseCase getMyOrdersUseCase;

  OrderBloc({required this.getMyOrdersUseCase}) : super(OrderInitial()) {
    on<GetMyOrdersEvent>(_onGetMyOrders);
    on<RefreshOrdersEvent>(_onRefreshOrders);
  }

  Future<void> _onGetMyOrders(
    GetMyOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    final result = await getMyOrdersUseCase.execute();

    result.fold((error) => emit(OrderError(message: error)), (orders) {
      if (orders.isEmpty) {
        emit(EmptyOrders()); // This is a state, not a widget
      } else {
        emit(OrdersLoaded(orders: orders));
      }
    });
  }

  Future<void> _onRefreshOrders(
    RefreshOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    add(GetMyOrdersEvent());
  }
}
