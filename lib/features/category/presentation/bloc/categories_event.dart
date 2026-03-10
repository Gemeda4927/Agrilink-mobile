abstract class CategoryEvent {
  const CategoryEvent();
}

class LoadCategories extends CategoryEvent {}

class LoadSubCategories extends CategoryEvent {
  final String categoryId;

  const LoadSubCategories(this.categoryId);
}