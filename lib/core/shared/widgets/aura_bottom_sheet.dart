import 'package:flutter/material.dart';

/// Themed modal bottom sheet with a grab handle.
class AuraBottomSheet {
  const AuraBottomSheet._();

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
