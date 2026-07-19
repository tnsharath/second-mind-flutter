import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/shared/widgets/aura_card.dart';
import '../../../../core/shared/widgets/aura_loading.dart';
import '../../../../core/shared/widgets/section_header.dart';
import '../../../goals/application/goals_providers.dart';

class GoalsCard extends HookConsumerWidget {
  const GoalsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(todayGoalsProvider);
    final theme = Theme.of(context);
    return AuraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: "Today's goals"),
          const SizedBox(height: 8),
          goals.when(
            data: (list) {
              if (list.isEmpty) {
                return Text('No goals yet for today.',
                    style: theme.textTheme.bodySmall);
              }
              return Column(
                children: [
                  for (final goal in list)
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => ref
                          .read(todayGoalsProvider.notifier)
                          .toggle(goal),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              goal.isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              size: 20,
                              color: goal.isCompleted
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.outline,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                goal.title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  decoration: goal.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: goal.isCompleted
                                      ? theme.textTheme.bodySmall?.color
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Column(
              children: [
                AuraShimmerBox(),
                SizedBox(height: 8),
                AuraShimmerBox(),
                SizedBox(height: 8),
                AuraShimmerBox(width: 200),
              ],
            ),
            error: (_, __) =>
                Text('Goals unavailable.', style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
