import 'package:agrilink/features/cart/data/models/CartItemModel.dart';
import 'package:agrilink/features/cart/data/service/cart_service.dart';
import 'package:agrilink/features/cart/domain/entity/cart_item.dart';
import 'package:agrilink/features/cart/domain/repositories/cart_repository.dart';
import 'package:agrilink/features/product/domain/entities/product_entities.dart';

class CartRepositoryImpl implements CartRepository {
  final CartService service;

  CartRepositoryImpl(this.service);

  @override
  Future<List<CartItem>> getCart() async {
    final response = await service.getCart();

    return (response.data as List).map((e) {
      final model = CartItemModel.fromJson(e);

      return CartItem(
        id: model.id,
        productId: model.productId,
        amount: model.amount,
        product: ProductEntity(
          id: model.product.id,
          farmerId: model.product.farmerId,
          name: model.product.name,
          subCategoryId: model.product.subCategoryId,
          amount: model.product.amount,
          price: model.product.price,
          description: model.product.description,
          image: model.product.image,
          createdAt: model.product.createdAt,
          subCategoryName: model.product.subCategoryName,
          categoryId: model.product.categoryId,
          farmerEmail: model.product.farmerEmail,
          farmerPhone: model.product.farmerPhone,
          farmerRole: model.product.farmerRole,
        ),
      );
    }).toList();
  }

  @override
  Future<CartItem> addToCart(String productId, int amount) async {
    final response = await service.addToCart(
      productId: productId,
      amount: amount,
    );

    final model = CartItemModel.fromJson(response.data);

    return CartItem(
      id: model.id,
      productId: model.productId,
      amount: model.amount,
      product: ProductEntity(
        id: model.product.id,
        farmerId: model.product.farmerId,
        name: model.product.name,
        subCategoryId: model.product.subCategoryId,
        amount: model.product.amount,
        price: model.product.price,
        description: model.product.description,
        image: model.product.image,
        createdAt: model.product.createdAt,
        subCategoryName: model.product.subCategoryName,
        categoryId: model.product.categoryId,
        farmerEmail: model.product.farmerEmail,
        farmerPhone: model.product.farmerPhone,
        farmerRole: model.product.farmerRole,
      ),
    );
  }

  @override
  Future<CartItem> updateCart(String productId, int amount) async {
    final response = await service.updateCart(
      productId: productId,
      amount: amount,
    );

    final model = CartItemModel.fromJson(response.data);

    return CartItem(
      id: model.id,
      productId: model.productId,
      amount: model.amount,
      product: ProductEntity(
        id: model.product.id,
        farmerId: model.product.farmerId,
        name: model.product.name,
        subCategoryId: model.product.subCategoryId,
        amount: model.product.amount,
        price: model.product.price,
        description: model.product.description,
        image: model.product.image,
        createdAt: model.product.createdAt,
        subCategoryName: model.product.subCategoryName,
        categoryId: model.product.categoryId,
        farmerEmail: model.product.farmerEmail,
        farmerPhone: model.product.farmerPhone,
        farmerRole: model.product.farmerRole,
      ),
    );
  }

  @override
  Future<void> removeItem(String productId) async {
    await service.removeItem(productId);
  }
}
