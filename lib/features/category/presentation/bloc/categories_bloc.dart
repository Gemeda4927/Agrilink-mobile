import 'package:agrilink/features/category/domain/usecases/get_subcategories.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_event.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/entities/category.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategories getCategories;
  final GetSubCategories getSubCategories;

  List<Category> _categories = [];

  CategoryBloc(
    this.getCategories,
    this.getSubCategories,
  ) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadSubCategories>(_onLoadSubCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    try {
      final categories = await getCategories();

      _categories = categories;

      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onLoadSubCategories(
    LoadSubCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    try {
      final subCategories = await getSubCategories(event.categoryId);

      emit(SubCategoryLoaded(subCategories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}