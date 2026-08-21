import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/shared/widgets/aura_card.dart';
import '../../../core/shared/widgets/aura_empty_view.dart';
import '../../../core/shared/widgets/aura_error_view.dart';
import '../../../core/shared/widgets/aura_loading.dart';
import '../../../core/utils/time_format.dart';
import '../application/projects_providers.dart';
import '../domain/project_detail.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(projectDetailProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: Text(detail.valueOrNull?.name ?? 'Project'),
      ),
      body: detail.when(
        loading: () => const AuraLoading(),
        error: (_, __) => AuraErrorView(
          message: 'Project could not be loaded.',
          onRetry: () => ref.invalidate(projectDetailProvider(projectId)),
        ),
        data: (project) {
          final theme = Theme.of(context);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              if (project.description != null &&
                  project.description!.isNotEmpty) ...[
                Text(project.description!, style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
              ],
              Text(
                'Created ${formatRelative(project.createdAt)}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              _SectionHeader(label: 'Notes', count: project.notes.length),
              if (project.notes.isEmpty)
                const AuraEmptyView(
                  title: 'No notes linked',
                  message: 'Link notes to this project to see them here.',
                  icon: Icons.notes_rounded,
                )
              else
                for (final note in project.notes) _NoteTile(note: note),
              const SizedBox(height: 16),
              _SectionHeader(label: 'Goals', count: project.goals.length),
              if (project.goals.isEmpty)
                const AuraEmptyView(
                  title: 'No goals linked',
                  message: 'Link goals to this project to track them here.',
                  icon: Icons.flag_outlined,
                )
              else
                for (final goal in project.goals) _GoalTile(goal: goal),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(width: 8),
          Text('$count', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note});

  final ProjectNote note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AuraCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              note.done
                  ? Icons.check_circle_outline_rounded
                  : Icons.notes_rounded,
              size: 18,
              color: note.done
                  ? const Color(0xFF4ADE80)
                  : theme.colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      decoration:
                          note.done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (note.createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${note.kind} · ${formatRelative(note.createdAt!)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({required this.goal});

  final ProjectGoal goal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = goal.progress.clamp(0, 100);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AuraCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              goal.isCompleted
                  ? Icons.check_circle_outline_rounded
                  : Icons.flag_outlined,
              size: 18,
              color: goal.isCompleted
                  ? const Color(0xFF4ADE80)
                  : theme.colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      decoration:
                          goal.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: percent / 100,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text('$percent%', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
