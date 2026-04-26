import 'dart:async';

import 'package:agrilink/features/my_product/presentation/bloc/farmer_order_bloc.dart';
import 'package:agrilink/features/my_product/presentation/bloc/farmer_order_events.dart';
import 'package:agrilink/features/my_product/presentation/bloc/farmer_order_state.dart';
import 'package:agrilink/features/my_product/presentation/product_detail_screen.dart';
import 'package:agrilink/features/product/presentation/bloc/product_event.dart';
import 'package:agrilink/features/product/presentation/bloc/product_state.dart'
    show
        ProductState,
        ProductDeleted,
        ProductError,
        ProductLoading,
        MyProductsLoaded;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:go_router/go_router.dart';
import '../../product/domain/entities/product_entities.dart';
import '../../product/presentation/bloc/product_bloc.dart';
import 'empty_products_widget.dart';
import 'product_card.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({Key? key}) : super(key: key);

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'All';
  String _selectedSort = 'Newest';

  // Search variables
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String _searchQuery = '';
  List<ProductEntity> _filteredProducts = [];

  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Debounce for search
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadProducts();
    _animationController.forward();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        _hasMore &&
        !_isRefreshing) {
      _loadMoreProducts();
    }
  }

  void _loadProducts() {
    _currentPage = 1;
    _hasMore = true;
    context.read<ProductBloc>().add(
      LoadMyProducts(page: _currentPage, limit: _itemsPerPage),
    );
  }

  void _loadMoreProducts() {
    if (!_isLoadingMore && _hasMore && !_isRefreshing) {
      setState(() {
        _isLoadingMore = true;
      });
      _currentPage++;
      context.read<ProductBloc>().add(
        LoadMyProducts(page: _currentPage, limit: _itemsPerPage),
      );
    }
  }

  void _refreshProducts() {
    _currentPage = 1;
    _hasMore = true;
    setState(() {
      _isLoadingMore = false;
      _isRefreshing = true;
    });
    context.read<ProductBloc>().add(RefreshMyProducts());
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery = '';
    setState(() {
      _isSearching = false;
    });
    FocusScope.of(context).unfocus();
  }

  void _navigateToCreateProduct() async {
    final result = await context.pushNamed(RouteName.createProduct);
    if (result == true) {
      _refreshProducts();
      _showSuccessSnackBar('Product created successfully', Icons.check_circle);
    }
  }

  void _navigateToProductDetail(ProductEntity product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  // Edit product dialog
  void _showEditProductDialog(ProductEntity product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price);
    final amountController = TextEditingController(
      text: product.amount.toString(),
    );
    final descriptionController = TextEditingController(
      text: product.description,
    );
    final cityController = TextEditingController(text: product.city ?? '');
    bool withDelivery = product.withDelivery ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Edit Product'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price (ETB)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Stock Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'City (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: withDelivery,
                        onChanged: (value) {
                          setStateDialog(() {
                            withDelivery = value ?? false;
                          });
                        },
                      ),
                      const Text('Available for Delivery'),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _updateProduct(
                    productId: product.id,
                    name: nameController.text,
                    price: priceController.text,
                    amount:
                        int.tryParse(amountController.text) ?? product.amount,
                    description: descriptionController.text,
                    city: cityController.text.isEmpty
                        ? null
                        : cityController.text,
                    withDelivery: withDelivery,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                ),
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _updateProduct({
    required String productId,
    required String name,
    required String price,
    required int amount,
    required String description,
    String? city,
    required bool withDelivery,
  }) {
    context.read<FarmerOrderBloc>().add(
      PatchProductEvent(
        productId: productId,
        name: name,
        price: double.tryParse(price) ?? double.parse(price),
        amount: amount,
        description: description,
        city: city,
        withDelivery: withDelivery,
      ),
    );
    _showInfoSnackBar('Updating product...', Icons.update);
  }

  void _deleteProduct(String productId, String productName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Deleting product...')),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
    context.read<ProductBloc>().add(DeleteProductEvent(productId));
  }

  void _showSuccessSnackBar(String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInfoSnackBar(String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProductBloc, ProductState>(
          listenWhen: (previous, current) =>
              current is ProductDeleted || current is ProductError,
          listener: (context, state) {
            if (state is ProductDeleted) {
              _showSuccessSnackBar(
                'Product deleted successfully',
                Icons.check_circle,
              );
              _refreshProducts();
            }
            if (state is ProductError) {
              _handleProductError(state.message);
            }
            if (state is MyProductsLoaded) {
              setState(() {
                _isLoadingMore = false;
                _isRefreshing = false;
              });
            }
          },
        ),
        BlocListener<FarmerOrderBloc, FarmerOrderState>(
          listenWhen: (previous, current) =>
              current is ProductPatched || current is FarmerOrderError,
          listener: (context, state) {
            if (state is ProductPatched) {
              _showSuccessSnackBar(
                'Product updated successfully',
                Icons.check_circle,
              );
              _refreshProducts();
            }
            if (state is FarmerOrderError) {
              _handleProductError(state.message);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildSearchBar(),
              _buildFilterChips(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  void _handleProductError(String message) {
    String userFriendlyMessage;
    IconData icon;
    Color color;

    if (message.contains('500') || message.contains('Internal server error')) {
      userFriendlyMessage = 'Server error. Please try again later.';
      icon = Icons.error;
      color = Colors.red;
    } else if (message.contains('400') || message.contains('not found')) {
      userFriendlyMessage =
          'Product not found. It may have been already deleted.';
      icon = Icons.search_off;
      color = Colors.orange;
      _refreshProducts();
    } else if (message.contains('401') || message.contains('403')) {
      userFriendlyMessage =
          'You don\'t have permission to perform this action.';
      icon = Icons.lock;
      color = Colors.red;
    } else if (message.contains('Network')) {
      userFriendlyMessage = 'Network error. Check your internet connection.';
      icon = Icons.wifi_off;
      color = Colors.orange;
    } else {
      userFriendlyMessage = 'Something went wrong. Please try again.';
      icon = Icons.error_outline;
      color = Colors.red;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(userFriendlyMessage)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );

    setState(() {
      _isLoadingMore = false;
      _isRefreshing = false;
    });
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Products',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your inventory',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildIconButton(
                icon: Icons.filter_list_rounded,
                color: const Color(0xFF2E7D32),
                badge: _selectedFilter != 'All',
                onPressed: () => _showFilterBottomSheet(),
              ),
              const SizedBox(width: 8),
              _buildIconButton(
                icon: Icons.sort_rounded,
                color: const Color(0xFF1976D2),
                badge: _selectedSort != 'Newest',
                onPressed: () => _showSortBottomSheet(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    bool badge = false,
    required VoidCallback onPressed,
  }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(icon, color: color, size: 22),
            onPressed: onPressed,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ),
        if (badge)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _isSearching ? Colors.white : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isSearching ? const Color(0xFF2E7D32) : Colors.transparent,
            width: 2,
          ),
          boxShadow: _isSearching
              ? [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onTap: () {
            setState(() {
              _isSearching = true;
            });
          },
          onSubmitted: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search products by name...',
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _isSearching
                  ? const Color(0xFF2E7D32)
                  : Colors.grey.shade500,
              size: 22,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    if (_selectedFilter == 'All' && _searchQuery.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_searchQuery.isNotEmpty)
              _buildActiveChip(
                label: 'Search: "$_searchQuery"',
                icon: Icons.search_rounded,
                color: const Color(0xFF1976D2),
                onRemove: _clearSearch,
              ),
            if (_selectedFilter != 'All') ...[
              if (_searchQuery.isNotEmpty) const SizedBox(width: 8),
              _buildActiveChip(
                label: _selectedFilter,
                icon: _getFilterIcon(_selectedFilter),
                color: _getFilterColor(_selectedFilter),
                onRemove: () {
                  setState(() {
                    _selectedFilter = 'All';
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 16, color: color),
          ),
        ],
      ),
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'Available':
        return Icons.check_circle_rounded;
      case 'Low Stock':
        return Icons.warning_rounded;
      case 'Out of Stock':
        return Icons.remove_shopping_cart_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'Available':
        return const Color(0xFF2E7D32);
      case 'Low Stock':
        return const Color(0xFFF57C00);
      case 'Out of Stock':
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }

  Widget _buildBody() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading && _currentPage == 1 && !_isRefreshing) {
          return _buildLoadingState();
        }

        if (state is MyProductsLoaded) {
          final products = _applyFiltersAndSort(state.products);
          _filteredProducts = products;

          if (products.isEmpty) {
            if (_searchQuery.isNotEmpty || _selectedFilter != 'All') {
              return _buildNoResultsWidget();
            }
            return EmptyProductsWidget(onAddPressed: _navigateToCreateProduct);
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refreshProducts();
              await Future.delayed(const Duration(milliseconds: 800));
            },
            color: const Color(0xFF2E7D32),
            backgroundColor: Colors.white,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildResultsHeader(products.length)),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == products.length) {
                        if (_isLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2E7D32),
                                ),
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }
                      final product = products[index];
                      return GestureDetector(
                        onTap: () => _navigateToProductDetail(product),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ProductCard(
                            product: product,
                            onEdit: () => _showEditProductDialog(product),
                            onDelete: () => _showDeleteConfirmation(
                              product.id,
                              product.name,
                              product.amount,
                            ),
                          ),
                        ),
                      );
                    }, childCount: products.length + (_isLoadingMore ? 1 : 0)),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is ProductError) {
          return _buildErrorWidget(state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showDeleteConfirmation(
    String productId,
    String productName,
    int stockCount,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.red.shade700,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delete Product?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        color: Colors.grey.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_rounded,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Stock: $stockCount units',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'This action cannot be undone. The product will be permanently deleted.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 15)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(productId, productName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete Forever', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2,
                  color: Color(0xFF2E7D32),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$count ${count == 1 ? 'Product' : 'Products'}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (_selectedSort != 'Newest' || _searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sort_rounded,
                    size: 14,
                    color: Color(0xFF1976D2),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _selectedSort != 'Newest' ? _selectedSort : 'Filtered',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF2E7D32)),
          SizedBox(height: 24),
          Text('Loading products...'),
        ],
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _searchQuery.isNotEmpty
                    ? Icons.search_off_rounded
                    : Icons.filter_alt_off_rounded,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No Products Found'
                  : 'No Products Match Filters',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try different search terms or clear the search'
                  : 'Try changing your filters to see more products',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedFilter = 'All';
                  _clearSearch();
                });
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Clear All Filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
                side: const BorderSide(color: Color(0xFF2E7D32)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToCreateProduct,
      backgroundColor: const Color(0xFF2E7D32),
      elevation: 4,
      icon: const Icon(Icons.add_rounded, size: 24),
      label: const Text(
        'Add Product',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  List<ProductEntity> _applyFiltersAndSort(List<ProductEntity> products) {
    List<ProductEntity> filtered = List.from(products);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    switch (_selectedFilter) {
      case 'Available':
        filtered = filtered.where((p) => p.amount > 0).toList();
        break;
      case 'Low Stock':
        filtered = filtered
            .where((p) => p.amount < 10 && p.amount > 0)
            .toList();
        break;
      case 'Out of Stock':
        filtered = filtered.where((p) => p.amount == 0).toList();
        break;
    }

    switch (_selectedSort) {
      case 'Newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'Price: Low to High':
        filtered.sort(
          (a, b) => int.parse(a.price).compareTo(int.parse(b.price)),
        );
        break;
      case 'Price: High to Low':
        filtered.sort(
          (a, b) => int.parse(b.price).compareTo(int.parse(a.price)),
        );
        break;
      case 'Stock: Low to High':
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'Stock: High to Low':
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'Name: A to Z':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Name: Z to A':
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
    }

    return filtered;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Products',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFilterOption(
                    'All Products',
                    Icons.grid_view_rounded,
                    Colors.grey,
                    _selectedFilter == 'All',
                    () {
                      setStateBottomSheet(() => _selectedFilter = 'All');
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  _buildFilterOption(
                    'Available',
                    Icons.check_circle_rounded,
                    const Color(0xFF2E7D32),
                    _selectedFilter == 'Available',
                    () {
                      setStateBottomSheet(() => _selectedFilter = 'Available');
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  _buildFilterOption(
                    'Low Stock',
                    Icons.warning_rounded,
                    const Color(0xFFF57C00),
                    _selectedFilter == 'Low Stock',
                    () {
                      setStateBottomSheet(() => _selectedFilter = 'Low Stock');
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  _buildFilterOption(
                    'Out of Stock',
                    Icons.remove_shopping_cart_rounded,
                    const Color(0xFFD32F2F),
                    _selectedFilter == 'Out of Stock',
                    () {
                      setStateBottomSheet(
                        () => _selectedFilter = 'Out of Stock',
                      );
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sort Products',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSortOption(
                    'Newest First',
                    Icons.fiber_new_rounded,
                    const Color(0xFF1976D2),
                    _selectedSort == 'Newest',
                    () {
                      setStateBottomSheet(() => _selectedSort = 'Newest');
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  _buildSortOption(
                    'Oldest First',
                    Icons.history_rounded,
                    const Color(0xFF7B1FA2),
                    _selectedSort == 'Oldest',
                    () {
                      setStateBottomSheet(() => _selectedSort = 'Oldest');
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  _buildSortOption(
                    'Name: A to Z',
                    Icons.sort_by_alpha_rounded,
                    const Color(0xFF00796B),
                    _selectedSort == 'Name: A to Z',
                    () {
                      setStateBottomSheet(() => _selectedSort = 'Name: A to Z');
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  _buildSortOption(
                    'Name: Z to A',
                    Icons.sort_by_alpha_rounded,
                    const Color(0xFF00796B),
                    _selectedSort == 'Name: Z to A',
                    () {
                      setStateBottomSheet(() => _selectedSort = 'Name: Z to A');
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  _buildSortOption(
                    'Price: Low to High',
                    Icons.trending_up_rounded,
                    const Color(0xFF2E7D32),
                    _selectedSort == 'Price: Low to High',
                    () {
                      setStateBottomSheet(
                        () => _selectedSort = 'Price: Low to High',
                      );
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  _buildSortOption(
                    'Price: High to Low',
                    Icons.trending_down_rounded,
                    const Color(0xFFF57C00),
                    _selectedSort == 'Price: High to Low',
                    () {
                      setStateBottomSheet(
                        () => _selectedSort = 'Price: High to Low',
                      );
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  _buildSortOption(
                    'Stock: Low to High',
                    Icons.inventory_rounded,
                    const Color(0xFFD32F2F),
                    _selectedSort == 'Stock: Low to High',
                    () {
                      setStateBottomSheet(
                        () => _selectedSort = 'Stock: Low to High',
                      );
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  _buildSortOption(
                    'Stock: High to Low',
                    Icons.inventory_2_rounded,
                    const Color(0xFF0097A7),
                    _selectedSort == 'Stock: High to Low',
                    () {
                      setStateBottomSheet(
                        () => _selectedSort = 'Stock: High to Low',
                      );
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption(
    String title,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? color : const Color(0xFF1A1A1A),
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded, color: color, size: 24)
            : Icon(
                Icons.circle_outlined,
                color: Colors.grey.shade300,
                size: 24,
              ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSortOption(
    String title,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? color : const Color(0xFF1A1A1A),
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded, color: color, size: 24)
            : Icon(
                Icons.circle_outlined,
                color: Colors.grey.shade300,
                size: 24,
              ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    String userFriendlyMessage;
    if (message.contains('500') || message.contains('Internal server error')) {
      userFriendlyMessage = 'Server error. Please try again later.';
    } else if (message.contains('Network')) {
      userFriendlyMessage = 'Network error. Check your internet connection.';
    } else if (message.contains('400')) {
      userFriendlyMessage = 'Invalid request. Please refresh and try again.';
    } else {
      userFriendlyMessage = message;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 500, // Limit height
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 50,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Something Went Wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  userFriendlyMessage,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _refreshProducts,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
