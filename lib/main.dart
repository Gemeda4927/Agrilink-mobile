import 'package:flutter/material.dart';
import 'package:agrilink/app.dart';
import 'package:agrilink/injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjector();
  runApp(const MyApp());
}
