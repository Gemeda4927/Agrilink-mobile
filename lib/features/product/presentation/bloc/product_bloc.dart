import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/get_my_products.dart';
import '../../domain/usecases/get_product_by_id.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_products_by_category.dart';
import '../../domain/usecases/search_products.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;
  final CreateProduct createProduct;
  final GetMyProductsUseCase getMyProducts;
  final GetProductByIdUseCase getProductById;
  final UpdateProductUseCase updateProduct;
  final DeleteProductUseCase deleteProduct;
  final GetProductsByCategoryUseCase getProductsByCategory;
  final SearchProductsUseCase searchProducts;

  ProductBloc({
    required this.getProducts,
    required this.createProduct,
    required this.getMyProducts,
    required this.getProductById,
    required this.updateProduct,
    required this.deleteProduct,
    required this.getProductsByCategory,
    required this.searchProducts,
  }) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadMyProducts>(_onLoadMyProducts);
    on<LoadProductById>(_onLoadProductById);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<RefreshMyProducts>(_onRefreshMyProducts);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
    on<SearchProductsEvent>(_onSearchProducts);
    on<ResetProductState>(_onResetProductState);
  }

  // GET /product - Load all products
  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await getProducts(
      page: event.page,
      limit: event.limit,
      category: event.category,
      search: event.search,
    );

    result.fold(
      (error) => emit(ProductError(error)),
      (products) => emit(ProductLoaded(products)),
    );
  }

  // GET /product/my-products - Load my products
  Future<void> _onLoadMyProducts(
    LoadMyProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await getMyProducts(
      page: event.page,
      limit: event.limit,
      status: event.status,
    );

    result.fold(
      (error) => emit(ProductError(error)),
      (products) => emit(MyProductsLoaded(products)),
    );
  }

  // Add handler
  Future<void> _onRefreshMyProducts(
    RefreshMyProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await getMyProducts(page: 1, limit: 10);

    result.fold(
      (error) => emit(ProductError(error)),
      (products) => emit(MyProductsLoaded(products)),
    );
  }

  // GET /product/{id} - Load product by ID
  Future<void> _onLoadProductById(
    LoadProductById event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await getProductById(event.id);

    result.fold(
      (error) => emit(ProductError(error)),
      (product) => emit(ProductDetailLoaded(product)),
    );
  }

  // POST /product - Create product
  Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductCreating());

    final result = await createProduct(
      name: event.name,
      amount: event.amount,
      price: event.price,
      description: event.description,
      subCategoryId: event.subCategoryId,
      image: event.image,
    );

    result.fold(
      (error) => emit(ProductError(error)),
      (product) => emit(ProductCreated(product)),
    );
  }

  // PATCH /product/{id} - Update product
  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductUpdating());

    final result = await updateProduct(
      id: event.id,
      name: event.name,
      amount: event.amount,
      price: event.price,
      description: event.description,
      subCategoryId: event.subCategoryId,
      image: event.image,
    );

    result.fold(
      (error) => emit(ProductError(error)),
      (product) => emit(ProductUpdated(product)),
    );
  }

  // DELETE /product/{id} - Delete product
  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductDeleting());

    final result = await deleteProduct(event.id);

    result.fold(
      (error) => emit(ProductError(error)),
      (_) => emit(ProductDeleted(event.id)),
    );
  }

  // GET /product?category={id} - Load products by category
  Future<void> _onLoadProductsByCategory(
    LoadProductsByCategory event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await getProductsByCategory(event.categoryId);

    result.fold(
      (error) => emit(ProductError(error)),
      (products) => emit(ProductsByCategoryLoaded(products, event.categoryId)),
    );
  }

  // GET /product?search={query} - Search products
  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await searchProducts(event.query);

    result.fold(
      (error) => emit(ProductError(error)),
      (products) => emit(ProductSearchResults(products, event.query)),
    );
  }

  // Reset product state
  Future<void> _onResetProductState(
    ResetProductState event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductInitial());
  }
}
