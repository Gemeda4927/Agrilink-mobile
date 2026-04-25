// ================= BLOC =================
import 'package:agrilink/features/my_product/domain/usecases/farmer_order_usecases.dart';
import 'package:agrilink/features/my_product/presentation/bloc/farmer_order_events.dart';
import 'package:agrilink/features/my_product/presentation/bloc/farmer_order_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FarmerOrderBloc extends Bloc<FarmerOrderEvent, FarmerOrderState> {
  final GetFarmerOrdersUseCase _getFarmerOrdersUseCase;
  final GetPendingFarmerOrdersUseCase _getPendingFarmerOrdersUseCase;
  final GetFarmerOrderByIdUseCase _getFarmerOrderByIdUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  final PatchProductUseCase _patchProductUseCase;

  FarmerOrderBloc({
    required GetFarmerOrdersUseCase getFarmerOrdersUseCase,
    required GetPendingFarmerOrdersUseCase getPendingFarmerOrdersUseCase,
    required GetFarmerOrderByIdUseCase getFarmerOrderByIdUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
    required PatchProductUseCase patchProductUseCase,
  }) : _getFarmerOrdersUseCase = getFarmerOrdersUseCase,
       _getPendingFarmerOrdersUseCase = getPendingFarmerOrdersUseCase,
       _getFarmerOrderByIdUseCase = getFarmerOrderByIdUseCase,
       _updateOrderStatusUseCase = updateOrderStatusUseCase,
       _patchProductUseCase = patchProductUseCase,
       super(FarmerOrderInitial()) {
    on<LoadFarmerOrdersEvent>(_onLoadFarmerOrders);
    on<LoadPendingFarmerOrdersEvent>(_onLoadPendingFarmerOrders);
    on<LoadFarmerOrderByIdEvent>(_onLoadFarmerOrderById);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<PatchProductEvent>(_onPatchProduct);
  }

  // ================= HANDLERS =================
  Future<void> _onLoadFarmerOrders(
    LoadFarmerOrdersEvent event,
    Emitter<FarmerOrderState> emit,
  ) async {
    emit(FarmerOrderLoading());
    final result = await _getFarmerOrdersUseCase(const NoParams());
    result.fold(
      (failure) => emit(FarmerOrderError(failure.message)),
      (orders) => emit(FarmerOrdersLoaded(orders)),
    );
  }

  Future<void> _onLoadPendingFarmerOrders(
    LoadPendingFarmerOrdersEvent event,
    Emitter<FarmerOrderState> emit,
  ) async {
    emit(FarmerOrderLoading());
    final result = await _getPendingFarmerOrdersUseCase(const NoParams());
    result.fold(
      (failure) => emit(FarmerOrderError(failure.message)),
      (orders) => emit(PendingFarmerOrdersLoaded(orders)),
    );
  }

  Future<void> _onLoadFarmerOrderById(
    LoadFarmerOrderByIdEvent event,
    Emitter<FarmerOrderState> emit,
  ) async {
    emit(FarmerOrderLoading());
    final result = await _getFarmerOrderByIdUseCase(event.orderId);
    result.fold(
      (failure) => emit(FarmerOrderError(failure.message)),
      (order) => emit(FarmerOrderLoaded(order)),
    );
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<FarmerOrderState> emit,
  ) async {
    emit(FarmerOrderLoading());
    final result = await _updateOrderStatusUseCase(
      UpdateOrderStatusParams(orderId: event.orderId, status: event.status),
    );
    result.fold(
      (failure) => emit(FarmerOrderError(failure.message)),
      (_) => emit(OrderStatusUpdated('Order status updated successfully')),
    );
  }

  Future<void> _onPatchProduct(
    PatchProductEvent event,
    Emitter<FarmerOrderState> emit,
  ) async {
    emit(FarmerOrderLoading());
    final result = await _patchProductUseCase(
      PatchProductParams(
        productId: event.productId,
        name: event.name,
        amount: event.amount,
        price: event.price,
        description: event.description,
        city: event.city,
        subCategoryId: event.subCategoryId,
        withDelivery: event.withDelivery,
        image: event.image,
      ),
    );
    result.fold(
      (failure) => emit(FarmerOrderError(failure.message)),
      (product) => emit(ProductPatched(product)),
    );
  }
}
