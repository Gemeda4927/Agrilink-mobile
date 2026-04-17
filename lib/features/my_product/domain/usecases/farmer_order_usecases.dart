// lib/features/order/domain/usecases/farmer_order_usecases.dart

import 'package:dartz/dartz.dart';
import '../entities/farmer_order.dart';
import '../repositories/i_farmer_order_repository.dart';

// ================= FAILURE CLASS =================
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure(super.message);
}

// ================= BASE USE CASE =================
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}

// ================= 1. GET FARMER ORDERS USE CASE =================
class GetFarmerOrdersUseCase implements UseCase<List<FarmerOrder>, NoParams> {
  final IFarmerOrderRepository repository;

  GetFarmerOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<FarmerOrder>>> call(NoParams params) async {
    try {
      final orders = await repository.getFarmerOrders();
      return Right(orders);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error.toString().contains('Network')) {
      return NetworkFailure(
        'Network connection failed. Please check your internet.',
      );
    }
    return ServerFailure(error.toString());
  }
}

// ================= 2. GET PENDING FARMER ORDERS USE CASE =================
class GetPendingFarmerOrdersUseCase
    implements UseCase<List<FarmerOrder>, NoParams> {
  final IFarmerOrderRepository repository;

  GetPendingFarmerOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<FarmerOrder>>> call(NoParams params) async {
    try {
      final orders = await repository.getPendingFarmerOrders();
      return Right(orders);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error.toString().contains('Network')) {
      return NetworkFailure(
        'Network connection failed. Please check your internet.',
      );
    }
    return ServerFailure(error.toString());
  }
}

// ================= 3. GET FARMER ORDER BY ID USE CASE =================
class GetFarmerOrderByIdUseCase implements UseCase<FarmerOrder, String> {
  final IFarmerOrderRepository repository;

  GetFarmerOrderByIdUseCase(this.repository);

  @override
  Future<Either<Failure, FarmerOrder>> call(String orderId) async {
    try {
      final order = await repository.getFarmerOrderById(orderId);
      return Right(order);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error.toString().contains('Network')) {
      return NetworkFailure(
        'Network connection failed. Please check your internet.',
      );
    }
    if (error.toString().contains('404')) {
      return ServerFailure('Order not found.');
    }
    return ServerFailure(error.toString());
  }
}

// ================= 4. UPDATE ORDER STATUS USE CASE =================
class UpdateOrderStatusParams {
  final String orderId;
  final String status;

  UpdateOrderStatusParams({required this.orderId, required this.status});
}

class UpdateOrderStatusUseCase
    implements UseCase<void, UpdateOrderStatusParams> {
  final IFarmerOrderRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateOrderStatusParams params) async {
    try {
      await repository.updateOrderStatus(params.orderId, params.status);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error.toString().contains('Network')) {
      return NetworkFailure(
        'Network connection failed. Please check your internet.',
      );
    }
    return ServerFailure(error.toString());
  }
}

// ================= 5. CONFIRM ORDER USE CASE =================
class ConfirmOrderUseCase implements UseCase<void, String> {
  final IFarmerOrderRepository repository;

  ConfirmOrderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String orderId) async {
    try {
      await repository.confirmOrder(orderId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error.toString().contains('Network')) {
      return NetworkFailure(
        'Network connection failed. Please check your internet.',
      );
    }
    return ServerFailure(error.toString());
  }
}

// ================= 6. MARK AS SHIPPED USE CASE =================
class MarkAsShippedUseCase implements UseCase<void, String> {
  final IFarmerOrderRepository repository;

  MarkAsShippedUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String orderId) async {
    try {
      await repository.markAsShipped(orderId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error.toString().contains('Network')) {
      return NetworkFailure(
        'Network connection failed. Please check your internet.',
      );
    }
    return ServerFailure(error.toString());
  }
}

// ================= 7. MARK AS DELIVERED USE CASE =================
class MarkAsDeliveredUseCase implements UseCase<void, String> {
  final IFarmerOrderRepository repository;

  MarkAsDeliveredUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String orderId) async {
    try {
      await repository.markAsDelivered(orderId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error.toString().contains('Network')) {
      return NetworkFailure(
        'Network connection failed. Please check your internet.',
      );
    }
    return ServerFailure(error.toString());
  }
}
