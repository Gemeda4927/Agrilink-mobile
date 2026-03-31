import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProductDetailsPage extends StatelessWidget {
  final dynamic product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final priceValue = double.tryParse(product.price) ?? 0.0;
    final isCheap = priceValue <= 10000;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      /// 🔥 APP BAR
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(RouteName.product),
        ),
        title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,

        actions: [
          if (isCheap)
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => context.push(RouteName.cart),
            ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              child: Image.network(
                product.image,
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 260,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 60),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NAME
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// INFO CARD
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        /// PRICE
                        Row(
                          children: [
                            const Icon(Icons.payments, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text(
                              "Price:",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${product.price} ETB",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// AMOUNT
                        Row(
                          children: [
                            const Icon(Icons.inventory_2, color: Colors.grey),
                            const SizedBox(width: 8),
                            const Text(
                              "Amount:",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 6),
                            Text("${product.amount} kg"),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// OWNER
                        if (product.farmerEmail != null)
                          GestureDetector(
                            onTap: () {
                              context.goNamed(
                                RouteName.farmerProfile,
                                extra: product.farmerId,
                              );
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.person, color: Colors.orange),
                                const SizedBox(width: 8),
                                const Text(
                                  "Owner:",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    product.farmerEmail!,
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// DESCRIPTION
                  if (product.description != null &&
                      product.description.toString().trim().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.description, color: Colors.green),
                              SizedBox(width: 6),
                              Text(
                                "Description",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  /// ACTION BUTTONS
                  Row(
                    children: [
                      if (isCheap)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showModernCartSheet(context, product);
                            },
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text("Add to Cart"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                      if (isCheap) const SizedBox(width: 10),

                      /// 💬 CHAT BUTTON (BLUE)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _goToFarmer(context, product);
                          },
                          icon: const Icon(Icons.chat),
                          label: const Text("Chat"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 MODERN ADD TO CART (BOTTOM SHEET)
  void _showModernCartSheet(BuildContext context, dynamic product) {
    int quantity = 1;
    final price = double.tryParse(product.price) ?? 0.0;
    final maxAmount = product.amount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// HANDLE BAR
                Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                Text("${product.price} ETB"),

                const SizedBox(height: 16),

                /// QUANTITY STEPPER
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _circleBtn(Icons.remove, () {
                      if (quantity > 1) setState(() => quantity--);
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "$quantity",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _circleBtn(Icons.add, () {
                      if (quantity < maxAmount) setState(() => quantity++);
                    }),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  "Total: ${(price * quantity).toStringAsFixed(2)} ETB",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                /// ADD BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<CartBloc>().add(
                        AddToCart(productId: product.id, amount: quantity),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added $quantity item(s) to cart'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Add to Cart"),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        shape: BoxShape.circle,
      ),
      child: IconButton(icon: Icon(icon), onPressed: onTap),
    );
  }

  void _goToFarmer(BuildContext context, dynamic product) {
    context.goNamed(RouteName.farmerProfile, extra: product.farmerId);
  }
}
