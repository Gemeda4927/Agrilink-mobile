import 'package:agrilink/features/category/domain/entities/category.dart';
import 'package:agrilink/features/category/domain/entities/subcategory.dart';

abstract class CategoryState {
  const CategoryState();
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;

  const CategoryLoaded(this.categories);
}

class SubCategoryLoaded extends CategoryState {
  final List<SubCategory> subCategories;

  const SubCategoryLoaded(this.subCategories);
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);
}