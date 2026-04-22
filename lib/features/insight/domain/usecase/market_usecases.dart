import 'package:agrilink/features/insight/data/model/market_insight.dart';
import 'package:agrilink/features/insight/domain/repository/i_market_repository.dart';

// ================= BASE USE CASE =================
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

class NoParams {
  const NoParams();
}

// ================= 1. GET ALL PRODUCTS USE CASE =================
class GetAllProductsUseCase implements UseCase<AllProductsResponse, NoParams> {
  final IMarketRepository repository;

  GetAllProductsUseCase(this.repository);

  @override
  Future<AllProductsResponse> call(NoParams params) async {
    return await repository.getAllProducts();
  }
}

// ================= 2. SUBMIT MARKET PRICE USE CASE =================
class SubmitMarketPriceUseCase {
  final IMarketRepository repository;

  SubmitMarketPriceUseCase(this.repository);

  Future<MarketPriceResponse> call(MarketPriceRequest request) async {
    return await repository.submitMarketPrice(request);
  }
}

// ================= 3. GET ALL MARKET PRICES USE CASE =================
class GetAllMarketPricesUseCase
    implements UseCase<List<MarketPriceResponse>, NoParams> {
  final IMarketRepository repository;

  GetAllMarketPricesUseCase(this.repository);

  @override
  Future<List<MarketPriceResponse>> call(NoParams params) async {
    return await repository.getAllMarketPrices();
  }
}

// ================= 4. GET APPROVED MARKET PRICES USE CASE =================
class GetApprovedMarketPricesUseCase
    implements UseCase<List<MarketPriceResponse>, NoParams> {
  final IMarketRepository repository;

  GetApprovedMarketPricesUseCase(this.repository);

  @override
  Future<List<MarketPriceResponse>> call(NoParams params) async {
    return await repository.getApprovedMarketPrices();
  }
}

// ================= 5. UPDATE MARKET PRICE USE CASE =================

class UpdateMarketPriceUseCase
    implements UseCase<MarketPriceResponse, UpdateMarketPriceParams> {
  final IMarketRepository repository;

  UpdateMarketPriceUseCase(this.repository);

  @override
  Future<MarketPriceResponse> call(UpdateMarketPriceParams params) async {
    return await repository.updateMarketPrice(params.id, params.request);
  }
}

class UpdateMarketPriceParams {
  final String id;
  final MarketPriceRequest request;

  UpdateMarketPriceParams({required this.id, required this.request});
}
