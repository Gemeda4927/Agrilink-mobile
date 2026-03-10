class SubCategoryModel {
  final String id;
  final String name;
  final String categoryId;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.categoryId,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      categoryId: json['categoryId'] ?? '',
    );
  }
}