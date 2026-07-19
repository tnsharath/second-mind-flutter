import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// The AURA mark: a soft gradient orb with a spark.
class AuraLogo extends StatelessWidget {
  const AuraLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.accent],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: size * 0.35,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
        size: size * 0.42,
      ),
    );
  }
}
