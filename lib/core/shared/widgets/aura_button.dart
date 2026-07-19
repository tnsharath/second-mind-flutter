import 'package:flutter/material.dart';

enum AuraButtonVariant { primary, tonal, ghost }

/// The single button used across AURA.
class AuraButton extends StatelessWidget {
  const AuraButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AuraButtonVariant.primary,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AuraButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveOnPressed = isLoading ? null : onPressed;

    final Widget content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AuraButtonVariant.ghost
                  ? scheme.onSurface
                  : scheme.onPrimary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final Widget button = switch (variant) {
      AuraButtonVariant.primary =>
        FilledButton(onPressed: effectiveOnPressed, child: content),
      AuraButtonVariant.tonal =>
        FilledButton.tonal(onPressed: effectiveOnPressed, child: content),
      AuraButtonVariant.ghost =>
        OutlinedButton(onPressed: effectiveOnPressed, child: content),
    };

    return SizedBox(width: expand ? double.infinity : null, child: button);
  }
}
