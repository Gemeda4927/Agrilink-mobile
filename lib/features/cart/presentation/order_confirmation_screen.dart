import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agrilink/core/config/routes/route_name.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String? orderId;
  final double? amount;
  final String? paymentMethod;

  const OrderConfirmationScreen({
    super.key,
    this.orderId,
    this.amount,
    this.paymentMethod,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  String _orderId = '';
  double _amount = 0.0;
  String _paymentMethod = '';

  @override
  void initState() {
    super.initState();
    
    // Validate and initialize data
    _validateAndInitializeData();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  void _validateAndInitializeData() {
    // Set default values if data is missing
    _orderId = widget.orderId ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    _amount = widget.amount ?? 0.0;
    _paymentMethod = widget.paymentMethod ?? 'Unknown';
    
    // If amount is 0, show warning
    if (_amount <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Warning: Order amount is 0"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Success Animation
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 80,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Success Text
                const Text(
                  'Order Placed Successfully!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Thank you for your purchase',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Order Details Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Order Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        // Order ID - Full display without truncation
                        _buildDetailRow(
                          'Order ID',
                          _orderId,
                          Icons.receipt,
                          isFullText: true,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Amount Paid',
                          'ETB ${_amount.toStringAsFixed(2)}',
                          Icons.money,
                          isAmount: true,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Payment Method',
                          _paymentMethod.toUpperCase(),
                          Icons.payment,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Order Date',
                          _getCurrentDate(),
                          Icons.calendar_today,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Continue Shopping Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to home and clear all previous routes
                      context.go(RouteName.home);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue Shopping',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Share Order Button
                TextButton.icon(
                  onPressed: () {
                    _shareOrderDetails();
                  },
                  icon: const Icon(Icons.share, color: Colors.green),
                  label: const Text(
                    'Share Order Details',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool isAmount = false,
    bool isFullText = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: Colors.green, size: 20),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(width: 12),
        // For full text display (like Order ID), use Expanded without truncation
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isAmount ? 16 : 14,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
              color: isAmount ? Colors.green : Colors.black,
            ),
            textAlign: TextAlign.right,
            overflow: isFullText ? TextOverflow.visible : TextOverflow.ellipsis,
            maxLines: isFullText ? null : 1,
          ),
        ),
      ],
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  void _shareOrderDetails() {
    // Show feedback that share feature is coming
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}