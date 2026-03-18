import 'package:agrilink/features/product/data/model/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts();
}
