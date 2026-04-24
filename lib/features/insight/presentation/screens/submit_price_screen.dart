// features/insight/presentation/screens/submit_price_screen.dart
import 'package:agrilink/features/insight/presentation/bloc/market_event.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_bloc.dart';
import 'package:agrilink/features/insight/data/model/market_insight.dart';

class SubmitPriceScreen extends StatefulWidget {
  final Product? preSelectedProduct;

  const SubmitPriceScreen({super.key, this.preSelectedProduct});

  @override
  State<SubmitPriceScreen> createState() => _SubmitPriceScreenState();
}

class _SubmitPriceScreenState extends State<SubmitPriceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  Product? _selectedProduct;
  String? _selectedWoredaId;
  List<Product> _products = [];
  bool _isLoadingProducts = true;
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    final state = context.read<MarketBloc>().state;

    if (state is ProductsLoaded) {
      _updateProductsList(state);
    } else if (state is MarketError) {
      setState(() {
        _isLoadingProducts = false;
        _errorMessage = state.message;
      });
    } else {
      context.read<MarketBloc>().add(GetAllProductsEvent());
      _listenForProducts();
    }
  }

  void _listenForProducts() {
    final subscription = context.read<MarketBloc>().stream.listen((state) {
      if (state is ProductsLoaded && mounted) {
        _updateProductsList(state);
      } else if (state is MarketError && mounted) {
        setState(() {
          _isLoadingProducts = false;
          _errorMessage = state.message;
        });
      }
    });
  }

  void _updateProductsList(ProductsLoaded state) {
    setState(() {
      _products = state.productsResponse.products;
      _isLoadingProducts = false;
      _errorMessage = null;

      if (widget.preSelectedProduct != null) {
        _selectedProduct = widget.preSelectedProduct;
      } else if (_products.isNotEmpty) {
        _selectedProduct = _products.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Market Price'),
        elevation: 2,
      ),
      body: BlocListener<MarketBloc, MarketState>(
        listener: _handleStateChange,
        child: _buildBody(),
      ),
    );
  }

  void _handleStateChange(BuildContext context, MarketState state) {
    if (state is MarketPriceSubmitted) {
      _showSnackBar('Price submitted successfully!', isError: false);
      Navigator.pop(context, true);
    } else if (state is MarketError && !_isLoadingProducts) {
      _showSnackBar('Error: ${state.message}', isError: true);
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return _buildForm();
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $_errorMessage'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProducts,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProductDropdown(),
            const SizedBox(height: 16),
            _buildWoredaField(),
            const SizedBox(height: 16),
            _buildPriceField(),
            const SizedBox(height: 16),
            _buildLatitudeField(),
            const SizedBox(height: 16),
            _buildLongitudeField(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDropdown() {
    return DropdownButtonFormField<Product>(
      decoration: const InputDecoration(
        labelText: 'Product *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.production_quantity_limits),
      ),
      value: _selectedProduct,
      items: _products.map((product) {
        return DropdownMenuItem(
          value: product,
          child: Text(product.name),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedProduct = value),
      validator: (value) => value == null ? 'Please select a product' : null,
    );
  }

  Widget _buildWoredaField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Woreda ID *',
        border: OutlineInputBorder(),
        hintText: 'Enter woreda ID',
        prefixIcon: Icon(Icons.location_city),
      ),
      onChanged: (value) => _selectedWoredaId = value,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter woreda ID' : null,
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: const InputDecoration(
        labelText: 'Price (ETB) *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter price';
        if (double.tryParse(value) == null) return 'Please enter a valid number';
        return null;
      },
    );
  }

  Widget _buildLatitudeField() {
    return TextFormField(
      controller: _latitudeController,
      decoration: const InputDecoration(
        labelText: 'Latitude *',
        border: OutlineInputBorder(),
        hintText: 'e.g., 9.03',
        prefixIcon: Icon(Icons.map),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter latitude' : null,
    );
  }

  Widget _buildLongitudeField() {
    return TextFormField(
      controller: _longitudeController,
      decoration: const InputDecoration(
        labelText: 'Longitude *',
        border: OutlineInputBorder(),
        hintText: 'e.g., 38.74',
        prefixIcon: Icon(Icons.map),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter longitude' : null,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitPrice,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: _isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Submit Price', style: TextStyle(fontSize: 16)),
    );
  }

  void _submitPrice() {
    if (_formKey.currentState!.validate() && _selectedProduct != null) {
      setState(() => _isSubmitting = true);

      final request = MarketPriceRequest(
        productId: _selectedProduct!.id,
        woredaId: _selectedWoredaId!,
        price: double.parse(_priceController.text),
        latitude: _latitudeController.text,
        longitude: _longitudeController.text,
      );

      context.read<MarketBloc>().add(SubmitMarketPriceEvent(request));
    }
  }
}