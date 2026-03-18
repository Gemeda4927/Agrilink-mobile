import 'package:agrilink/features/product/presentation/widgets/product_action_buttons.dart';
import 'package:agrilink/features/product/presentation/widgets/product_info_section.dart';
import 'package:flutter/material.dart';
import 'package:agrilink/features/product/domain/entities/product_entities.dart';

class ProductDetailsPage extends StatelessWidget {
  final ProductEntity product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Column(
        children: [
          /// IMAGE
          SizedBox(
            height: 250,
            width: double.infinity,
            child: Image.network(product.image, fit: BoxFit.cover),
          ),

          /// PRODUCT INFO
          Expanded(
            child: SingleChildScrollView(
              child: ProductInfoSection(product: product),
            ),
          ),

          /// BUTTONS
          ProductActionButtons(product: product),
        ],
      ),
    );
  }
}
