// checkout_screen.dart
import 'package:agrilink/core/network/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/cart/domain/entity/cart_item.dart';
import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_event.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_state.dart';
import 'package:agrilink/core/network/dio_client.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
  String? _currentOrderId;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'Chapa',
      name: 'Chapa',
      icon: Icons.credit_card,
      description: 'Pay with Chapa',
      color: const Color(0xFF1A237E),
    ),
    PaymentMethod(
      id: 'Telebirr',
      name: 'Telebirr',
      icon: Icons.phone_android,
      description: 'Pay with Telebirr',
      color: const Color(0xFF00A651),
    ),
    PaymentMethod(
      id: 'Cash on Delivery',
      name: 'Cash on Delivery',
      icon: Icons.money,
      description: 'Pay when you receive',
      color: const Color(0xFFFF6B35),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => _showExitConfirmation(),
        ),
      ),
      body: BlocListener<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartCheckoutSuccess) {
            setState(() {
              _isProcessing = false;
              _currentOrderId = state.orderId;
            });
           
            
            // Validate URL before opening
            if (state.paymentUrl.isNotEmpty && state.paymentUrl.startsWith('http')) {
              _openPaymentWebView(state.paymentUrl, state.orderId);
            } else {
              _showErrorSnackBar('Invalid payment URL. Please try again.');
            }
          } else if (state is CartError) {
            setState(() => _isProcessing = false);
            _showErrorSnackBar(state.message);
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildOrderSummaryCard(),
                  const SizedBox(height: 20),
                  _buildPaymentMethodCard(),
                  const SizedBox(height: 32),
                  _buildPayButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            if (_isProcessing) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag, color: Colors.green.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Order Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.cartItems.length > 3
                  ? 3
                  : widget.cartItems.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                final price = double.tryParse(item.product.price) ?? 0.0;
                final itemTotal = price * item.amount;
                return Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${item.amount}x',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'ETB ${price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'ETB ${itemTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
            if (widget.cartItems.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+ ${widget.cartItems.length - 3} more items',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Subtotal',
              'ETB ${widget.totalPrice.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow('Delivery Fee', 'Free'),
            const Divider(height: 24),
            _buildSummaryRow(
              'Total',
              'ETB ${widget.totalPrice.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? Colors.green.shade700 : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.green.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Payment Method',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._paymentMethods.map((method) => _buildPaymentMethodTile(method)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? method.color : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? method.color.withOpacity(0.05) : Colors.white,
      ),
      child: RadioListTile<String>(
        value: method.id,
        groupValue: _selectedPaymentMethod,
        onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
        activeColor: method.color,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Row(
          children: [
            Icon(method.icon, color: method.color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Text(
          method.description,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
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
                'Place Order & Pay',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Processing...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _processPayment() {
    setState(() => _isProcessing = true);
    context.read<CartBloc>().add(ProcessCheckout());
  }

  void _openPaymentWebView(String paymentUrl, String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentWebView(
          paymentUrl: paymentUrl,
          orderId: orderId,
          totalPrice: widget.totalPrice,
          paymentMethod: _selectedPaymentMethod,
        ),
      ),
    ).then((paymentSuccess) {
      if (paymentSuccess == true) {
        _startPaymentVerification(orderId);
      }
    });
  }

  void _startPaymentVerification(String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentVerificationScreen(
          orderId: orderId,
          totalPrice: widget.totalPrice,
          paymentMethod: _selectedPaymentMethod,
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Checkout'),
        content: const Text('Cancel checkout? Your cart will be saved.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }
}

// ==================== PAYMENT WEBVIEW ====================

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final String orderId;
  final double totalPrice;
  final String paymentMethod;

  const PaymentWebView({
    super.key,
    required this.paymentUrl,
    required this.orderId,
    required this.totalPrice,
    required this.paymentMethod,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url.toLowerCase();
            
            // Check for success indicators
            if (url.contains('success') || 
                url.contains('paid') || 
                url.contains('complete') ||
                url.contains('thank-you')) {
              _handleSuccess();
              return NavigationDecision.prevent;
            }
            
            // Check for failure indicators
            if (url.contains('fail') || 
                url.contains('error') || 
                url.contains('cancel')) {
              _handleFailure();
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            setState(() => _isLoading = true);
            _checkUrlForStatus(url);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            _injectJavaScript();
          },
          onHttpError: (error) {
            print('HTTP Error: $error');
            _showNetworkError();
          },
        ),
      );

    _controller.addJavaScriptChannel(
      'PaymentStatus',
      onMessageReceived: (JavaScriptMessage message) {
        _handleStatusMessage(message.message);
      },
    );

    // Fix malformed URL if needed
    final cleanUrl = _cleanPaymentUrl(widget.paymentUrl);
    _controller.loadRequest(Uri.parse(cleanUrl));
  }

  String _cleanPaymentUrl(String url) {
    // Remove duplicate parameters if any
    if (url.contains('hf2wucqKyAFgP11o0knFyjxQPJuWVaWyNvWnH2wucqKyAFgP11o0knFyjxQPJuWVaWY')) {
      url = url.replaceAll('hf2wucqKyAFgP11o0knFyjxQPJuWVaWyNvWnH2wucqKyAFgP11o0knFyjxQPJuWVaWY', '');
    }
    return url;
  }

  void _injectJavaScript() {
    _controller.runJavaScript("""
      (function() {
        // Monitor page content
        const checkContent = () => {
          const body = document.body ? document.body.innerText : '';
          if (body && (body.includes('PAID') || body.includes('SUCCESS'))) {
            PaymentStatus.postMessage('SUCCESS');
          } else if (body && (body.includes('FAIL') || body.includes('ERROR'))) {
            PaymentStatus.postMessage('FAILURE');
          }
        };
        
        setTimeout(checkContent, 2000);
        
        // Monitor XHR responses
        const originalOpen = XMLHttpRequest.prototype.open;
        XMLHttpRequest.prototype.open = function() {
          this.addEventListener('load', function() {
            if (this.responseText) {
              try {
                const data = JSON.parse(this.responseText);
                if (data.status === 'PAID' || data.status === 'SUCCESS') {
                  PaymentStatus.postMessage('SUCCESS');
                } else if (data.status === 'FAILED') {
                  PaymentStatus.postMessage('FAILURE');
                }
              } catch(e) {}
            }
          });
          return originalOpen.apply(this, arguments);
        };
      })();
    """);
  }

  void _checkUrlForStatus(String url) {
    final urlLower = url.toLowerCase();
    if (urlLower.contains('success') || urlLower.contains('paid')) {
      _handleSuccess();
    } else if (urlLower.contains('fail') || urlLower.contains('error')) {
      _handleFailure();
    }
  }

  void _handleStatusMessage(String message) {
    if (message == 'SUCCESS') {
      _handleSuccess();
    } else if (message == 'FAILURE') {
      _handleFailure();
    }
  }

  void _handleSuccess() {
    if (_isCompleted) return;
    _isCompleted = true;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment successful! Verifying...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  void _handleFailure() {
    if (_isCompleted) return;
    _isCompleted = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: const Text('Your payment was not successful. Please try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isCompleted = false;
                _isLoading = true;
              });
              _controller.reload();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showNetworkError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Network Error'),
        content: const Text('Unable to load payment page. Please check your internet connection.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, false);
            },
            child: const Text('Back'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.reload();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Pay Securely'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showCloseConfirmation(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.grey.shade50,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading payment gateway...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCloseConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Payment'),
        content: const Text('Are you sure you want to cancel the payment?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Payment'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// ==================== PAYMENT VERIFICATION SCREEN ====================

class PaymentVerificationScreen extends StatefulWidget {
  final String orderId;
  final double totalPrice;
  final String paymentMethod;

  const PaymentVerificationScreen({
    super.key,
    required this.orderId,
    required this.totalPrice,
    required this.paymentMethod,
  });

  @override
  State<PaymentVerificationScreen> createState() => _PaymentVerificationScreenState();
}

class _PaymentVerificationScreenState extends State<PaymentVerificationScreen> {
  Timer? _pollingTimer;
  int _attempts = 0;
  static const int maxAttempts = 15;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_attempts >= maxAttempts) {
        timer.cancel();
        _showTimeoutDialog();
      } else {
        _attempts++;
        _verifyPayment();
      }
    });
  }

  Future<void> _verifyPayment() async {
    try {
      final dioClient = context.read<DioClient>();
      final response = await dioClient.get(ApiConstants.verifyOrder(widget.orderId));
      
      if (response.statusCode == 200 && response.data != null) {
        final status = response.data['status']?.toString().toUpperCase();
        
        if (status == 'PAID') {
          _pollingTimer?.cancel();
          _showThankYouPage();
        }
      }
    } catch (e) {
      // Continue polling
    }
  }

  void _showThankYouPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => ThankYouPage(
          orderId: widget.orderId,
          amount: widget.totalPrice,
          paymentMethod: widget.paymentMethod,
        ),
      ),
      (route) => false,
    );
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verification in Progress'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 48, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Payment verification is taking longer than expected.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Please check your order status in "My Orders".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(RouteName.home);
            },
            child: const Text('Go Home'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push(RouteName.orderConfirmation, extra: {
                'orderId': widget.orderId,
                'amount': widget.totalPrice,
                'paymentMethod': widget.paymentMethod,
                'status': 'pending',
              });
            },
            child: const Text('View Order'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 32),
              Text(
                'Verifying Payment...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Attempt $_attempts of $maxAttempts',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Text(
                'Please wait while we confirm your payment',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== THANK YOU PAGE ====================

class ThankYouPage extends StatelessWidget {
  final String orderId;
  final double amount;
  final String paymentMethod;

  const ThankYouPage({
    super.key,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Thank You for Choosing Us! 🎉',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your order has been placed successfully',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildDetailRow('Order ID:', orderId, isHighlighted: true),
                        const Divider(),
                        _buildDetailRow('Amount:', 'ETB ${amount.toStringAsFixed(2)}', isBold: true),
                        const SizedBox(height: 8),
                        _buildDetailRow('Payment Method:', paymentMethod),
                        const SizedBox(height: 8),
                        _buildStatusBadge(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => context.go(RouteName.home),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue Shopping',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      context.push(
                        RouteName.orderConfirmation,
                        extra: {
                          'orderId': orderId,
                          'amount': amount,
                          'paymentMethod': paymentMethod,
                          'status': 'paid',
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.green.shade700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'View My Orders',
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? Colors.green : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Status:'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'PAID',
            style: TextStyle(
              color: Colors.green.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final Color color;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
  });
}