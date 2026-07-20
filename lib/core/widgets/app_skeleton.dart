import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppSkeleton extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const AppSkeleton({
    super.key,
    this.height = 16,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const AppSkeleton(height: 120, borderRadius: BorderRadius.all(Radius.circular(20))),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(child: AppSkeleton(height: 90)),
            SizedBox(width: 12),
            Expanded(child: AppSkeleton(height: 90)),
          ],
        ),
        const SizedBox(height: 16),
        const AppSkeleton(height: 60),
        const SizedBox(height: 12),
        const AppSkeleton(height: 60),
        const SizedBox(height: 12),
        const AppSkeleton(height: 60),
      ],
    );
  }
}
