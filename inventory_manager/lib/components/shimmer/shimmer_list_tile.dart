import 'package:flutter/material.dart';
import 'package:inventory_manager/components/shimmer/shimmer_text.dart';

class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: ClipOval(
        child: ShimmerText(
          width: 50,
          height: 50,
        ),
      ),
      title: ShimmerText(width: 100, height: 15),
      subtitle: ShimmerText(width: 100, height: 10),
    );
  }
}
