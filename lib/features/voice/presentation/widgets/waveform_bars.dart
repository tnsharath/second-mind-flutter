import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/theme/app_colors.dart';

/// Soft animated waveform shown while listening / speaking.
class WaveformBars extends HookWidget {
  const WaveformBars({super.key, this.barCount = 26, this.height = 44});

  final int barCount;
  final double height;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1100),
    )..repeat();
    final seeds = useMemoized(
      () => List<double>.generate(barCount, (i) => (i * 0.7) % 3.14),
      [barCount],
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value * 2 * math.pi;
        return SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < barCount; i++)
                Container(
                  width: 3,
                  height: 6 +
                      (height - 10) *
                          (0.5 + 0.5 * math.sin(t + seeds[i])) *
                          (0.4 + 0.6 * ((i % 5) / 4)),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
