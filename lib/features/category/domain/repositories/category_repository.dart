import 'package:agrilink/features/category/domain/entities/subcategory.dart';

import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<List<SubCategory>> getSubCategories(String categoryId);
}
