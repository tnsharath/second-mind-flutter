import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// The standard AURA surface: rounded, bordered, softly filled.
class AuraCard extends StatelessWidget {
  const AuraCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(AppSpacing.radiusLg);
    final decoration = BoxDecoration(
      color: color ?? scheme.surfaceContainerLow,
      borderRadius: borderRadius,
      border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
    );
    final effectivePadding = padding ?? AppSpacing.cardPadding;

    if (onTap == null) {
      return Container(
        width: double.infinity,
        padding: effectivePadding,
        decoration: decoration,
        child: child,
      );
    }
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(padding: effectivePadding, child: child),
        ),
      ),
    );
  }
}
