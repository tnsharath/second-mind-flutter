import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../routes/app_router.dart';
import '../../../memory/presentation/widgets/quick_capture_sheet.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  static const List<({IconData icon, String label, String route})> _actions = [
    (
      icon: Icons.chat_bubble_outline_rounded,
      label: 'Talk',
      route: AppRoutes.conversation,
    ),
    (icon: Icons.mic_none_rounded, label: 'Voice', route: AppRoutes.voice),
    (
      icon: Icons.add_circle_outline_rounded,
      label: 'Capture',
      route: '__capture__',
    ),
    (
      icon: Icons.wb_twilight_rounded,
      label: 'Briefing',
      route: AppRoutes.briefing,
    ),
    (
      icon: Icons.psychology_outlined,
      label: 'Memory',
      route: AppRoutes.memory,
    ),
    (icon: Icons.note_outlined, label: 'Notes', route: AppRoutes.notes),
    (
      icon: Icons.center_focus_strong_rounded,
      label: 'Focus',
      route: AppRoutes.focus,
    ),
    (icon: Icons.search_rounded, label: 'Search', route: AppRoutes.search),
    (
      icon: Icons.folder_outlined,
      label: 'Projects',
      route: AppRoutes.projects,
    ),
    (icon: Icons.flag_outlined, label: 'Goals', route: AppRoutes.goals),
    (
      icon: Icons.repeat_rounded,
      label: 'Habits',
      route: AppRoutes.habits,
    ),
  ];

  static const int _columns = 4;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.sm;
        final itemWidth =
            (constraints.maxWidth - spacing * (_columns - 1)) / _columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final action in _actions)
              SizedBox(
                width: itemWidth,
                child: _QuickAction(
                  icon: action.icon,
                  label: action.label,
                  route: action.route,
                ),
              ),
          ],
        );
      },
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
        onTap: () {
          if (route == '__capture__') {
            QuickCaptureSheet.show(context);
          } else {
            context.push(route);
          }
        },
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
