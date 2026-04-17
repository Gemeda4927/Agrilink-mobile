// lib/features/product/presentation/screens/my_products_screen.dart

import 'package:agrilink/features/product/data/model/product_model.dart';
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
import '../../product/presentation/bloc/product_bloc.dart';
import 'empty_products_widget.dart';
import 'product_card.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({Key? key}) : super(key: key);

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> with SingleTickerProviderStateMixin {
  String _selectedFilter = 'All';
  String _selectedSort = 'Newest';
  
  // Search variables
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

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
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Only load more when not refreshing and not already loading
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
    _searchQuery = '';
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _isLoadingMore = false;
      _isRefreshing = true;
    });
    context.read<ProductBloc>().add(RefreshMyProducts());
    
    // Reset refreshing flag after a delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    });
  }

  void _navigateToCreateProduct() async {
    final result = await context.pushNamed(RouteName.createProduct);
    if (result == true) {
      _refreshProducts();
      _showSuccessSnackBar('Product created successfully', Icons.check_circle);
    }
  }

  void _navigateToEditProduct(String productId) async {
    final result = await context.pushNamed(
      RouteName.editProduct,
      extra: productId,
    );
    if (result == true) {
      _refreshProducts();
      _showSuccessSnackBar('Product updated successfully', Icons.update);
    }
  }

  void _deleteProduct(String productId, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Product',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this product?',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory_2, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 14)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProductBloc>().add(DeleteProductEvent(productId));
              _showInfoSnackBar('Deleting "$productName"...', Icons.hourglass_empty);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
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
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
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
                onPressed: () => _showFilterBottomSheet(context),
              ),
              const SizedBox(width: 8),
              _buildIconButton(
                icon: Icons.sort_rounded,
                color: const Color(0xFF1976D2),
                onPressed: () => _showSortBottomSheet(context),
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
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isSearching ? const Color(0xFF2E7D32) : Colors.transparent,
            width: 2,
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          onTap: () {
            setState(() {
              _isSearching = true;
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
              color: _isSearching ? const Color(0xFF2E7D32) : Colors.grey.shade500,
              size: 22,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: Colors.grey.shade600, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _isSearching = false;
                      });
                      FocusScope.of(context).unfocus();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    if (_selectedFilter == 'All' && _searchQuery.isEmpty) return const SizedBox.shrink();

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
                onRemove: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _isSearching = false;
                  });
                },
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
    return BlocConsumer<ProductBloc, ProductState>(
      listenWhen: (previous, current) =>
          current is ProductDeleted || current is ProductError,
      listener: (context, state) {
        if (state is ProductDeleted) {
          _showSuccessSnackBar('Product deleted successfully', Icons.delete_outline);
          _refreshProducts();
        }
        if (state is ProductError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          // Reset loading state on error
          setState(() {
            _isLoadingMore = false;
            _isRefreshing = false;
          });
        }
        // Reset loading state when products are loaded
        if (state is MyProductsLoaded) {
          setState(() {
            _isLoadingMore = false;
            _isRefreshing = false;
          });
        }
      },
      builder: (context, state) {
        if (state is ProductLoading && _currentPage == 1 && !_isRefreshing) {
          return _buildLoadingState();
        }

        if (state is MyProductsLoaded) {
          final products = _applyFiltersAndSort(state.products);

          if (products.isEmpty) {
            return _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? _buildNoResultsWidget()
                : EmptyProductsWidget(onAddPressed: _navigateToCreateProduct);
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refreshProducts();
              // Wait for refresh to complete
              await Future.delayed(const Duration(milliseconds: 800));
            },
            color: const Color(0xFF2E7D32),
            backgroundColor: Colors.white,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                // Prevent refresh indicator from triggering during normal scroll
                if (scrollNotification is ScrollUpdateNotification &&
                    _scrollController.position.pixels < 0) {
                  return false;
                }
                return true;
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildResultsHeader(products.length),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == products.length) {
                            if (_isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }
                          final product = products[index];
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: ProductCard(
                              product: product,
                              onEdit: () => _navigateToEditProduct(product.id),
                              onDelete: () => _deleteProduct(product.id, product.name),
                            ),
                          );
                        },
                        childCount: products.length + (_isLoadingMore ? 1 : 0),
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                    ),
                  ),
                ],
              ),
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
                child: const Icon(Icons.inventory_2, color: Color(0xFF2E7D32), size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                '$count ${count == 1 ? 'Product' : 'Products'}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          if (_selectedSort != 'Newest')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sort_rounded, size: 14, color: Color(0xFF1976D2)),
                  const SizedBox(width: 4),
                  Text(
                    _selectedSort,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading products...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.filter_alt_off_rounded,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Products Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'Try changing your filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedFilter = 'All';
                  _searchQuery = '';
                  _searchController.clear();
                  _isSearching = false;
                });
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Clear Filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
                side: const BorderSide(color: Color(0xFF2E7D32)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<ProductModel> _applyFiltersAndSort(List<ProductModel> products) {
    List<ProductModel> filtered = List.from(products);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply filters
    switch (_selectedFilter) {
      case 'Available':
        filtered = filtered.where((p) => p.amount > 0).toList();
        break;
      case 'Low Stock':
        filtered = filtered.where((p) => p.amount < 10 && p.amount > 0).toList();
        break;
      case 'Out of Stock':
        filtered = filtered.where((p) => p.amount == 0).toList();
        break;
      default:
        break;
    }

    // Apply sorting
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

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
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
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: Colors.grey.shade600),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFilterOption(
                    'All Products',
                    Icons.grid_view_rounded,
                    Colors.grey.shade700,
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
                      setStateBottomSheet(() => _selectedFilter = 'Out of Stock');
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
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
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: Colors.grey.shade600),
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
                      setStateBottomSheet(() => _selectedSort = 'Price: Low to High');
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
                      setStateBottomSheet(() => _selectedSort = 'Price: High to Low');
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
                      setStateBottomSheet(() => _selectedSort = 'Stock: Low to High');
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
                      setStateBottomSheet(() => _selectedSort = 'Stock: High to Low');
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
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
            : Icon(Icons.circle_outlined, color: Colors.grey.shade300, size: 24),
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
            : Icon(Icons.circle_outlined, color: Colors.grey.shade300, size: 24),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something Went Wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshProducts,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}