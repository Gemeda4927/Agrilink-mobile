import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

// Load all products
class LoadProducts extends ProductEvent {
  final int? page;
  final int? limit;
  final String? category;
  final String? search;

  const LoadProducts({this.page, this.limit, this.category, this.search});

  @override
  List<Object?> get props => [page, limit, category, search];
}

// Load my products
class LoadMyProducts extends ProductEvent {
  final int? page;
  final int? limit;
  final String? status;

  const LoadMyProducts({this.page, this.limit, this.status});

  @override
  List<Object?> get props => [page, limit, status];
}

// Load product by ID
class LoadProductById extends ProductEvent {
  final String id;

  const LoadProductById(this.id);

  @override
  List<Object> get props => [id];
}

class RefreshMyProducts extends ProductEvent {
  const RefreshMyProducts();
}

// Create product
class CreateProductEvent extends ProductEvent {
  final String name;
  final int amount;
  final int price;
  final String description;
  final String subCategoryId;
  final File image;

  const CreateProductEvent({
    required this.name,
    required this.amount,
    required this.price,
    required this.description,
    required this.subCategoryId,
    required this.image,
    String? city,
    bool? withDelivery,
  });

  @override
  List<Object> get props => [
    name,
    amount,
    price,
    description,
    subCategoryId,
    image,
  ];
}

// Update product
class UpdateProductEvent extends ProductEvent {
  final String id;
  final String? name;
  final int? amount;
  final int? price;
  final String? description;
  final String? subCategoryId;
  final File? image;

  const UpdateProductEvent({
    required this.id,
    this.name,
    this.amount,
    this.price,
    this.description,
    this.subCategoryId,
    this.image,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    amount,
    price,
    description,
    subCategoryId,
    image,
  ];
}

// Delete product
class DeleteProductEvent extends ProductEvent {
  final String id;

  const DeleteProductEvent(this.id);

  @override
  List<Object> get props => [id];
}

// Load products by category
class LoadProductsByCategory extends ProductEvent {
  final String categoryId;

  const LoadProductsByCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

// Search products
class SearchProductsEvent extends ProductEvent {
  final String query;

  const SearchProductsEvent(this.query);

  @override
  List<Object> get props => [query];
}

// Reset state
class ResetProductState extends ProductEvent {
  const ResetProductState();
}
