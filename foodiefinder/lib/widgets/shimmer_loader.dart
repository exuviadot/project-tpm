import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/constants/app_colors.dart';

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Container(
                height: 110,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: 14, color: Colors.white),
                    const SizedBox(height: 4),
                    Container(width: 80, height: 12, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 120, height: 12, color: Colors.white),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
