import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../routes/app_router.dart';
import '../../auth/application/auth_controller.dart';
import '../../calendar/application/calendar_providers.dart';
import '../../conversation/application/conversations_providers.dart';
import '../../goals/application/goals_providers.dart';
import '../application/home_providers.dart';
import 'widgets/events_card.dart';
import 'widgets/goals_card.dart';
import 'widgets/greeting_header.dart';
import 'widgets/memory_highlights_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_conversations_card.dart';
import 'widgets/summary_card.dart';
import 'widgets/weather_card.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = useStream(
          useMemoized(
            () => Stream<DateTime>.periodic(
              const Duration(seconds: 1),
              (_) => DateTime.now(),
            ),
          ),
          initialData: DateTime.now(),
        ).data ??
        DateTime.now();
    final user = ref.watch(authStateProvider).valueOrNull;
    final isOffline = ref.watch(isOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AURA',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(letterSpacing: 4, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundImage:
                  user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
              child: user?.photoUrl == null
                  ? Text(
                      (user?.name.isNotEmpty == true ? user!.name[0] : 'A')
                          .toUpperCase(),
                      style: const TextStyle(fontSize: 13),
                    )
                  : null,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todaySummaryProvider);
          ref.invalidate(weatherProvider);
          ref.invalidate(todayGoalsProvider);
          ref.invalidate(upcomingEventsProvider);
          ref.invalidate(memoryHighlightsProvider);
          ref.invalidate(recentConversationsProvider);
          await Future<void>.delayed(const Duration(milliseconds: 400));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            if (isOffline) ...[
              const _OfflineBanner(),
              const SizedBox(height: AppSpacing.md),
            ],
            GreetingHeader(now: now, name: user?.name ?? 'there'),
            const SizedBox(height: AppSpacing.lg),
            const SummaryCard(),
            const SizedBox(height: AppSpacing.md),
            const WeatherCard(),
            const SizedBox(height: AppSpacing.md),
            const GoalsCard(),
            const SizedBox(height: AppSpacing.md),
            const EventsCard(),
            const SizedBox(height: AppSpacing.md),
            const MemoryHighlightsCard(),
            const SizedBox(height: AppSpacing.md),
            const RecentConversationsCard(),
            const SizedBox(height: AppSpacing.lg),
            const QuickActions(),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "You're offline — showing cached data.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
