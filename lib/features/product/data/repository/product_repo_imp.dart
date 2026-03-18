import 'package:agrilink/features/product/data/model/product_model.dart';
import 'package:agrilink/features/product/data/services/product_service.dart';
import 'package:agrilink/features/product/domain/repository/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductService productService;

  ProductRepositoryImpl(this.productService);

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await productService.getProducts();

    return response.map((json) => ProductModel.fromJson(json)).toList();
  }
}
