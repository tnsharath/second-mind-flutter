import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Centered loading spinner.
class AuraLoading extends StatelessWidget {
  const AuraLoading({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(strokeWidth: 2.4),
      ),
    );
  }
}

/// Skeleton block used for shimmering placeholders.
class AuraShimmerBox extends StatelessWidget {
  const AuraShimmerBox({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.radius = 10,
  });

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerLow,
      highlightColor: scheme.surfaceContainerHighest,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
