import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/product/domain/entities/product_entities.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.goNamed(RouteName.productDetails, extra: product);
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                product.image,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 8),

            /// Product Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 4),

            /// Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Price: ${product.price}",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 4),

            /// Amount
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Amount: ${product.amount}",
                style: const TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
