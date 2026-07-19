import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/shared/widgets/aura_card.dart';
import '../../../core/shared/widgets/aura_error_view.dart';
import '../../../core/shared/widgets/aura_loading.dart';
import '../../../core/shared/widgets/section_header.dart';
import '../application/briefing_providers.dart';

class BriefingScreen extends HookConsumerWidget {
  const BriefingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final briefing = ref.watch(todayBriefingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily briefing')),
      body: briefing.when(
        loading: () => const AuraLoading(),
        error: (error, _) => AuraErrorView(
          message: 'The briefing could not be prepared right now.',
          onRetry: () => ref.invalidate(todayBriefingProvider),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(todayBriefingProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                DateFormat('EEEE, MMMM d').format(data.date),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Text(data.headline, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              AuraCard(child: Text(data.summary, style: theme.textTheme.bodyMedium)),
              const SizedBox(height: 12),
              if (data.weather != null)
                AuraCard(
                  child: Row(
                    children: [
                      Icon(Icons.wb_sunny_outlined,
                          size: 30, color: theme.colorScheme.secondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${data.weather!.temperatureC.round()}° · '
                          '${data.weather!.condition} · '
                          'H ${data.weather!.highC?.round() ?? '—'}° / '
                          'L ${data.weather!.lowC?.round() ?? '—'}°',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              const SectionHeader(title: 'Meetings'),
              const SizedBox(height: 10),
              for (final meeting in data.meetings)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AuraCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Text(
                          DateFormat('HH:mm').format(meeting.start),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(meeting.title,
                              style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              const SectionHeader(title: 'Goals'),
              const SizedBox(height: 10),
              AuraCard(
                child: Column(
                  children: [
                    for (final goal in data.goals)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Icon(
                              goal.isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              size: 18,
                              color: goal.isCompleted
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.outline,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(goal.title,
                                  style: theme.textTheme.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const SectionHeader(title: 'AURA suggests'),
              const SizedBox(height: 10),
              for (final suggestion in data.suggestions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AuraCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline_rounded,
                            size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(suggestion,
                              style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
