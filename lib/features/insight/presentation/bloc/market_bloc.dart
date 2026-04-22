import 'package:agrilink/features/insight/presentation/bloc/market_event.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/insight/domain/usecase/market_usecases.dart';

// ================= BLOC =================
class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final GetAllProductsUseCase getAllProductsUseCase;
  final SubmitMarketPriceUseCase submitMarketPriceUseCase;
  final GetAllMarketPricesUseCase getAllMarketPricesUseCase;
  final GetApprovedMarketPricesUseCase getApprovedMarketPricesUseCase;
  final UpdateMarketPriceUseCase updateMarketPriceUseCase;

  MarketBloc({
    required this.getAllProductsUseCase,
    required this.submitMarketPriceUseCase,
    required this.getAllMarketPricesUseCase,
    required this.getApprovedMarketPricesUseCase,
    required this.updateMarketPriceUseCase,
  }) : super(MarketInitial()) {
    // Register event handlers
    on<GetAllProductsEvent>(_onGetAllProducts);
    on<SubmitMarketPriceEvent>(_onSubmitMarketPrice);
    on<GetAllMarketPricesEvent>(_onGetAllMarketPrices);
    on<GetApprovedMarketPricesEvent>(_onGetApprovedMarketPrices);
    on<UpdateMarketPriceEvent>(_onUpdateMarketPrice);
    on<ResetMarketStateEvent>(_onResetState);
  }

  // ================= EVENT HANDLERS =================

  /// Handle Get All Products
  Future<void> _onGetAllProducts(
    GetAllProductsEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      final products = await getAllProductsUseCase(NoParams());
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(MarketError(e.toString()));
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
      emit(MarketError(e.toString()));
    }
  }

  /// Handle Get All Market Prices
  Future<void> _onGetAllMarketPrices(
    GetAllMarketPricesEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      final prices = await getAllMarketPricesUseCase(NoParams());
      emit(MarketPricesLoaded(prices));
    } catch (e) {
      emit(MarketError(e.toString()));
    }
  }

  /// Handle Get Approved Market Prices
  Future<void> _onGetApprovedMarketPrices(
    GetApprovedMarketPricesEvent event,
    Emitter<MarketState> emit,
  ) async {
    try {
      emit(MarketLoading());
      final prices = await getApprovedMarketPricesUseCase(NoParams());
      emit(MarketPricesLoaded(prices));
    } catch (e) {
      emit(MarketError(e.toString()));
    }
  }

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
      emit(MarketError(e.toString()));
    }
  }

  /// Handle Reset State
  Future<void> _onResetState(
    ResetMarketStateEvent event,
    Emitter<MarketState> emit,
  ) async {
    emit(MarketInitial());
  }
}
