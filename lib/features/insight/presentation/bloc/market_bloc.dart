import 'package:agrilink/features/insight/presentation/bloc/market_event.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/insight/domain/usecase/market_usecases.dart';

// ================= BLOC =================
class MarketBloc extends Bloc<MarketEvent, MarketState> {
  // Product Use Cases
  final GetAllProductsUseCase getAllProductsUseCase;
  final GetPublicProductsUseCase getPublicProductsUseCase;

  // Market Price Use Cases
  final SubmitMarketPriceUseCase submitMarketPriceUseCase;
  final GetAllMarketPricesUseCase getAllMarketPricesUseCase;
  final GetApprovedMarketPricesUseCase getApprovedMarketPricesUseCase;
  final GetMyMarketPricesUseCase getMyMarketPricesUseCase;
  final GetMarketPricesByWoredaUseCase getMarketPricesByWoredaUseCase;
  final GetMarketPricesByProductUseCase getMarketPricesByProductUseCase;
  final GetMarketPriceByIdUseCase getMarketPriceByIdUseCase;
  final UpdateMarketPriceUseCase updateMarketPriceUseCase;
  final ApproveMarketPriceUseCase approveMarketPriceUseCase;
  final RejectMarketPriceUseCase rejectMarketPriceUseCase;
  final DeleteMarketPriceUseCase deleteMarketPriceUseCase;

  // Statistics Use Cases
  final GetProductPriceStatisticsUseCase getProductPriceStatisticsUseCase;
  final GetRecentPriceAlertsUseCase getRecentPriceAlertsUseCase;

  MarketBloc({
    required this.getAllProductsUseCase,
    required this.getPublicProductsUseCase,
    required this.submitMarketPriceUseCase,
    required this.getAllMarketPricesUseCase,
    required this.getApprovedMarketPricesUseCase,
    required this.getMyMarketPricesUseCase,
    required this.getMarketPricesByWoredaUseCase,
    required this.getMarketPricesByProductUseCase,
    required this.getMarketPriceByIdUseCase,
    required this.updateMarketPriceUseCase,
    required this.approveMarketPriceUseCase,
    required this.rejectMarketPriceUseCase,
    required this.deleteMarketPriceUseCase,
    required this.getProductPriceStatisticsUseCase,
    required this.getRecentPriceAlertsUseCase,
  }) : super(MarketInitial()) {
    // Register event handlers
    on<GetAllProductsEvent>(_onGetAllProducts);
    on<GetPublicProductsEvent>(_onGetPublicProducts);
    on<SubmitMarketPriceEvent>(_onSubmitMarketPrice);
    on<GetAllMarketPricesEvent>(_onGetAllMarketPrices);
    on<GetApprovedMarketPricesEvent>(_onGetApprovedMarketPrices);
    on<GetMyMarketPricesEvent>(_onGetMyMarketPrices);
    on<GetMarketPricesByWoredaEvent>(_onGetMarketPricesByWoreda);
    on<GetMarketPricesByProductEvent>(_onGetMarketPricesByProduct);
    on<GetMarketPriceByIdEvent>(_onGetMarketPriceById);
    on<GetProductPriceStatisticsEvent>(_onGetProductPriceStatistics);
    on<GetRecentPriceAlertsEvent>(_onGetRecentPriceAlerts);
    on<UpdateMarketPriceEvent>(_onUpdateMarketPrice);
    on<ApproveMarketPriceEvent>(_onApproveMarketPrice);
    on<RejectMarketPriceEvent>(_onRejectMarketPrice);
    on<DeleteMarketPriceEvent>(_onDeleteMarketPrice);
    on<ResetMarketStateEvent>(_onResetState);
  }

  // ================= EVENT HANDLERS =================

