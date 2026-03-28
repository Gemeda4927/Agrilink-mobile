import 'package:agrilink/features/product/domain/entities/product_entities.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductEntity> products;

  ProductLoaded(this.products);
}

class ProductCreating extends ProductState {}

class ProductCreated extends ProductState {}

class ProductError extends ProductState {
  final String message;

  ProductError(this.message);
}
