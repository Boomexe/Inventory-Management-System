import 'package:flutter/material.dart';
import 'package:inventory_manager/auth/auth_service.dart';
import 'package:inventory_manager/pages/home_page.dart';
import 'package:inventory_manager/pages/login_page.dart';

class AuthGate extends StatelessWidget {
  AuthGate({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _authService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == true) {
              return const HomePage();
            }
          }
          
          return const LoginPage();
        },
      ),
    );
  }
}
