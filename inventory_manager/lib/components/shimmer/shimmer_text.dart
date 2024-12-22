import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerText extends StatelessWidget {
  final double width;
  final double height;
  const ShimmerText({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade400,
      child: Container(
        height: height,
        width: width,
        color: Colors.white,
      ),
    );
  }
}
