import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/shared/widgets/aura_card.dart';
import '../../../../core/shared/widgets/aura_loading.dart';
import '../../../../core/shared/widgets/section_header.dart';
import '../../../calendar/application/calendar_providers.dart';

class EventsCard extends HookConsumerWidget {
  const EventsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(upcomingEventsProvider);
    final theme = Theme.of(context);
    return AuraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Upcoming events'),
          const SizedBox(height: 8),
          events.when(
            data: (list) {
              if (list.isEmpty) {
                return Text('Nothing scheduled.',
                    style: theme.textTheme.bodySmall);
              }
              return Column(
                children: [
                  for (final event in list)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 48,
                            child: Text(
                              DateFormat('HH:mm').format(event.start),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 32,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event.title,
                                    style: theme.textTheme.bodyMedium),
                                if (event.location != null)
                                  Text(
                                    event.location!,
                                    style: theme.textTheme.bodySmall,
                                  ),
                              ],
                            ),
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
            error: (_, __) =>
                Text('Events unavailable.', style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
