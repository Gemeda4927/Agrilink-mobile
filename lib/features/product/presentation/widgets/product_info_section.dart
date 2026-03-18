import 'package:flutter/material.dart';
import 'package:agrilink/features/product/domain/entities/product_entities.dart';

class ProductInfoSection extends StatelessWidget {
  final ProductEntity product;

  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            "ETB ${product.price}",
            style: const TextStyle(
              fontSize: 20,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Amount: ${product.amount}",
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 16),

          const Text(
            "Description",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(product.description, style: const TextStyle(fontSize: 15)),

          const SizedBox(height: 10),

          Text(
            "Posted: ${product.createdAt}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
