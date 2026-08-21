import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/shared/widgets/aura_bottom_sheet.dart';
import '../../../core/shared/widgets/aura_button.dart';
import '../../../core/shared/widgets/aura_card.dart';
import '../../../core/shared/widgets/aura_empty_view.dart';
import '../../../core/shared/widgets/aura_error_view.dart';
import '../../../core/shared/widgets/aura_loading.dart';
import '../../../core/shared/widgets/aura_text_field.dart';
import '../../../core/utils/time_format.dart';
import '../application/projects_providers.dart';
import '../domain/project.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends HookConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewProjectSheet(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: projects.when(
        loading: () => const AuraLoading(),
        error: (_, __) => AuraErrorView(
          message: 'Projects could not be loaded.',
          onRetry: () => ref.invalidate(projectsProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const AuraEmptyView(
              title: 'No projects yet',
              message: 'Group notes and goals around what matters to you.',
              icon: Icons.folder_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(projectsProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
              children: [
                for (final project in list) _ProjectTile(project: project),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showNewProjectSheet(BuildContext context, WidgetRef ref) async {
    final result = await AuraBottomSheet.show<(String, String?)>(
      context,
      title: 'New project',
      child: const _NewProjectForm(),
    );
    if (result == null) return;
    final (name, description) = result;
    await ref
        .read(projectsProvider.notifier)
        .createProject(name, description);
  }
}

class _NewProjectForm extends HookConsumerWidget {
  const _NewProjectForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = useTextEditingController();
    final description = useTextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuraTextField(controller: name, hint: 'Project name', autofocus: true),
        const SizedBox(height: 12),
        AuraTextField(controller: description, hint: 'Description (optional)'),
        const SizedBox(height: 16),
        AuraButton(
          label: 'Create project',
          onPressed: () {
            final title = name.text.trim();
            if (title.isEmpty) return;
            final desc = description.text.trim();
            Navigator.of(context).pop((title, desc.isEmpty ? null : desc));
          },
        ),
      ],
    );
  }
}

class _ProjectTile extends ConsumerWidget {
  const _ProjectTile({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(project.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
        ),
        confirmDismiss: (_) => _confirmDelete(context, project),
        onDismissed: (_) =>
            ref.read(projectsProvider.notifier).deleteProject(project),
        child: AuraCard(
          padding: const EdgeInsets.all(14),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProjectDetailScreen(projectId: project.id),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    formatRelative(project.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              if (project.description != null &&
                  project.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  project.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  _CountChip(
                    icon: Icons.notes_rounded,
                    label: '${project.notesCount} notes',
                  ),
                  const SizedBox(width: 8),
                  _CountChip(
                    icon: Icons.flag_outlined,
                    label: '${project.goalsCount} goals',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text('"${project.name}" will be removed. Linked notes and goals are kept.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.outline),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
