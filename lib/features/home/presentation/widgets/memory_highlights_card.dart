import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/shared/widgets/aura_card.dart';
import '../../../../core/shared/widgets/aura_loading.dart';
import '../../../../core/shared/widgets/section_header.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../routes/app_router.dart';
import '../../application/home_providers.dart';

class MemoryHighlightsCard extends HookConsumerWidget {
  const MemoryHighlightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(memoryHighlightsProvider);
    final theme = Theme.of(context);
    return AuraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Memory highlights',
            actionLabel: 'View all',
            onAction: () => context.push(AppRoutes.memory),
          ),
          const SizedBox(height: 8),
          memories.when(
            data: (list) {
              if (list.isEmpty) {
                return Text('No memories yet.',
                    style: theme.textTheme.bodySmall);
              }
              return Column(
                children: [
                  for (final memory in list)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              memory.title,
                              style: theme.textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            formatRelative(memory.timestamp),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
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
              ],
            ),
            error: (_, __) => Text('Memories unavailable.',
                style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
