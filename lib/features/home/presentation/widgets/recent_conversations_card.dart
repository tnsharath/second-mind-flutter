import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/shared/widgets/aura_card.dart';
import '../../../../core/shared/widgets/aura_loading.dart';
import '../../../../core/shared/widgets/section_header.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../routes/app_router.dart';
import '../../../conversation/application/conversations_providers.dart';

class RecentConversationsCard extends HookConsumerWidget {
  const RecentConversationsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(recentConversationsProvider);
    final theme = Theme.of(context);
    return AuraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Recent conversations'),
          const SizedBox(height: 8),
          conversations.when(
            data: (list) {
              if (list.isEmpty) {
                return Text('No conversations yet.',
                    style: theme.textTheme.bodySmall);
              }
              return Column(
                children: [
                  for (final conversation in list)
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => context.push(AppRoutes.conversation),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    conversation.title,
                                    style: theme.textTheme.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (conversation.preview.isNotEmpty)
                                    Text(
                                      conversation.preview,
                                      style: theme.textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              formatRelative(conversation.updatedAt),
                              style: theme.textTheme.bodySmall,
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
              ],
            ),
            error: (_, __) => Text('Conversations unavailable.',
                style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
