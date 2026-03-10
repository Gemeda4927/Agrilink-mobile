import 'package:agrilink/features/category/data/model/category_model.dart';
import 'package:agrilink/features/category/data/model/subcategory_model.dart';
import 'package:agrilink/features/category/data/service/category_service.dart';
import 'package:agrilink/features/category/domain/entities/category.dart';
import 'package:agrilink/features/category/domain/entities/subcategory.dart';
import 'package:agrilink/features/category/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryService service;

  CategoryRepositoryImpl({required this.service});

  @override
  Future<List<Category>> getCategories() async {
    final response = await service.getCategories();

    print("📦 Categories API response: $response");

    final models =
        response.map((json) => CategoryModel.fromJson(json)).toList();

    for (var m in models) {
      print("📁 Category -> ${m.name} : ${m.id}");
    }

    return models
        .map((model) => Category(id: model.id, name: model.name))
        .toList();
  }

  @override
  Future<List<SubCategory>> getSubCategories(String categoryId) async {
    final response = await service.getSubCategories();

    print("📦 SubCategory API response: $response");
    print("🟢 Selected CategoryId: $categoryId");

    final models =
        response.map((json) => SubCategoryModel.fromJson(json)).toList();

    for (var m in models) {
      print("🔹 SubCategory -> ${m.name} | categoryId: ${m.categoryId}");
    }

    /// Filter
    final filtered = models.where((model) {
      final match = model.categoryId.trim() == categoryId.trim();
      print(
          "🔍 Compare ${model.categoryId} == $categoryId -> $match");
      return match;
    }).toList();

    print("✅ Filtered SubCategories count: ${filtered.length}");

    return filtered
        .map(
          (model) => SubCategory(
            id: model.id,
            name: model.name,
            categoryId: model.categoryId,
          ),
        )
        .toList();
  }
}