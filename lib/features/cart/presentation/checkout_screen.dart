import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/cart/domain/entity/cart_item.dart';
import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_event.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_state.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalPrice;
  final int totalItems;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalPrice,
    required this.totalItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'Chapa';
  bool _isProcessing = false;

  final List<String> _paymentMethods = [
    'Chapa',
    'Telebirr',
    'Cash on Delivery',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartCheckoutSuccess) {
            setState(() => _isProcessing = false);
            log('✅ Order created successfully!');
            log('📦 Order ID: ${state.orderId}');
            log('🔗 Payment URL: ${state.paymentUrl}');

            // Open URL directly without canLaunchUrl check
            _launchPaymentUrlDirectly(state.paymentUrl, state.orderId);
          } else if (state is CartError) {
            setState(() => _isProcessing = false);
            log('❌ Checkout error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      ...widget.cartItems.map((item) {
                        final price =
                            double.tryParse(item.product.price) ?? 0.0;
                        final itemTotal = price * item.amount;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.product.name} x ${item.amount}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text('ETB ${itemTotal.toStringAsFixed(2)}'),
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Items:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${widget.totalItems}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ETB ${widget.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Method Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._paymentMethods.map((method) {
                        return RadioListTile<String>(
                          title: Text(
                            method,
                            style: const TextStyle(fontSize: 16),
                          ),
                          value: method,
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value!;
                            });
                          },
                          activeColor: Colors.green,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Pay Now Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Pay Now',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processPayment() {
    setState(() => _isProcessing = true);
    context.read<CartBloc>().add(ProcessCheckout());
  }

  Future<void> _launchPaymentUrlDirectly(
    String paymentUrl,
    String orderId,
  ) async {
    final Uri url = Uri.parse(paymentUrl);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Opening payment page...'),
          ],
        ),
      ),
    );

    try {
      // Try to launch the URL
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (launched) {
        log('✅ Browser opened successfully');
        _showPaymentInitiatedDialog(orderId);
      } else {
        log('❌ Failed to open browser');
        _showErrorDialog(
          'Could not open payment page. Please check your browser settings.',
        );
      }
    } catch (e) {
      log('❌ Error opening URL: $e');
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog('Could not open payment page. Error: $e');
      }
    }
  }

  void _showPaymentInitiatedDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Initiated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.payment, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Please complete the payment in the opened browser.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Order ID:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    orderId,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Total Amount:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'ETB ${widget.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'After payment, you can view your order status.',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push(
                RouteName.orderConfirmation,
                extra: {
                  'orderId': orderId,
                  'amount': widget.totalPrice,
                  'paymentMethod': _selectedPaymentMethod,
                  'status': 'pending',
                },
              );
            },
            child: const Text('View Order'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(RouteName.home);
            },
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Error'),
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
}