  /// Handle Get All Products - For privileged users
  Future<void> _onGetAllProducts(
    GetAllProductsEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      final products = await getAllProductsUseCase(NoParams());
      emit(ProductsLoaded(products));
    } catch (e) {
      _emitError(emit, e);
    }
  }

  /// Handle Get Public Products - For BUYER/FARMER role
  Future<void> _onGetPublicProducts(
    GetPublicProductsEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      final products = await getPublicProductsUseCase(NoParams());
      emit(ProductsLoaded(products));
    } catch (e) {
      _emitError(emit, e);
    }
  }

  /// Handle Submit Market Price
  Future<void> _onSubmitMarketPrice(
    SubmitMarketPriceEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      final response = await submitMarketPriceUseCase(event.request);
      emit(MarketPriceSubmitted(response));
    } catch (e) {
      _emitError(emit, e);
    }
  }

  /// Handle Get All Market Prices - For privileged users
  Future<void> _onGetAllMarketPrices(
    GetAllMarketPricesEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      final prices = await getAllMarketPricesUseCase(NoParams());
      emit(MarketPricesLoaded(prices));
    } catch (e) {
      _emitError(emit, e);
    }
  }

  /// Handle Get Approved Market Prices - For all users (public)
  Future<void> _onGetApprovedMarketPrices(
    GetApprovedMarketPricesEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      final prices = await getApprovedMarketPricesUseCase(NoParams());
      emit(MarketPricesLoaded(prices));
    } catch (e) {
      _emitError(emit, e);
    }
  }

  /// Handle Get My Market Prices - For DATA_CONTRIBUTOR
  Future<void> _onGetMyMarketPrices(
    GetMyMarketPricesEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      final prices = await getMyMarketPricesUseCase(NoParams());
      emit(MarketPricesLoaded(prices));
    } catch (e) {
      _emitError(emit, e);
    }
  }

  /// Handle Get Market Prices By Woreda
  Future<void> _onGetMarketPricesByWoreda(
    GetMarketPricesByWoredaEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      final prices = await getMarketPricesByWoredaUseCase(event.woredaId);
      emit(MarketPricesLoaded(prices));
    } catch (e) {
      _emitError(emit, e);
    }
  }

  /// Handle Get Market Prices By Product
  Future<void> _onGetMarketPricesByProduct(
    GetMarketPricesByProductEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      final prices = await getMarketPricesByProductUseCase(event.productId);
      emit(MarketPricesLoaded(prices));
    } catch (e) {
      _emitError(emit, e);
    }
  }

  /// Handle Get Market Price By ID
  Future<void> _onGetMarketPriceById(
    GetMarketPriceByIdEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      final price = await getMarketPriceByIdUseCase(event.id);
      emit(MarketPricesLoaded([price]));
    } catch (e) {
      _emitError(emit, e);
    }
  }

  /// Handle Get Product Price Statistics
  Future<void> _onGetProductPriceStatistics(
    GetProductPriceStatisticsEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      final statistics = await getProductPriceStatisticsUseCase(
        event.productId,
      );
      emit(PriceStatisticsLoaded(statistics));
    } catch (e) {
      _emitError(emit, e);
    }
  }

  /// Handle Get Recent Price Alerts
  Future<void> _onGetRecentPriceAlerts(
    GetRecentPriceAlertsEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      final alerts = await getRecentPriceAlertsUseCase(NoParams());
      emit(MarketPricesLoaded(alerts));
    } catch (e) {
      _emitError(emit, e);
    }
  }

  /// Handle Update Market Price
  Future<void> _onUpdateMarketPrice(
    UpdateMarketPriceEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      final response = await updateMarketPriceUseCase(
        UpdateMarketPriceParams(id: event.id, request: event.request),
      );
      emit(MarketPriceUpdated(response));
    } catch (e) {
      _emitError(emit, e);
    }
  }

  /// Handle Approve Market Price - For ADMIN/AGENT
  Future<void> _onApproveMarketPrice(
    ApproveMarketPriceEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      final response = await approveMarketPriceUseCase(event.priceId);
      emit(MarketPriceApproved(response));
      // Refresh the list after approval
      add(GetAllMarketPricesEvent());
    } catch (e) {
      _emitError(emit, e);
    }
  }

  /// Handle Reject Market Price - For ADMIN/AGENT
  Future<void> _onRejectMarketPrice(
    RejectMarketPriceEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      final response = await rejectMarketPriceUseCase(event.priceId);
      emit(MarketPriceRejected(response));
      // Refresh the list after rejection
      add(GetAllMarketPricesEvent());
    } catch (e) {
      _emitError(emit, e);
    }
  }

  /// Handle Delete Market Price - For ADMIN/AGENT
  Future<void> _onDeleteMarketPrice(
    DeleteMarketPriceEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      await deleteMarketPriceUseCase(event.priceId);
      emit(MarketPriceDeleted(event.priceId));
      // Refresh the list after deletion
      add(GetAllMarketPricesEvent());
    } catch (e) {
      _emitError(emit, e);
    }
  }

  /// Handle Reset State
  Future<void> _onResetState(
    ResetMarketStateEvent event,
    Emitter<MarketState> emit,
  ) async {
    emit(MarketInitial());
  }

  // ================= PRIVATE HELPERS =================

  /// Emits error state with consistent formatting
  void _emitError(Emitter<MarketState> emit, dynamic error) {
    emit(MarketError(error.toString()));
  }
}
