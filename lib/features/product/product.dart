import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_event.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_state.dart';
import 'package:agrilink/features/product/presentation/bloc/product_bloc.dart';
import 'package:agrilink/features/product/presentation/bloc/product_event.dart';
import 'package:agrilink/features/product/presentation/bloc/product_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProducts());
    context.read<CartBloc>().add(LoadCart());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              int cartItemCount = 0;
              if (cartState is CartLoaded) {
                cartItemCount = cartState.totalItems;
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => context.push(RouteName.cart),
                  ),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          cartItemCount > 99 ? '99+' : '$cartItemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),

      /// BODY
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 60, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(state.message),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(LoadProducts());
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (state is ProductLoaded) {
            final products = state.products;

            if (products.isEmpty) {
              return const Center(child: Text("No products available"));
            }

            /// ✅ CLEAN GRID
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,

                /// 🔥 IMPORTANT (FIX OVERFLOW)
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final product = products[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    context.goNamed(
                      RouteName.productDetails,
                      extra: product,
                    );
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// IMAGE
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                product.image,
                                height: 110,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 110,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image),
                                ),
                              ),
                            ),

                            /// ADD BUTTON
                            Positioned(
                              bottom: 6,
                              right: 6,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.add_shopping_cart,
                                    size: 18,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    _showAddToCartDialog(context, product);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        /// INFO
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /// NAME
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),

                                /// PRICE
                                Text(
                                  "ETB ${product.price}",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                /// STOCK
                                Text(
                                  "Stock: ${product.amount}",
                                  style: const TextStyle(fontSize: 11),
                                ),

                                /// FARMER
                                if (product.farmerEmail != null)
                                  GestureDetector(
                                    onTap: () {
                                      context.goNamed(
                                        RouteName.farmerProfile,
                                        extra: product.farmerId,
                                      );
                                    },
                                    child: Text(
                                      product.farmerEmail!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  /// ================= DIALOG =================
  void _showAddToCartDialog(BuildContext context, dynamic product) {
    int quantity = 1;
    final price = double.tryParse(product.price) ?? 0.0;
    final maxStock = product.amount;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add to Cart'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Price: ETB ${product.price}"),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() => quantity--);
                        }
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Text(quantity.toString()),
                    IconButton(
                      onPressed: () {
                        if (quantity < maxStock) {
                          setState(() => quantity++);
                        }
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

                Text(
                  "Total: ETB ${(price * quantity).toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addToCart(context, product.id, quantity);
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addToCart(BuildContext context, String productId, int amount) {
    context.read<CartBloc>().add(
          AddToCart(productId: productId, amount: amount),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $amount item(s)'),
        backgroundColor: Colors.green,
      ),
    );
  }
}