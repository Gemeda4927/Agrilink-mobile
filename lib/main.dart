import 'package:flutter/material.dart';
import 'app.dart';
import 'injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjector();
  runApp(const MyApp());
}
