import 'package:flutter/material.dart';

import '../../product/domain/entities/product_entities.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [_buildImageSection(), _buildContentSection()],
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        height: 90,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            product.hasImage
                ? Image.network(
                    product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildLoadingImage();
                    },
                  )
                : _buildPlaceholderImage(),
            Positioned(top: 6, right: 6, child: _buildStockBadge()),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 30,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF2E7D32),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product Name
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              product.getCategoryDisplay(),
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),

          // Price and Stock row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.payments_rounded,
                      size: 11,
                      color: const Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Stock Info
              _buildStockInfo(),
            ],
          ),
          const SizedBox(height: 4),

          // Delivery Badge (optional)
          if (product.withDelivery == true)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.local_shipping_rounded,
                    size: 8,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Delivery',
                    style: TextStyle(fontSize: 8, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStockInfo() {
    final stockColor = product.amount == 0
        ? const Color(0xFFD32F2F)
        : product.amount < 10
        ? const Color(0xFFF57C00)
        : const Color(0xFF2E7D32);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          product.amount == 0
              ? Icons.inventory_2_outlined
              : Icons.inventory_rounded,
          size: 10,
          color: stockColor,
        ),
        const SizedBox(width: 2),
        Text(
          product.formattedAmount,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: stockColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStockBadge() {
    Color backgroundColor;
    String text;

    if (product.amount == 0) {
      backgroundColor = const Color(0xFFD32F2F);
      text = 'Out';
    } else if (product.amount < 10) {
      backgroundColor = const Color(0xFFF57C00);
      text = 'Low';
    } else {
      backgroundColor = const Color(0xFF2E7D32);
      text = 'In';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF1976D2),
                      size: 11,
                    ),
                    SizedBox(width: 2),
                    Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFD32F2F),
                      size: 11,
                    ),
                    SizedBox(width: 2),
                    Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
