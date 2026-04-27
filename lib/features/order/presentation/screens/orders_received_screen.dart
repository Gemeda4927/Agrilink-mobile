
import 'package:flutter/material.dart';
import 'my_orders_screen.dart';

class OrdersReceivedScreen extends StatelessWidget {
  const OrdersReceivedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MyOrdersScreen(initialFarmerView: true);
  }
}