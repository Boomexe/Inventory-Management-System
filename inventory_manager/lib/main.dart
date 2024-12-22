import 'package:flutter/material.dart';
import 'package:inventory_manager/auth/auth_gate.dart';
import 'package:inventory_manager/themes/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AuthGate(),
    );
  }
}
