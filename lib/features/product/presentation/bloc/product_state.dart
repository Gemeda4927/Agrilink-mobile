import 'package:equatable/equatable.dart';
import '../../data/model/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

// Loaded states
class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  final int? totalCount;

  const ProductLoaded(this.products, {this.totalCount});

  @override
  List<Object?> get props => [products, totalCount];
}

class MyProductsLoaded extends ProductState {
  final List<ProductModel> products;

  const MyProductsLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class ProductDetailLoaded extends ProductState {
  final ProductModel product;

  const ProductDetailLoaded(this.product);

  @override
  List<Object> get props => [product];
}

// CRUD states
class ProductCreating extends ProductState {}

class ProductCreated extends ProductState {
  final ProductModel product;

  const ProductCreated(this.product);

  @override
  List<Object> get props => [product];
}

class ProductUpdating extends ProductState {}

class ProductUpdated extends ProductState {
  final ProductModel product;

  const ProductUpdated(this.product);

  @override
  List<Object> get props => [product];
}

class ProductDeleting extends ProductState {}

class ProductDeleted extends ProductState {
  final String productId;

  const ProductDeleted(this.productId);

  @override
  List<Object> get props => [productId];
}

// Filtered states
class ProductsByCategoryLoaded extends ProductState {
  final List<ProductModel> products;
  final String categoryId;

  const ProductsByCategoryLoaded(this.products, this.categoryId);

  @override
  List<Object> get props => [products, categoryId];
}

class ProductSearchResults extends ProductState {
  final List<ProductModel> products;
  final String query;

  const ProductSearchResults(this.products, this.query);

  @override
  List<Object> get props => [products, query];
}

// Error state
class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}