import 'dart:async';
import 'package:agrilink/features/insight/presentation/bloc/market_event.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_bloc.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_bloc.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_event.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_state.dart';
import '../../data/model/market_insight.dart';

class SubmitPriceScreen extends StatefulWidget {
  final ProductInfo? preSelectedProduct;
  final MarketPriceResponse? existingPrice;

  const SubmitPriceScreen({
    super.key,
    this.preSelectedProduct,
    this.existingPrice,
  });

  @override
  State<SubmitPriceScreen> createState() => _SubmitPriceScreenState();
}

class _SubmitPriceScreenState extends State<SubmitPriceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  ProductInfo? _selectedProduct;

  // Hierarchical location selections
  dynamic _selectedRegion;
  dynamic _selectedZone;
  dynamic _selectedWoreda;
  dynamic _selectedKebele;

  String? _selectedWoredaId; // For submission

  List<ProductInfo> _products = [];
  List<dynamic> _regions = [];
  List<dynamic> _zones = [];
  List<dynamic> _woredas = [];
  List<dynamic> _kebeles = [];

  bool _isLoadingProducts = true;
  bool _isLoadingRegions = true;
  bool _isLoadingZones = false;
  bool _isLoadingWoredas = false;
  bool _isLoadingKebeles = false;
  bool _isGettingLocation = false;

  String? _errorMessage;
  bool _isSubmitting = false;

  // Edit mode flag
  bool get _isEditMode => widget.existingPrice != null;
  String? _editingPriceId;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadRegions();

    if (_isEditMode) {
      _populateExistingData();
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  // ================= EDIT MODE METHODS =================

  void _populateExistingData() {
    final price = widget.existingPrice!;
    _editingPriceId = price.id;
    _priceController.text = price.price.toString();

    if (price.latitude != null && price.latitude!.isNotEmpty) {
      _latitudeController.text = price.latitude!;
    }
    if (price.longitude != null && price.longitude!.isNotEmpty) {
      _longitudeController.text = price.longitude!;
    }

    _selectedWoredaId = price.woredaId;
  }

  // ================= HIERARCHICAL LOCATION METHODS =================

  void _loadRegions() {
    context.read<RegistrationBloc>().add(LoadRegions());
  }

  void _onRegionSelected(dynamic region) {
    setState(() {
      _selectedRegion = region;
      _selectedZone = null;
      _selectedWoreda = null;
      _selectedKebele = null;
      _selectedWoredaId = null;
      _zones = [];
      _woredas = [];
      _kebeles = [];
      _isLoadingZones = true;
    });
    context.read<RegistrationBloc>().add(
      LoadZones(region['id']),
    );
  }

  void _onZoneSelected(dynamic zone) {
    setState(() {
      _selectedZone = zone;
      _selectedWoreda = null;
      _selectedKebele = null;
      _selectedWoredaId = null;
      _woredas = [];
      _kebeles = [];
      _isLoadingWoredas = true;
    });
    context.read<RegistrationBloc>().add(
      LoadWoredas(zone['id']),
    );
  }

  void _onWoredaSelected(dynamic woreda) {
    setState(() {
      _selectedWoreda = woreda;
      _selectedKebele = null;
      _selectedWoredaId = woreda['id'];
      _kebeles = [];
      _isLoadingKebeles = true;
    });
    context.read<RegistrationBloc>().add(
      LoadKebeles(woreda['id']),
    );
  }

  void _onKebeleSelected(dynamic kebele) {
    setState(() {
      _selectedKebele = kebele;
    });
  }

  // ================= LOCATION METHODS =================

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationDialog('Location services are disabled. Please enable them.');
        return;
      }

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

  void _listenForProducts() {
    late StreamSubscription<MarketState> subscription;

    subscription = context.read<MarketBloc>().stream.listen((state) {
      if (state is ProductsLoaded && mounted) {
        _updateProductsList(state);
        subscription.cancel();
      } else if (state is MarketError && mounted) {
        setState(() {
          _isLoadingProducts = false;
          _errorMessage = state.message;
        });
        subscription.cancel();
      }
    });
  }

  void _updateProductsList(ProductsLoaded state) {
    setState(() {
      _products = state.products;
      _isLoadingProducts = false;
      _errorMessage = null;

      if (_isEditMode && widget.existingPrice != null) {
        _selectedProduct = _products.firstWhere(
          (product) => product.id == widget.existingPrice!.productId,
          orElse: () => _products.isNotEmpty ? _products.first : ProductInfo(id: '', name: ''),
        );
        if (_selectedProduct?.id == '') _selectedProduct = null;
      } else if (widget.preSelectedProduct != null) {
        _selectedProduct = widget.preSelectedProduct;
      } else if (_products.isNotEmpty) {
        _selectedProduct = _products.first;
      }
    });
  }

  // ================= REVIEW & SUBMIT/UPDATE =================

  void _showReviewDialog() {
    if (!_formKey.currentState!.validate() ||
        _selectedProduct == null ||
        _selectedWoredaId == null) {
      return;
    }

    final isEdit = _isEditMode;
    final actionButtonText = isEdit ? 'Confirm Update' : 'Confirm Submit';

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
            Center(
              child: Text(
                'Review ${isEdit ? 'Update' : 'Submission'}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              label: 'Region',
              value: _selectedRegion?['name'] ?? 'N/A',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildReviewTile(
              icon: Icons.location_on,
              label: 'Zone',
              value: _selectedZone?['name'] ?? 'N/A',
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildReviewTile(
              icon: Icons.map,
              label: 'Woreda',
              value: _selectedWoreda?['name'] ?? 'Selected',
              color: Colors.teal,
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
              color: Colors.pink,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isEdit ? Colors.blue.shade50 : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit_note : Icons.info_outline,
                    color: isEdit ? Colors.blue : Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEdit
                          ? 'Updating this price will require re-approval by moderators.'
                          : 'Please review your information carefully. Submitted prices will be reviewed by moderators.',
                      style: const TextStyle(fontSize: 12),
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
                      if (isEdit) {
                        _updatePrice();
                      } else {
                        _submitPrice();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(actionButtonText),
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

  void _updatePrice() {
    setState(() => _isSubmitting = true);

    final request = MarketPriceRequest(
      productId: _selectedProduct!.id,
      woredaId: _selectedWoredaId!,
      price: double.parse(_priceController.text),
      latitude: _latitudeController.text,
      longitude: _longitudeController.text,
    );

    context.read<MarketBloc>().add(
      UpdateMarketPriceEvent(id: _editingPriceId!, request: request),
    );
  }

  void _showSuccessModal({required bool isEdit}) {
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
                child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
              ),
              const SizedBox(height: 20),
              Text(
                isEdit ? 'Updated!' : 'Success!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                isEdit ? 'Price updated successfully' : 'Price submitted successfully',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (!isEdit) ...[
                const SizedBox(height: 8),
                Text(
                  'Your submission is pending review',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
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
    return MultiBlocListener(
      listeners: [
        BlocListener<MarketBloc, MarketState>(
          listener: (context, state) {
            if (state is MarketPriceSubmitted) {
              _showSuccessModal(isEdit: false);
            } else if (state is MarketPriceUpdated) {
              _showSuccessModal(isEdit: true);
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
        ),
        BlocListener<RegistrationBloc, RegistrationState>(
          listener: (context, state) {
            if (state is RegionsLoaded) {
              setState(() {
                _regions = state.regions;
                _isLoadingRegions = false;
              });
            } else if (state is ZonesLoaded) {
              setState(() {
                _zones = state.zones;
                _isLoadingZones = false;
              });
            } else if (state is WoredasLoaded) {
              setState(() {
                _woredas = state.woredas;
                _isLoadingWoredas = false;
              });
            } else if (state is KebelesLoaded) {
              setState(() {
                _kebeles = state.kebeles;
                _isLoadingKebeles = false;
              });
            } else if (state is RegistrationError) {
              setState(() {
                _isLoadingZones = false;
                _isLoadingWoredas = false;
                _isLoadingKebeles = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Location Error: ${state.message}'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? 'Edit Market Price' : 'Submit Market Price'),
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
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if ((_isLoadingProducts || _isLoadingRegions) && _products.isEmpty && _regions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _products.isEmpty) {
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
                _isLoadingRegions = true;
                _errorMessage = null;
                _loadProducts();
                _loadRegions();
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProductDropdown(),
            const SizedBox(height: 20),
            _buildRegionDropdown(),
            const SizedBox(height: 20),
            if (_selectedRegion != null) _buildZoneDropdown(),
            if (_selectedZone != null) const SizedBox(height: 20),
            if (_selectedZone != null) _buildWoredaDropdown(),
            if (_selectedWoreda != null) const SizedBox(height: 20),
            if (_selectedWoreda != null) _buildKebeleDropdown(),
            const SizedBox(height: 20),
            _buildPriceField(),
            const SizedBox(height: 20),
            _buildLocationSection(),
            const SizedBox(height: 28),
            _buildSubmitButton(),
            const SizedBox(height: 16),
            _buildInfoNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: DropdownButtonFormField<ProductInfo>(
            decoration: InputDecoration(
              hintText: 'Select a product',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            value: _selectedProduct,
            isExpanded: true,
            items: _products.map((product) {
              return DropdownMenuItem(
                value: product,
                child: Row(
                  children: [
                    Icon(_getProductIcon(product.name), size: 20, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(child: Text(product.name)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedProduct = value),
            validator: (value) => value == null ? 'Please select a product' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildRegionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Region', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: DropdownButtonFormField<dynamic>(
            decoration: InputDecoration(
              hintText: 'Select a region',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            value: _selectedRegion,
            isExpanded: true,
            items: _regions.map((region) {
              return DropdownMenuItem(
                value: region,
                child: Row(
                  children: [
                    Icon(Icons.location_city, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Expanded(child: Text(region['name'])),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => _onRegionSelected(value),
            validator: (value) => value == null ? 'Please select a region' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildZoneDropdown() {
    if (_isLoadingZones) {
      return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Center(child: CircularProgressIndicator()));
    }
    if (_zones.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Zone', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: DropdownButtonFormField<dynamic>(
            decoration: InputDecoration(
              hintText: 'Select a zone',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            value: _selectedZone,
            isExpanded: true,
            items: _zones.map((zone) {
              return DropdownMenuItem(
                value: zone,
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Expanded(child: Text(zone['name'])),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => _onZoneSelected(value),
            validator: (value) => value == null ? 'Please select a zone' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildWoredaDropdown() {
    if (_isLoadingWoredas) {
      return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Center(child: CircularProgressIndicator()));
    }
    if (_woredas.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Woreda (District)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: DropdownButtonFormField<dynamic>(
            decoration: InputDecoration(
              hintText: 'Select a woreda',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            value: _selectedWoreda,
            isExpanded: true,
            items: _woredas.map((woreda) {
              return DropdownMenuItem(
                value: woreda,
                child: Row(
                  children: [
                    Icon(Icons.map, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Expanded(child: Text(woreda['name'])),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => _onWoredaSelected(value),
            validator: (value) => value == null ? 'Please select a woreda' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildKebeleDropdown() {
    if (_isLoadingKebeles) {
      return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Center(child: CircularProgressIndicator()));
    }
    if (_kebeles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kebele', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: DropdownButtonFormField<dynamic>(
            decoration: InputDecoration(
              hintText: 'Select a kebele',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            value: _selectedKebele,
            isExpanded: true,
            items: _kebeles.map((kebele) {
              return DropdownMenuItem(
                value: kebele,
                child: Row(
                  children: [
                    Icon(Icons.place, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Expanded(child: Text(kebele['name'])),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => _onKebeleSelected(value),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: TextFormField(
            controller: _priceController,
            decoration: InputDecoration(
              hintText: 'Enter price in ETB',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2)),
              prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
              suffixText: 'ETB',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter price';
              final price = double.tryParse(value);
              if (price == null) return 'Please enter a valid number';
              if (price <= 0) return 'Price must be greater than 0';
              if (price > 100000) return 'Price seems unrealistic. Please verify';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Location Coordinates', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade700))),
            TextButton.icon(
              onPressed: _isGettingLocation ? null : _getCurrentLocation,
              icon: _isGettingLocation
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location, size: 18),
              label: Text(_isGettingLocation ? 'Getting...' : 'Use My Location'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF2E7D32)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _latitudeController,
                decoration: InputDecoration(
                  hintText: 'Latitude (e.g., 7.6753)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2)),
                  prefixIcon: const Icon(Icons.map, color: Colors.grey),
                  suffixText: 'N',
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d+\.?\d*'))],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter latitude';
                  final lat = double.tryParse(value);
                  if (lat == null) return 'Please enter a valid number';
                  if (lat < -90 || lat > 90) return 'Latitude must be between -90 and 90';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _longitudeController,
                decoration: InputDecoration(
                  hintText: 'Longitude (e.g., 36.8373)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2)),
                  prefixIcon: const Icon(Icons.map, color: Colors.grey),
                  suffixText: 'E',
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d+\.?\d*'))],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter longitude';
                  final lng = double.tryParse(value);
                  if (lng == null) return 'Please enter a valid number';
                  if (lng < -180 || lng > 180) return 'Longitude must be between -180 and 180';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final isEdit = _isEditMode;
    final buttonText = isEdit ? 'Review & Update' : 'Review & Submit';
    final isFormValid = _selectedProduct != null && _selectedWoredaId != null && _priceController.text.isNotEmpty;

    return ElevatedButton(
      onPressed: _isSubmitting || !isFormValid ? null : _showReviewDialog,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E7D32),
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: _isSubmitting
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Text(buttonText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoNote() {
    final isEdit = _isEditMode;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEdit
                  ? 'Updating this price will require re-approval by moderators.'
                  : 'Your submission will be reviewed before appearing in the market insights.',
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    final isEdit = _isEditMode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'How to Update Prices' : 'How to Submit Prices'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem('1. Select Product', 'Choose the agricultural product you want to report', Icons.production_quantity_limits),
              const SizedBox(height: 12),
              _buildHelpItem('2. Select Region → Zone → Woreda', 'Navigate through the hierarchical location selection', Icons.location_city),
              const SizedBox(height: 12),
              _buildHelpItem('3. Enter Price', 'Input the current market price in Ethiopian Birr (ETB)', Icons.attach_money),
              const SizedBox(height: 12),
              _buildHelpItem('4. Get Location', 'Tap "Use My Location" to auto-fill coordinates', Icons.my_location),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isEdit
                            ? 'Updated prices will be reviewed by moderators before appearing publicly.'
                            : 'Submitted prices will be reviewed by moderators before appearing publicly.',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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