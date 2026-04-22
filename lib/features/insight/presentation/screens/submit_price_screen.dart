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

  // Fix: Initialize with a default value or make nullable
  Product? _selectedProduct; // Changed from late to nullable
  String? _selectedWoredaId;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  List<Product> _products = [];
  bool _isLoadingProducts = true;
  String? _errorMessage;

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
      setState(() {
        _products = state.productsResponse.products;
        _isLoadingProducts = false;
        _errorMessage = null;

        // Set selected product
        if (widget.preSelectedProduct != null) {
          _selectedProduct = widget.preSelectedProduct;
        } else if (_products.isNotEmpty) {
          _selectedProduct = _products.first;
        }
      });
    } else if (state is MarketError) {
      setState(() {
        _isLoadingProducts = false;
        _errorMessage = state.message;
      });
    } else {
      context.read<MarketBloc>().add(GetAllProductsEvent());

      final subscription = context.read<MarketBloc>().stream.listen((state) {
        if (state is ProductsLoaded && mounted) {
          setState(() {
            _products = state.productsResponse.products;
            _isLoadingProducts = false;
            if (widget.preSelectedProduct != null) {
              _selectedProduct = widget.preSelectedProduct;
            } else if (_products.isNotEmpty) {
              _selectedProduct = _products.first;
            }
          });
        } else if (state is MarketError && mounted) {
          setState(() {
            _isLoadingProducts = false;
            _errorMessage = state.message;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Market Price')),
      body: BlocListener<MarketBloc, MarketState>(
        listener: (context, state) {
          if (state is MarketPriceSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Price submitted successfully!')),
            );
            Navigator.pop(context, true);
          } else if (state is MarketError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: _isLoadingProducts
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $_errorMessage'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadProducts,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _buildForm(),
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
            // Product Selection
            DropdownButtonFormField<Product>(
              decoration: const InputDecoration(
                labelText: 'Product',
                border: OutlineInputBorder(),
              ),
              value: _selectedProduct,
              items: _products.map((product) {
                return DropdownMenuItem(
                  value: product,
                  child: Text(product.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProduct = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a product';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Woreda Selection
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Woreda ID',
                border: OutlineInputBorder(),
                hintText: 'Enter woreda ID',
              ),
              onChanged: (value) {
                _selectedWoredaId = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter woreda ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Price
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price (ETB)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Latitude
            TextFormField(
              controller: _latitudeController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                border: OutlineInputBorder(),
                hintText: 'e.g., 9.03 N',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter latitude';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Longitude
            TextFormField(
              controller: _longitudeController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(),
                hintText: 'e.g., 38.74 E',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter longitude';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _submitPrice,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Submit Price'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitPrice() {
    if (_formKey.currentState!.validate() && _selectedProduct != null) {
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
