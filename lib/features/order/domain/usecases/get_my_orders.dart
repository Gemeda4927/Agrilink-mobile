// lib/features/order/domain/usecases/order_use_cases.dart

import 'package:agrilink/features/order/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';
import '../entities/order.dart' as order_entity;

// ================= BASE USE CASE =================

abstract class UseCase<Type, Params> {
  Future<Either<String, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}

// ================= 1. GET MY ORDERS USE CASE (BUYER) =================

class GetMyOrdersUseCase2 implements UseCase<List<order_entity.Order>, NoParams> {
  final OrderRepository repository;

  GetMyOrdersUseCase2(this.repository);

  @override
  Future<Either<String, List<order_entity.Order>>> call(NoParams params) async {
    try {
      final orders = await repository.getMyOrders();
      return Right(orders);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// ================= 2. GET FARMER ORDERS USE CASE (SELLER) =================

class GetFarmerOrdersUseCase2 implements UseCase<List<order_entity.Order>, NoParams> {
  final OrderRepository repository;

  GetFarmerOrdersUseCase2(this.repository);

  @override
  Future<Either<String, List<order_entity.Order>>> call(NoParams params) async {
    try {
      final orders = await repository.getFarmerOrders();
      return Right(orders);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// ================= 3. GET PENDING FARMER ORDERS USE CASE =================

class GetPendingFarmerOrdersUseCase2 implements UseCase<List<order_entity.Order>, NoParams> {
  final OrderRepository repository;

  GetPendingFarmerOrdersUseCase2(this.repository);

  @override
  Future<Either<String, List<order_entity.Order>>> call(NoParams params) async {
    try {
      final orders = await repository.getPendingFarmerOrders();
      return Right(orders);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// ================= 4. GET ORDER BY ID USE CASE =================

class GetOrderByIdUseCase2 implements UseCase<order_entity.Order, String> {
  final OrderRepository repository;

  GetOrderByIdUseCase2(this.repository);

  @override
  Future<Either<String, order_entity.Order>> call(String orderId) async {
    try {
      final order = await repository.getOrderById(orderId);
      return Right(order);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// ================= 5. GET FARMER ORDER BY ID USE CASE =================

class GetFarmerOrderByIdUseCase2 implements UseCase<order_entity.Order, String> {
  final OrderRepository repository;

  GetFarmerOrderByIdUseCase2(this.repository);

  @override
  Future<Either<String, order_entity.Order>> call(String orderId) async {
    try {
      final order = await repository.getFarmerOrderById(orderId);
      return Right(order);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// ================= 6. UPDATE ORDER STATUS USE CASE =================

class UpdateOrderStatusParams2 {
  final String orderId;
  final String status;

  UpdateOrderStatusParams2({
    required this.orderId,
    required this.status,
  });
}

class UpdateOrderStatusUseCase2 implements UseCase<order_entity.Order, UpdateOrderStatusParams2> {
  final OrderRepository repository;

  UpdateOrderStatusUseCase2(this.repository);

  @override
  Future<Either<String, order_entity.Order>> call(UpdateOrderStatusParams2 params) async {
    try {
      final order = await repository.updateOrderStatus(params.orderId, params.status);
      return Right(order);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// ================= 7. ACCEPT ORDER USE CASE (FARMER) =================

class AcceptOrderUseCase2 implements UseCase<order_entity.Order, String> {
  final OrderRepository repository;

  AcceptOrderUseCase2(this.repository);

  @override
  Future<Either<String, order_entity.Order>> call(String orderId) async {
    try {
      final order = await repository.acceptOrder(orderId);
      return Right(order);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// ================= 8. REJECT ORDER USE CASE (FARMER) =================

class RejectOrderParams2 {
  final String orderId;
  final String? reason;

  RejectOrderParams2({
    required this.orderId,
    this.reason,
  });
}

class RejectOrderUseCase2 implements UseCase<order_entity.Order, RejectOrderParams2> {
  final OrderRepository repository;

  RejectOrderUseCase2(this.repository);

  @override
  Future<Either<String, order_entity.Order>> call(RejectOrderParams2 params) async {
    try {
      final order = await repository.rejectOrder(params.orderId, reason: params.reason);
      return Right(order);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// ================= 9. MARK ORDER AS DELIVERED USE CASE (FARMER) =================

class MarkAsDeliveredUseCase2 implements UseCase<order_entity.Order, String> {
  final OrderRepository repository;

  MarkAsDeliveredUseCase2(this.repository);

  @override
  Future<Either<String, order_entity.Order>> call(String orderId) async {
    try {
      final order = await repository.markAsDelivered(orderId);
      return Right(order);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// ================= 10. CANCEL ORDER USE CASE (BUYER) =================

class CancelOrderUseCase2 implements UseCase<order_entity.Order, String> {
  final OrderRepository repository;

  CancelOrderUseCase2(this.repository);

  @override
  Future<Either<String, order_entity.Order>> call(String orderId) async {
    try {
      final order = await repository.cancelOrder(orderId);
      return Right(order);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// ================= 11. COMPLETE ORDER USE CASE (BUYER) =================

class CompleteOrderUseCase2 implements UseCase<order_entity.Order, String> {
  final OrderRepository repository;

  CompleteOrderUseCase2(this.repository);

  @override
  Future<Either<String, order_entity.Order>> call(String orderId) async {
    try {
      final order = await repository.completeOrder(orderId);
      return Right(order);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// ================= 12. CHECKOUT USE CASE =================

class CheckoutParams2 {
  final String addressId;
  final String paymentMethod;

  CheckoutParams2({
    required this.addressId,
    required this.paymentMethod,
  });
}

class CheckoutUseCase2 implements UseCase<Map<String, dynamic>, CheckoutParams2> {
  final OrderRepository repository;

  CheckoutUseCase2(this.repository);

  @override
  Future<Either<String, Map<String, dynamic>>> call(CheckoutParams2 params) async {
    try {
      final result = await repository.checkout(
        addressId: params.addressId,
        paymentMethod: params.paymentMethod,
      );
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// ================= 13. VERIFY ORDER USE CASE =================

class VerifyOrderUseCase2 implements UseCase<order_entity.Order, String> {
  final OrderRepository repository;

  VerifyOrderUseCase2(this.repository);

  @override
  Future<Either<String, order_entity.Order>> call(String orderId) async {
    try {
      final order = await repository.verifyOrder(orderId);
      return Right(order);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// ================= 14. GET ORDER COUNTS USE CASE (BUYER) =================

class GetOrderCountsUseCase2 implements UseCase<Map<String, int>, NoParams> {
  final OrderRepository repository;

  GetOrderCountsUseCase2(this.repository);

  @override
  Future<Either<String, Map<String, int>>> call(NoParams params) async {
    try {
      final counts = await repository.getOrderCounts();
      return Right(counts);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// ================= 15. GET FARMER ORDER COUNTS USE CASE =================

class GetFarmerOrderCountsUseCase2 implements UseCase<Map<String, int>, NoParams> {
  final OrderRepository repository;

  GetFarmerOrderCountsUseCase2(this.repository);

  @override
  Future<Either<String, Map<String, int>>> call(NoParams params) async {
    try {
      final counts = await repository.getFarmerOrderCounts();
      return Right(counts);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

// ================= 16. GET ORDERS BY DATE RANGE USE CASE =================

class GetOrdersByDateRangeParams2 {
  final DateTime startDate;
  final DateTime endDate;
  final String? role; // 'buyer' or 'farmer'

  GetOrdersByDateRangeParams2({
    required this.startDate,
    required this.endDate,
    this.role,
  });
}

class GetOrdersByDateRangeUseCase2 implements UseCase<List<order_entity.Order>, GetOrdersByDateRangeParams2> {
  final OrderRepository repository;

  GetOrdersByDateRangeUseCase2(this.repository);

  @override
  Future<Either<String, List<order_entity.Order>>> call(GetOrdersByDateRangeParams2 params) async {
    try {
      final orders = await repository.getOrdersByDateRange(
        startDate: params.startDate,
        endDate: params.endDate,
        role: params.role,
      );
      return Right(orders);
    } catch (e) {
      return Left(e.toString());
    }
  }
}