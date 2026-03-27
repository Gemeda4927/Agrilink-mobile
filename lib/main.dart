import 'package:agrilink/features/chat/data/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:agrilink/app.dart';
import 'package:agrilink/injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjector();
  sl<ChatService>().connectSocket();
  runApp(const MyApp());
}
