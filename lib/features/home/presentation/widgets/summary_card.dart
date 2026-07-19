import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/shared/widgets/aura_card.dart';
import '../../../../core/shared/widgets/aura_loading.dart';
import '../../../../core/shared/widgets/section_header.dart';
import '../../application/home_providers.dart';

class SummaryCard extends HookConsumerWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(todaySummaryProvider);
    final theme = Theme.of(context);
    return AuraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: "Today's summary"),
          const SizedBox(height: 10),
          summary.when(
            data: (text) => Text(text, style: theme.textTheme.bodyMedium),
            loading: () => const Column(
              children: [
                AuraShimmerBox(),
                SizedBox(height: 8),
                AuraShimmerBox(width: 220),
              ],
            ),
            error: (_, __) => Text(
              'Summary unavailable right now.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
