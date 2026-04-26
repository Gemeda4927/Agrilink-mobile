import 'package:agrilink/features/insight/data/model/market_insight.dart';
import 'package:agrilink/features/insight/data/services/marketService.dart';
import 'package:agrilink/features/insight/domain/repository/i_market_repository.dart';

// ================= BASE USE CASE =================
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

class NoParams {
  const NoParams();
}

// ================= 1. GET ALL PRODUCTS USE CASE (Privileged Users) =================
/// For ADMIN, AGENT, DATA_CONTRIBUTOR roles
/// Uses /all-product endpoint
class GetAllProductsUseCase implements UseCase<List<ProductInfo>, NoParams> {
  final IMarketRepository repository;

  GetAllProductsUseCase(this.repository);

  @override
  Future<List<ProductInfo>> call(NoParams params) async {
    return await repository.getAllProducts();
  }
}

// ================= 2. GET PUBLIC PRODUCTS USE CASE (Buyers) =================
/// For BUYER/FARMER role
/// Uses /product endpoint (no 403 error)
class GetPublicProductsUseCase implements UseCase<List<ProductInfo>, NoParams> {
  final IMarketRepository repository;

  GetPublicProductsUseCase(this.repository);

  @override
  Future<List<ProductInfo>> call(NoParams params) async {
    return await repository.getPublicProducts();
  }
}

// ================= 3. SUBMIT MARKET PRICE USE CASE =================
class SubmitMarketPriceUseCase {
  final IMarketRepository repository;

  SubmitMarketPriceUseCase(this.repository);

  Future<MarketPriceResponse> call(MarketPriceRequest request) async {
    return await repository.submitMarketPrice(request);
  }
}

// ================= 4. GET ALL MARKET PRICES USE CASE =================
/// For ADMIN, AGENT, DATA_CONTRIBUTOR roles
/// Returns all prices (including pending, approved, rejected)
class GetAllMarketPricesUseCase
    implements UseCase<List<MarketPriceResponse>, NoParams> {
  final IMarketRepository repository;

  GetAllMarketPricesUseCase(this.repository);

  @override
  Future<List<MarketPriceResponse>> call(NoParams params) async {
    return await repository.getAllMarketPrices();
  }
}

// ================= 5. GET APPROVED MARKET PRICES USE CASE =================
/// For all users (public)
/// Returns only approved prices
class GetApprovedMarketPricesUseCase
    implements UseCase<List<MarketPriceResponse>, NoParams> {
  final IMarketRepository repository;

  GetApprovedMarketPricesUseCase(this.repository);

  @override
  Future<List<MarketPriceResponse>> call(NoParams params) async {
    return await repository.getApprovedMarketPrices();
  }
}

// ================= 6. GET MY MARKET PRICES USE CASE =================
/// For DATA_CONTRIBUTOR role
/// Returns prices submitted by current user
class GetMyMarketPricesUseCase
    implements UseCase<List<MarketPriceResponse>, NoParams> {
  final IMarketRepository repository;

  GetMyMarketPricesUseCase(this.repository);

  @override
  Future<List<MarketPriceResponse>> call(NoParams params) async {
    return await repository.getMyMarketPrices();
  }
}

// ================= 7. GET MARKET PRICES BY WOREDA USE CASE =================
/// Filter market prices by district
class GetMarketPricesByWoredaUseCase
    implements UseCase<List<MarketPriceResponse>, String> {
  final IMarketRepository repository;

  GetMarketPricesByWoredaUseCase(this.repository);

  @override
  Future<List<MarketPriceResponse>> call(String woredaId) async {
    return await repository.getMarketPricesByWoreda(woredaId);
  }
}

// ================= 8. GET MARKET PRICES BY PRODUCT USE CASE =================
/// Filter market prices by product
class GetMarketPricesByProductUseCase
    implements UseCase<List<MarketPriceResponse>, String> {
  final IMarketRepository repository;

  GetMarketPricesByProductUseCase(this.repository);

  @override
  Future<List<MarketPriceResponse>> call(String productId) async {
    return await repository.getMarketPricesByProduct(productId);
  }
}

// ================= 9. GET MARKET PRICE BY ID USE CASE =================
/// Get single market price entry
class GetMarketPriceByIdUseCase
    implements UseCase<MarketPriceResponse, String> {
  final IMarketRepository repository;

  GetMarketPriceByIdUseCase(this.repository);

  @override
  Future<MarketPriceResponse> call(String id) async {
    return await repository.getMarketPriceById(id);
  }
}

// ================= 10. UPDATE MARKET PRICE USE CASE =================
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

// ================= 11. APPROVE MARKET PRICE USE CASE =================
/// For ADMIN, AGENT roles
class ApproveMarketPriceUseCase
    implements UseCase<MarketPriceResponse, String> {
  final IMarketRepository repository;

  ApproveMarketPriceUseCase(this.repository);

  @override
  Future<MarketPriceResponse> call(String id) async {
    return await repository.approveMarketPrice(id);
  }
}

// ================= 12. REJECT MARKET PRICE USE CASE =================
/// For ADMIN, AGENT roles
class RejectMarketPriceUseCase implements UseCase<MarketPriceResponse, String> {
  final IMarketRepository repository;

  RejectMarketPriceUseCase(this.repository);

  @override
  Future<MarketPriceResponse> call(String id) async {
    return await repository.rejectMarketPrice(id);
  }
}

// ================= 13. DELETE MARKET PRICE USE CASE =================
/// For ADMIN, AGENT roles
class DeleteMarketPriceUseCase implements UseCase<bool, String> {
  final IMarketRepository repository;

  DeleteMarketPriceUseCase(this.repository);

  @override
  Future<bool> call(String id) async {
    return await repository.deleteMarketPrice(id);
  }
}

// ================= 14. GET PRODUCT PRICE STATISTICS USE CASE =================
/// Get price statistics for a specific product
class GetProductPriceStatisticsUseCase
    implements UseCase<PriceStatistics, String> {
  final IMarketRepository repository;

  GetProductPriceStatisticsUseCase(this.repository);

  @override
  Future<PriceStatistics> call(String productId) async {
    return await repository.getProductPriceStatistics(productId);
  }
}

// ================= 15. GET RECENT PRICE ALERTS USE CASE =================
/// Get recent price alerts
class GetRecentPriceAlertsUseCase
    implements UseCase<List<MarketPriceResponse>, NoParams> {
  final IMarketRepository repository;

  GetRecentPriceAlertsUseCase(this.repository);

  @override
  Future<List<MarketPriceResponse>> call(NoParams params) async {
    return await repository.getRecentPriceAlerts();
  }
}
