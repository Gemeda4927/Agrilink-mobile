import 'package:flutter/material.dart';
import 'package:agrilink/features/product/domain/entities/product_entities.dart';

class ProductActionButtons extends StatelessWidget {
  final ProductEntity product;

  const ProductActionButtons({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [

          /// ADD TO CART
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cart feature coming soon")),
                );
              },
              child: const Text("Add to Cart"),
            ),
          ),

          const SizedBox(width: 8),

          /// CONNECT OWNER
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Chat feature coming soon")),
                );
              },
              child: const Text("Connect Owner"),
            ),
          ),
        ],
      ),
    );
  }
}
