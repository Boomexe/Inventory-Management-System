import 'package:flutter/material.dart';
import 'package:inventory_manager/components/shimmer/shimmer_list_tile.dart';

class ShimmerList extends StatelessWidget {
  final int itemCount;
  const ShimmerList({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const ShimmerListTile();
      },
    );
  }
}
