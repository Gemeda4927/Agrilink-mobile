// lib/features/order/presentation/bloc/farmer_order_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/farmer_order_usecases.dart';
import 'farmer_order_event.dart';
import 'farmer_order_state.dart';

class FarmerOrderBloc extends Bloc<FarmerOrderEvent, FarmerOrderState> {
  final GetFarmerOrdersUseCase _getFarmerOrdersUseCase;
  final GetPendingFarmerOrdersUseCase _getPendingFarmerOrdersUseCase;
  final GetFarmerOrderByIdUseCase _getFarmerOrderByIdUseCase;
  final ConfirmOrderUseCase _confirmOrderUseCase;
  final MarkAsShippedUseCase _markAsShippedUseCase;
  final MarkAsDeliveredUseCase _markAsDeliveredUseCase;

  FarmerOrderBloc({
    required GetFarmerOrdersUseCase getFarmerOrdersUseCase,
    required GetPendingFarmerOrdersUseCase getPendingFarmerOrdersUseCase,
    required GetFarmerOrderByIdUseCase getFarmerOrderByIdUseCase,
    required ConfirmOrderUseCase confirmOrderUseCase,
    required MarkAsShippedUseCase markAsShippedUseCase,
    required MarkAsDeliveredUseCase markAsDeliveredUseCase,
  }) : _getFarmerOrdersUseCase = getFarmerOrdersUseCase,
       _getPendingFarmerOrdersUseCase = getPendingFarmerOrdersUseCase,
       _getFarmerOrderByIdUseCase = getFarmerOrderByIdUseCase,
       _confirmOrderUseCase = confirmOrderUseCase,
       _markAsShippedUseCase = markAsShippedUseCase,
       _markAsDeliveredUseCase = markAsDeliveredUseCase,
       super(FarmerOrderInitial()) {
    on<LoadFarmerOrders>(_onLoadFarmerOrders);
    on<LoadPendingFarmerOrders>(_onLoadPendingFarmerOrders);
    on<GetFarmerOrderById>(_onGetFarmerOrderById);
    on<ConfirmFarmerOrder>(_onConfirmFarmerOrder);
    on<MarkOrderAsShipped>(_onMarkOrderAsShipped);
    on<MarkOrderAsDelivered>(_onMarkOrderAsDelivered);
    on<RefreshFarmerOrders>(_onRefreshFarmerOrders);
  }

  Future<void> _onLoadFarmerOrders(
    LoadFarmerOrders event,
    Emitter<FarmerOrderState> emit,
  ) async {
    emit(FarmerOrderLoading());

    final result = await _getFarmerOrdersUseCase(const NoParams());

    result.fold(
      (failure) => emit(FarmerOrderError(message: failure.message)),
      (orders) => emit(FarmerOrderLoaded(orders: orders)),
    );
  }

  Future<void> _onLoadPendingFarmerOrders(
    LoadPendingFarmerOrders event,
    Emitter<FarmerOrderState> emit,
  ) async {
    emit(FarmerOrderLoading());

    final result = await _getPendingFarmerOrdersUseCase(const NoParams());

    result.fold(
      (failure) => emit(FarmerOrderError(message: failure.message)),
      (orders) => emit(FarmerOrderLoaded(orders: orders)),
    );
  }

  Future<void> _onGetFarmerOrderById(
    GetFarmerOrderById event,
    Emitter<FarmerOrderState> emit,
  ) async {
    emit(FarmerOrderLoading());

    final result = await _getFarmerOrderByIdUseCase(event.orderId);

    result.fold(
      (failure) => emit(FarmerOrderError(message: failure.message)),
      (order) => emit(FarmerOrderDetailLoaded(order: order)),
    );
  }

  Future<void> _onConfirmFarmerOrder(
    ConfirmFarmerOrder event,
    Emitter<FarmerOrderState> emit,
  ) async {
    emit(FarmerOrderActionLoading());

    final result = await _confirmOrderUseCase(event.orderId);

    result.fold((failure) => emit(FarmerOrderError(message: failure.message)), (
      _,
    ) {
      emit(FarmerOrderActionSuccess(message: 'Order confirmed successfully'));
      add(LoadFarmerOrders());
    });
  }

  Future<void> _onMarkOrderAsShipped(
    MarkOrderAsShipped event,
    Emitter<FarmerOrderState> emit,
  ) async {
    emit(FarmerOrderActionLoading());

    final result = await _markAsShippedUseCase(event.orderId);

    result.fold((failure) => emit(FarmerOrderError(message: failure.message)), (
      _,
    ) {
      emit(FarmerOrderActionSuccess(message: 'Order marked as shipped'));
      add(LoadFarmerOrders());
    });
  }

  Future<void> _onMarkOrderAsDelivered(
    MarkOrderAsDelivered event,
    Emitter<FarmerOrderState> emit,
  ) async {
    emit(FarmerOrderActionLoading());

    final result = await _markAsDeliveredUseCase(event.orderId);

    result.fold((failure) => emit(FarmerOrderError(message: failure.message)), (
      _,
    ) {
      emit(FarmerOrderActionSuccess(message: 'Order marked as delivered'));
      add(LoadFarmerOrders());
    });
  }

  Future<void> _onRefreshFarmerOrders(
    RefreshFarmerOrders event,
    Emitter<FarmerOrderState> emit,
  ) async {
    final result = await _getFarmerOrdersUseCase(const NoParams());

    result.fold(
      (failure) => emit(FarmerOrderError(message: failure.message)),
      (orders) => emit(FarmerOrderLoaded(orders: orders)),
    );
  }
}
