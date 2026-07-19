import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Three soft pulsing dots shown while AURA composes a reply.
class TypingIndicator extends HookWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++) ...[
              Builder(
                builder: (context) {
                  final phase = (controller.value - i * 0.18) % 1.0;
                  final wave = 0.5 + 0.5 * math.sin(2 * math.pi * phase);
                  return Opacity(
                    opacity: 0.25 + 0.75 * wave,
                    child: Transform.translate(
                      offset: Offset(0, -2.5 * wave),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (i < 2) const SizedBox(width: 5),
            ],
          ],
        );
      },
    );
  }
}
