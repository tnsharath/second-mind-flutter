import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/voice_session_state.dart';

/// The breathing orb at the heart of voice mode.
class VoiceOrb extends HookWidget {
  const VoiceOrb({super.key, required this.phase});

  final VoicePhase phase;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    final intensity = switch (phase) {
      VoicePhase.idle => 0.35,
      VoicePhase.listening => 0.9,
      VoicePhase.thinking => 0.6,
      VoicePhase.speaking => 1.0,
    };

    final icon = switch (phase) {
      VoicePhase.idle => Icons.mic_none_rounded,
      VoicePhase.listening => Icons.mic_rounded,
      VoicePhase.thinking => Icons.psychology_outlined,
      VoicePhase.speaking => Icons.graphic_eq_rounded,
    };

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final wave = Curves.easeInOut.transform(controller.value);
        final glow = intensity * (0.7 + 0.3 * wave);
        return SizedBox(
          width: 230,
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _GlowCircle(size: 220 + 10 * wave, opacity: 0.05 * glow),
              _GlowCircle(size: 175 + 8 * wave, opacity: 0.10 * glow),
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        AppColors.primary.withValues(alpha: 0.6),
                        AppColors.primary,
                        intensity,
                      )!,
                      Color.lerp(
                        AppColors.accent.withValues(alpha: 0.6),
                        AppColors.accent,
                        intensity,
                      )!,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.45 * glow),
                      blurRadius: 48,
                      spreadRadius: math.max(0, 8 * glow),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 44),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.accent.withValues(alpha: opacity),
          width: 1.2,
        ),
      ),
    );
  }
}
