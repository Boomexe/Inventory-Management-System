import 'package:flutter/material.dart';

class MyDrawerTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const MyDrawerTitle({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: onTap,
    );
  }
}
