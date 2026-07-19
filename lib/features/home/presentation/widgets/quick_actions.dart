import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../routes/app_router.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _QuickAction(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Talk',
            route: AppRoutes.conversation,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickAction(
            icon: Icons.mic_none_rounded,
            label: 'Voice',
            route: AppRoutes.voice,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickAction(
            icon: Icons.wb_twilight_rounded,
            label: 'Briefing',
            route: AppRoutes.briefing,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickAction(
            icon: Icons.psychology_outlined,
            label: 'Memory',
            route: AppRoutes.memory,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => context.push(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
