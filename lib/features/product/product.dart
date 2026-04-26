import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/core/localization/generated/app_localizations.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_event.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_state.dart';
import 'package:agrilink/features/product/data/model/product_model.dart';
import 'package:agrilink/features/product/presentation/bloc/product_bloc.dart';
import 'package:agrilink/features/product/presentation/bloc/product_event.dart';
import 'package:agrilink/features/product/presentation/bloc/product_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // Search and Filter Controllers
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'name'; // name, price_asc, price_desc
  String _selectedCategory = 'All';

  // Pagination
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];

  // Categories
  Set<String> _categories = {'All'};

  bool _isProcessing = false;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProducts());
    context.read<CartBloc>().add(LoadCart());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_isProcessing) return;
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _currentPage = 0;
    });
    _filterProducts();
  }

  void _filterProducts() {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    // Use Future.delayed to avoid blocking UI
    Future.delayed(Duration.zero, () {
      if (!mounted) return;

      List<ProductModel> filtered = _allProducts.where((product) {
        final matchesSearch =
            _searchQuery.isEmpty ||
            product.name.toLowerCase().contains(_searchQuery) ||
            (product.farmerEmail?.toLowerCase().contains(_searchQuery) ??
                false) ||
            (product.categoryName?.toLowerCase().contains(_searchQuery) ??
                false);

        final matchesCategory =
            _selectedCategory == 'All' ||
            (product.categoryName?.toLowerCase() ==
                _selectedCategory.toLowerCase());

        return matchesSearch && matchesCategory;
      }).toList();

      // Apply sorting
      switch (_sortBy) {
        case 'name':
          filtered.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'price_asc':
          filtered.sort(
            (a, b) => (double.tryParse(a.price) ?? 0).compareTo(
              double.tryParse(b.price) ?? 0,
            ),
          );
          break;
        case 'price_desc':
          filtered.sort(
            (a, b) => (double.tryParse(b.price) ?? 0).compareTo(
              double.tryParse(a.price) ?? 0,
            ),
          );
          break;
      }

      setState(() {
        _filteredProducts = filtered;
        _isProcessing = false;
      });
    });
  }

  void _updateSort(String sortBy) {
    if (_isProcessing) return;
    setState(() {
      _sortBy = sortBy;
      _currentPage = 0;
    });
    _filterProducts();
    Navigator.pop(context);
  }

  void _updateCategory(String category) {
    if (_isProcessing) return;
    setState(() {
      _selectedCategory = category;
      _currentPage = 0;
    });
    _filterProducts();
    Navigator.pop(context);
  }

  List<ProductModel> _getPaginatedProducts() {
    final start = _currentPage * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= _filteredProducts.length) return [];
    return _filteredProducts.sublist(
      start,
      end > _filteredProducts.length ? _filteredProducts.length : end,
    );
  }

  void _nextPage() {
    if ((_currentPage + 1) * _itemsPerPage < _filteredProducts.length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _extractCategories(List<ProductModel> products) {
    final cats = <String>{'All'};
    for (var product in products) {
      if (product.categoryName != null && product.categoryName!.isNotEmpty) {
        cats.add(product.categoryName!);
      }
    }
    if (mounted) {
      setState(() {
        _categories = cats;
      });
    }
  }

  void _showSortBottomSheet() {
    final localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            localizations.sortProducts,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(
              Icons.sort_by_alpha,
              color: _sortBy == 'name' ? Colors.green : Colors.grey,
            ),
            title: Text(localizations.byName),
            trailing: _sortBy == 'name'
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () => _updateSort('name'),
          ),
          ListTile(
            leading: Icon(
              Icons.trending_up,
              color: _sortBy == 'price_asc' ? Colors.green : Colors.grey,
            ),
            title: Text(localizations.priceLowToHigh),
            trailing: _sortBy == 'price_asc'
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () => _updateSort('price_asc'),
          ),
          ListTile(
            leading: Icon(
              Icons.trending_down,
              color: _sortBy == 'price_desc' ? Colors.green : Colors.grey,
            ),
            title: Text(localizations.priceHighToLow),
            trailing: _sortBy == 'price_desc'
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () => _updateSort('price_desc'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    final localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            localizations.filterByCategory,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._categories.map(
            (category) => ListTile(
              leading: Icon(
                Icons.category,
                color: _selectedCategory == category
                    ? Colors.green
                    : Colors.grey,
              ),
              title: Text(
                category == 'All' ? localizations.allCategories : category,
              ),
              trailing: _selectedCategory == category
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () => _updateCategory(category),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: Text(localizations.products),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              int cartItemCount = 0;
              if (cartState is CartLoaded) cartItemCount = cartState.totalItems;

              return Stack(
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: localizations.searchProducts,
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: _showSortBottomSheet,
                    tooltip: localizations.sort,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: IconButton(
                    icon: Badge(
                      isLabelVisible: _selectedCategory != 'All',
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.filter_list),
                    ),
                    onPressed: _showFilterBottomSheet,
                    tooltip: localizations.filter,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          // Show loading indicator while initial loading
          if (state is ProductLoading && _allProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.loadingProducts,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (state is ProductError && _allProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    localizations.failedToLoadProducts,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isInitialLoading = true;
                      });
                      context.read<ProductBloc>().add(LoadProducts());
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(localizations.retry),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is ProductLoaded) {
            // Update products when loaded
            if (_allProducts != state.products) {
              _allProducts = state.products.cast<ProductModel>();
              _isInitialLoading = false;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _extractCategories(_allProducts);
                  _filterProducts();
                }
              });
            }

            final paginatedProducts = _getPaginatedProducts();
            final totalPages = (_filteredProducts.length / _itemsPerPage)
                .ceil();

            // Show loading overlay when filtering
            if (_isProcessing) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.filteringProducts,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            if (_filteredProducts.isEmpty && !_isProcessing) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      localizations.noProductsFound,
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isNotEmpty
                          ? localizations.tryDifferentSearchTerm
                          : localizations.checkBackLater,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 20),
                    if (_searchQuery.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(localizations.clearSearch),
                      ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Results info
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizations.productsFound(_filteredProducts.length),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (_selectedCategory != 'All')
                        Chip(
                          label: Text(_selectedCategory),
                          onDeleted: () => _updateCategory('All'),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          backgroundColor: Colors.green.shade100,
                          labelStyle: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),

                // Product Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: paginatedProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                    itemBuilder: (context, index) {
                      final product = paginatedProducts[index];
                      final price = double.tryParse(product.price) ?? 0.0;
                      final canAddToCart = price <= 10000;

                      return _buildProductCard(product, canAddToCart);
                    },
                  ),
                ),

                // Pagination
                if (totalPages > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _previousPage,
                          style: IconButton.styleFrom(
                            backgroundColor: _currentPage > 0
                                ? Colors.green
                                : Colors.grey[300],
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          localizations.pageOf(_currentPage + 1, totalPages),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _nextPage,
                          style: IconButton.styleFrom(
                            backgroundColor:
                                (_currentPage + 1) * _itemsPerPage <
                                    _filteredProducts.length
                                ? Colors.green
                                : Colors.grey[300],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, bool canAddToCart) {
    final localizations = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          RouteName.productDetails,
          pathParameters: {'id': product.id},
          extra: product,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Stack(
                children: [
                  product.image.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.image,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 120,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 120,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 40),
                          ),
                        )
                      : Container(
                          height: 120,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 40),
                        ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${product.price} ETB",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (product.categoryName != null)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.categoryName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (product.subCategoryName != null)
                    Text(
                      product.subCategoryName!,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    localizations.kgAvailable(product.amount),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.getFarmerDisplayName(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.orange,
                              ),
                            ),
                            if (product.regionName != null)
                              Text(
                                product.regionName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                ),
                              ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (canAddToCart) {
                            _showModernCartSheet(context, product);
                          } else {
                            _openChat(context, product);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: canAddToCart ? Colors.green : Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            canAddToCart ? Icons.add_shopping_cart : Icons.chat,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModernCartSheet(BuildContext context, ProductModel product) {
    final localizations = AppLocalizations.of(context)!;
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
                  localizations.total(price * quantity),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _addToCart(context, product.id, quantity);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(localizations.addToCart),
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

  void _addToCart(BuildContext context, String productId, int amount) {
    final localizations = AppLocalizations.of(context)!;

    context.read<CartBloc>().add(
      AddToCart(productId: productId, amount: amount),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.addedToCart(amount)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openChat(BuildContext context, ProductModel product) {
    final localizations = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.chatAboutProduct(product.name)),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
