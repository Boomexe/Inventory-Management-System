import 'package:flutter/material.dart';
import 'package:inventory_manager/auth/auth_gate.dart';
import 'package:inventory_manager/auth/auth_service.dart';
import 'package:inventory_manager/components/drawer/my_drawer_title.dart';
import 'package:inventory_manager/pages/home_page.dart';
import 'package:inventory_manager/pages/transactions_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout(BuildContext context) async {
    AuthService authService = AuthService();
    await authService.deleteSession();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AuthGate(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0),
              child: Icon(
                Icons.inventory,
                size: 72,
              ),
            ),
            const Divider(
              indent: 25,
              endIndent: 25,
            ),
            const SizedBox(height: 10),
            MyDrawerTitle(
              title: 'Home',
              icon: Icons.home_outlined,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
            ),
            // MyDrawerTitle(
            //   title: 'Assigned Items',
            //   icon: Icons.laptop,
            //   onTap: () {
            //     Navigator.pushReplacement(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const HomePage(),
            //       ),
            //     );
            //   },
            // ),
            MyDrawerTitle(
              title: 'Transactions',
              icon: Icons.currency_exchange,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionsPage(),
                  ),
                );
              },
            ),
            MyDrawerTitle(
              title: 'Logout',
              icon: Icons.logout,
              onTap: () => logout(context),
            )
          ],
        ),
      ),
    );
  }
}
