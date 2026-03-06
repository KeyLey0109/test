import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPostLoading extends StatelessWidget {
  const ShimmerPostLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 20, backgroundColor: Colors.white),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 100, height: 10, color: Colors.white),
                    const SizedBox(height: 5),
                    Container(width: 50, height: 10, color: Colors.white),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(width: double.infinity, height: 150, color: Colors.white),
          ],
        ),
      ),
    );
  }
}