import '../entities/subcategory.dart';
import '../repositories/category_repository.dart';

class GetSubCategories {
  final CategoryRepository repository;

  GetSubCategories(this.repository);

  Future<List<SubCategory>> call(String categoryId) async {
    return await repository.getSubCategories(categoryId);
  }
}