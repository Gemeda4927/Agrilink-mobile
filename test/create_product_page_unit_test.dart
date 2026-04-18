import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:agrilink/features/product/presentation/create_product_page.dart';
import 'package:agrilink/features/product/presentation/bloc/product_bloc.dart';
import 'package:agrilink/features/product/presentation/bloc/product_event.dart';
import 'package:agrilink/features/product/presentation/bloc/product_state.dart';
import 'package:agrilink/features/product/domain/usecases/create_product.dart';
import 'package:agrilink/features/product/domain/usecases/get_products.dart';
import 'package:agrilink/features/product/domain/usecases/get_my_products.dart';
import 'package:agrilink/features/product/domain/usecases/get_product_by_id.dart';
import 'package:agrilink/features/product/domain/usecases/update_product.dart';
import 'package:agrilink/features/product/domain/usecases/delete_product.dart';
import 'package:agrilink/features/product/domain/usecases/get_products_by_category.dart';
import 'package:agrilink/features/product/domain/usecases/search_products.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_bloc.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_event.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_state.dart';
import 'package:agrilink/features/category/domain/usecases/get_categories.dart';
import 'package:agrilink/features/category/domain/usecases/get_subcategories.dart';

// Mock Product UseCases
class MockGetProducts extends Mock implements GetProducts {}
class MockCreateProduct extends Mock implements CreateProduct {}
class MockGetMyProductsUseCase extends Mock implements GetMyProductsUseCase {}
class MockGetProductByIdUseCase extends Mock implements GetProductByIdUseCase {}
class MockUpdateProductUseCase extends Mock implements UpdateProductUseCase {}
class MockDeleteProductUseCase extends Mock implements DeleteProductUseCase {}
class MockGetProductsByCategoryUseCase extends Mock implements GetProductsByCategoryUseCase {}
class MockSearchProductsUseCase extends Mock implements SearchProductsUseCase {}

// Mock Category UseCases
class MockGetCategories extends Mock implements GetCategories {}
class MockGetSubCategories extends Mock implements GetSubCategories {}

void main() {
  late ProductBloc productBloc;
  late CategoryBloc categoryBloc;
  
  late MockGetProducts mockGetProducts;
  late MockCreateProduct mockCreateProduct;
  late MockGetMyProductsUseCase mockGetMyProducts;
  late MockGetProductByIdUseCase mockGetProductById;
  late MockUpdateProductUseCase mockUpdateProduct;
  late MockDeleteProductUseCase mockDeleteProduct;
  late MockGetProductsByCategoryUseCase mockGetProductsByCategory;
  late MockSearchProductsUseCase mockSearchProducts;
  
  late MockGetCategories mockGetCategories;
  late MockGetSubCategories mockGetSubCategories;

  setUp(() {
    mockGetProducts = MockGetProducts();
    mockCreateProduct = MockCreateProduct();
    mockGetMyProducts = MockGetMyProductsUseCase();
    mockGetProductById = MockGetProductByIdUseCase();
    mockUpdateProduct = MockUpdateProductUseCase();
    mockDeleteProduct = MockDeleteProductUseCase();
    mockGetProductsByCategory = MockGetProductsByCategoryUseCase();
    mockSearchProducts = MockSearchProductsUseCase();
    
    mockGetCategories = MockGetCategories();
    mockGetSubCategories = MockGetSubCategories();

    productBloc = ProductBloc(
      getProducts: mockGetProducts,
      createProduct: mockCreateProduct,
      getMyProducts: mockGetMyProducts,
      getProductById: mockGetProductById,
      updateProduct: mockUpdateProduct,
      deleteProduct: mockDeleteProduct,
      getProductsByCategory: mockGetProductsByCategory,
      searchProducts: mockSearchProducts,
    );

    categoryBloc = CategoryBloc(mockGetCategories, mockGetSubCategories);
  });

  Widget createCreateProductPage() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ProductBloc>.value(value: productBloc),
          BlocProvider<CategoryBloc>.value(value: categoryBloc),
        ],
        child: const CreateProductPage(),
      ),
    );
  }

  group('CreateProductPage Unit Tests', () {
    testWidgets('1. CreateProductPage renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      expect(find.byType(CreateProductPage), findsOneWidget);
    });

    testWidgets('2. CreateProductPage has Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('3. CreateProductPage has AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('4. CreateProductPage has title "Post Product"', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      expect(find.text('Post Product'), findsOneWidget);
    });

    testWidgets('5. AppBar background is green', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, Colors.green);
    });

    testWidgets('6. CreateProductPage has SingleChildScrollView', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('7. CreateProductPage has category dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));
    });

    testWidgets('8. CreateProductPage has name TextField', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('9. CreateProductPage has amount field icon', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      expect(find.byIcon(Icons.scale), findsOneWidget);
    });

    testWidgets('10. CreateProductPage has price field icon', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      expect(find.byIcon(Icons.payments), findsOneWidget);
    });

    testWidgets('11. CreateProductPage has description field icon', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      expect(find.byIcon(Icons.notes), findsOneWidget);
    });

    testWidgets('12. CreateProductPage has inventory icon', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      expect(find.byIcon(Icons.inventory), findsOneWidget);
    });

    testWidgets('13. CreateProductPage has image picker tile', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);
    });

    testWidgets('14. CreateProductPage has upload text', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      expect(find.text('Tap to upload product image'), findsOneWidget);
    });

    testWidgets('15. CreateProductPage has review button icon', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      
      productBloc.emit(ProductInitial());
      await tester.pump();
      
      expect(find.byIcon(Icons.preview), findsOneWidget);
    });

    testWidgets('16. Review button has correct text', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      
      productBloc.emit(ProductInitial());
      await tester.pump();
      
      expect(find.text('Review & Post'), findsOneWidget);
    });

    testWidgets('17. CreateProductPage has BlocListener', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      expect(find.byType(BlocListener<CategoryBloc, CategoryState>), findsOneWidget);
    });

    testWidgets('18. CreateProductPage has BlocConsumer', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      expect(find.byType(BlocConsumer<ProductBloc, ProductState>), findsOneWidget);
    });

    testWidgets('19. CreateProductPage has Card widgets', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('20. CreateProductPage background is grey.shade50', (WidgetTester tester) async {
      await tester.pumpWidget(createCreateProductPage());
      await tester.pump();
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.grey.shade50);
    });
  });
}