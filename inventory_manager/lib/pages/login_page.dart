import 'package:flutter/material.dart';
import 'package:inventory_manager/auth/auth_service.dart';
import 'package:inventory_manager/components/my_loading_circle.dart';
import 'package:inventory_manager/components/my_text_field.dart';
import 'package:inventory_manager/pages/home_page.dart';
import 'package:inventory_manager/pages/signup_page.dart';
import 'package:inventory_manager/services/inventory_manager_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void login(BuildContext context) async {
    showLoadingCircle(context);
    final result = await InventoryManagerService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    hideLoadingCircle(context);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure)),
        );
      },
      (success) async {
        AuthService authService = AuthService();
        bool isLoggedIn = await authService.isLoggedIn();
        
        if (isLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inventory, size: 100),
              const SizedBox(height: 25),
              MyTextField(
                hintText: 'Email',
                textController: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              MyTextField(
                hintText: 'Password',
                obscureText: true,
                textController: _passwordController,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => login(context),
                child: const Text('Login'),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
