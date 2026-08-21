import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/shared/widgets/aura_card.dart';
import '../../../core/shared/widgets/aura_empty_view.dart';
import '../../../core/shared/widgets/aura_error_view.dart';
import '../../../core/shared/widgets/aura_loading.dart';
import '../../../core/shared/widgets/aura_text_field.dart';
import '../../../core/utils/time_format.dart';
import '../../../routes/app_router.dart';
import '../application/search_providers.dart';

class SearchScreen extends HookConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchProvider);
    final search = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: AuraTextField(
          controller: search,
          hint: 'Search everything…',
          prefixIcon: Icons.search_rounded,
          autofocus: true,
          onChanged: (value) =>
              ref.read(searchProvider.notifier).setQuery(value),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (state.isIdle) {
            return const AuraEmptyView(
              title: 'Search AURA',
              message: 'Type at least 2 characters to search memories, goals, conversations and notes.',
              icon: Icons.search_rounded,
            );
          }
          return state.results.when(
            loading: () => const AuraLoading(),
            error: (_, __) => AuraErrorView(
              message: 'Search could not be completed.',
              onRetry: () =>
                  ref.read(searchProvider.notifier).setQuery(state.query),
            ),
            data: (results) {
              if (results.isEmpty) {
                return AuraEmptyView(
                  title: 'No results',
                  message: 'Nothing matches "${state.query.trim()}".',
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  if (results.memories.isNotEmpty) ...[
                    _SectionHeader(
                      label: 'Memories',
                      count: results.memories.length,
                    ),
                    for (final memory in results.memories)
                      _ResultTile(
                        icon: Icons.psychology_outlined,
                        color: const Color(0xFF5B8CFF),
                        title: memory.title,
                        snippet: memory.description,
                        subtitle: formatRelative(memory.timestamp),
                      ),
                  ],
                  if (results.goals.isNotEmpty) ...[
                    _SectionHeader(label: 'Goals', count: results.goals.length),
                    for (final goal in results.goals)
                      _ResultTile(
                        icon: goal.isCompleted
                            ? Icons.check_circle_outline_rounded
                            : Icons.flag_outlined,
                        color: const Color(0xFF4ADE80),
                        title: goal.title,
                        snippet: goal.isCompleted ? 'Completed' : 'In progress',
                        subtitle: goal.dueDate == null
                            ? null
                            : 'Due ${formatRelative(goal.dueDate!)}',
                      ),
                  ],
                  if (results.conversations.isNotEmpty) ...[
                    _SectionHeader(
                      label: 'Conversations',
                      count: results.conversations.length,
                    ),
                    for (final conversation in results.conversations)
                      _ResultTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        color: const Color(0xFF6EE7F9),
                        title: conversation.title,
                        snippet: conversation.preview,
                        subtitle: formatRelative(conversation.updatedAt),
                        onTap: () => context.push(AppRoutes.conversation),
                      ),
                  ],
                  if (results.notes.isNotEmpty) ...[
                    _SectionHeader(label: 'Notes', count: results.notes.length),
                    for (final note in results.notes)
                      _ResultTile(
                        icon: Icons.notes_rounded,
                        color: const Color(0xFFFBBF24),
                        title: note.text,
                        snippet: note.kind,
                        subtitle: note.createdAt == null
                            ? null
                            : formatRelative(note.createdAt!),
                      ),
                  ],
                ],
              );
            },
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

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.snippet,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String snippet;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AuraCard(
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (snippet.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      snippet,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(subtitle!, style: theme.textTheme.bodySmall),
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
