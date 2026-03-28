import 'dart:io';

abstract class ProductEvent {}

class LoadProducts extends ProductEvent {}

class CreateProductEvent extends ProductEvent {
  final String name;
  final int amount;
  final int price;
  final String description;
  final String subCategoryId;
  final File image;

  CreateProductEvent({
    required this.name,
    required this.amount,
    required this.price,
    required this.description,
    required this.subCategoryId,
    required this.image,
  });
}
