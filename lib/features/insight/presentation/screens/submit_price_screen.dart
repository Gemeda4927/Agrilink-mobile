// features/insight/presentation/screens/submit_price_screen.dart
import 'package:agrilink/features/insight/presentation/bloc/market_event.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_bloc.dart';
import '../../data/model/market_insight.dart';

class SubmitPriceScreen extends StatefulWidget {
  final ProductInfo? preSelectedProduct;

  const SubmitPriceScreen({super.key, this.preSelectedProduct});

  @override
  State<SubmitPriceScreen> createState() => _SubmitPriceScreenState();
}

class _SubmitPriceScreenState extends State<SubmitPriceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  ProductInfo? _selectedProduct;
  String? _selectedWoredaId;
  List<ProductInfo> _products = [];
  List<WoredaInfo> _woredas = [];
  bool _isLoadingProducts = true;
  bool _isLoadingWoredas = true;
  bool _isGettingLocation = false;
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadWoredas();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  // ================= LOCATION METHODS =================

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationDialog('Location services are disabled. Please enable them.');
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationDialog('Location permission denied. Please allow it to get your location.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationDialog('Location permission permanently denied. Please enable it in settings.');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📍 Location captured successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showLocationDialog('Error getting location: ${e.toString()}');
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  void _showLocationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Access'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ================= DATA LOADING METHODS =================

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

  void _loadWoredas() async {
    // Fetch from API or use mock
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _woredas = [
          WoredaInfo(id: "3ad29a6c-f11a-4041-94fe-0cbd20cd75eb", name: "Jimma"),
          WoredaInfo(id: "woreda2", name: "Addis Ababa"),
          WoredaInfo(id: "woreda3", name: "Bahir Dar"),
          WoredaInfo(id: "woreda4", name: "Hawassa"),
          WoredaInfo(id: "woreda5", name: "Dire Dawa"),
        ];
        _isLoadingWoredas = false;
      });
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
      _products = state.products;
      _isLoadingProducts = false;
      _errorMessage = null;

      if (widget.preSelectedProduct != null) {
        _selectedProduct = widget.preSelectedProduct;
      } else if (_products.isNotEmpty) {
        _selectedProduct = _products.first;
      }
    });
  }

  // ================= REVIEW & SUBMIT =================

  void _showReviewDialog() {
    if (!_formKey.currentState!.validate() || _selectedProduct == null || _selectedWoredaId == null) {
      return;
    }

    final woreda = _woredas.firstWhere((w) => w.id == _selectedWoredaId, orElse: () => WoredaInfo(id: '', name: 'Unknown'));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Review Submission',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildReviewTile(
              icon: Icons.production_quantity_limits,
              label: 'Product',
              value: _selectedProduct!.name,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildReviewTile(
              icon: Icons.location_city,
              label: 'Woreda',
              value: woreda.name,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildReviewTile(
              icon: Icons.attach_money,
              label: 'Price',
              value: '${double.parse(_priceController.text).toStringAsFixed(0)} ETB',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildReviewTile(
              icon: Icons.map,
              label: 'Coordinates',
              value: '${_latitudeController.text} N, ${_longitudeController.text} E',
              color: Colors.purple,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please review your information carefully. Submitted prices will be reviewed by moderators.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _submitPrice();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Confirm Submit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitPrice() {
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

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Price submitted successfully',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Your submission is pending review',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Go back with success
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI BUILD METHODS =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Market Price'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: BlocListener<MarketBloc, MarketState>(
        listener: (context, state) {
          if (state is MarketPriceSubmitted) {
            _showSuccessModal();
          } else if (state is MarketError && !_isLoadingProducts) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Error: ${state.message}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
            setState(() => _isSubmitting = false);
          }
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingProducts || _isLoadingWoredas) {
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
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isLoadingProducts = true;
                _errorMessage = null;
                _loadProducts();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
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
            _buildWoredaDropdown(),
            const SizedBox(height: 16),
            _buildPriceField(),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 12),
            _buildInfoNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<ProductInfo>(
        decoration: InputDecoration(
          labelText: 'Product *',
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
          prefixIcon: const Icon(Icons.production_quantity_limits),
          filled: true,
          fillColor: Colors.white,
        ),
        value: _selectedProduct,
        items: _products.map((product) {
          return DropdownMenuItem(
            value: product,
            child: Row(
              children: [
                Icon(_getProductIcon(product.name), size: 18, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Text(product.name),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedProduct = value),
        validator: (value) => value == null ? 'Please select a product' : null,
      ),
    );
  }

  Widget _buildWoredaDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Woreda (District) *',
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
          prefixIcon: const Icon(Icons.location_city),
          filled: true,
          fillColor: Colors.white,
        ),
        value: _selectedWoredaId,
        items: _woredas.map((woreda) {
          return DropdownMenuItem(
            value: woreda.id,
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Text(woreda.name),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedWoredaId = value),
        validator: (value) => value == null || value.isEmpty ? 'Please select a woreda' : null,
      ),
    );
  }

  Widget _buildPriceField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _priceController,
        decoration: InputDecoration(
          labelText: 'Price (ETB) *',
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
          prefixIcon: const Icon(Icons.attach_money),
          suffixText: 'ETB',
          filled: true,
          fillColor: Colors.white,
          helperText: 'Enter the current market price',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter price';
          final price = double.tryParse(value);
          if (price == null) return 'Please enter a valid number';
          if (price <= 0) return 'Price must be greater than 0';
          if (price > 100000) return 'Price seems unrealistic. Please verify';
          return null;
        },
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Location Coordinates',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _isGettingLocation ? null : _getCurrentLocation,
              icon: _isGettingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, size: 18),
              label: Text(_isGettingLocation ? 'Getting...' : 'Use My Location'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _latitudeController,
                  decoration: InputDecoration(
                    labelText: 'Latitude *',
                    labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                    ),
                    prefixIcon: const Icon(Icons.map),
                    suffixText: 'N',
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'e.g., 7.6753',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d+\.?\d*')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter latitude';
                    final lat = double.tryParse(value);
                    if (lat == null) return 'Please enter a valid number';
                    if (lat < -90 || lat > 90) return 'Latitude must be between -90 and 90';
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _longitudeController,
                  decoration: InputDecoration(
                    labelText: 'Longitude *',
                    labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                    ),
                    prefixIcon: const Icon(Icons.map),
                    suffixText: 'E',
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'e.g., 36.8373',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d+\.?\d*')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter longitude';
                    final lng = double.tryParse(value);
                    if (lng == null) return 'Please enter a valid number';
                    if (lng < -180 || lng > 180) return 'Longitude must be between -180 and 180';
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _showReviewDialog,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E7D32),
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: _isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              'Review & Submit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your submission will be reviewed before appearing in the market insights.',
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Submit Prices'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem('1. Select Product', 'Choose the agricultural product you want to report', Icons.production_quantity_limits),
            const SizedBox(height: 12),
            _buildHelpItem('2. Select Woreda', 'Choose the district where you observed the price', Icons.location_city),
            const SizedBox(height: 12),
            _buildHelpItem('3. Enter Price', 'Input the current market price in Ethiopian Birr (ETB)', Icons.attach_money),
            const SizedBox(height: 12),
            _buildHelpItem('4. Get Location', 'Tap "Use My Location" to auto-fill coordinates', Icons.my_location),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Submitted prices will be reviewed by moderators before appearing publicly.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: Colors.green.shade700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getProductIcon(String productName) {
    switch (productName.toLowerCase()) {
      case 'teff': return Icons.grass;
      case 'wheat': return Icons.agriculture;
      case 'coffee': return Icons.coffee;
      case 'maize': return Icons.earbuds;
      case 'banana': return Icons.emoji_food_beverage;
      case 'orange': return Icons.circle;
      default: return Icons.production_quantity_limits;
    }
  }
}

class WoredasLoaded extends MarketState {
  final List<WoredaInfo> woredas;
  WoredasLoaded(this.woredas);
}