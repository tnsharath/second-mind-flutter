import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/shared/widgets/aura_card.dart';
import '../../../core/shared/widgets/aura_empty_view.dart';
import '../../../core/shared/widgets/aura_error_view.dart';
import '../../../core/shared/widgets/aura_loading.dart';
import '../application/journal_providers.dart';
import '../domain/day_journal.dart';
import '../domain/journal_entry.dart';

class JournalScreen extends HookConsumerWidget {
  const JournalScreen({super.key});

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = _dateOnly(DateTime.now());
    final selectedDate = useState<DateTime>(today);
    final journal = ref.watch(journalProvider(selectedDate.value));
    final isToday = selectedDate.value == today;

    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: Column(
        children: [
          _DateNavigator(
            date: selectedDate.value,
            isToday: isToday,
            onPrevious: () => selectedDate.value = selectedDate.value
                .subtract(const Duration(days: 1)),
            onNext: isToday
                ? null
                : () => selectedDate.value =
                    selectedDate.value.add(const Duration(days: 1)),
          ),
          Expanded(
            child: journal.when(
              loading: () => const AuraLoading(),
              error: (error, _) => AuraErrorView(
                message: 'The journal could not be loaded.',
                onRetry: () =>
                    ref.invalidate(journalProvider(selectedDate.value)),
              ),
              data: (data) => RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(journalProvider(selectedDate.value)),
                child: _JournalBody(journal: data),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({
    required this.date,
    required this.isToday,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime date;
  final bool isToday;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: onPrevious,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE, MMMM d').format(date),
                  style: theme.textTheme.titleMedium,
                ),
                if (isToday)
                  Text(
                    'Today',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _JournalBody extends StatelessWidget {
  const _JournalBody({required this.journal});

  final DayJournal journal;

  @override
  Widget build(BuildContext context) {
    if (journal.entries.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _StatsRow(journal: journal),
          const SizedBox(height: 32),
          const AuraEmptyView(
            title: 'Nothing recorded',
            message: 'This day has no journal entries yet.',
            icon: Icons.auto_stories_outlined,
          ),
        ],
      );
    }

    final sorted = [...journal.entries]..sort((a, b) => a.time.compareTo(b.time));
    final byHour = LinkedHashMap<int, List<JournalEntry>>();
    for (final entry in sorted) {
      byHour.putIfAbsent(entry.time.hour, () => []).add(entry);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        _StatsRow(journal: journal),
        const SizedBox(height: 20),
        for (final group in byHour.entries) ...[
          _HourHeader(time: group.value.first.time),
          for (final entry in group.value) _EntryTile(entry: entry),
        ],
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.journal});

  final DayJournal journal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.center_focus_strong_rounded,
            color: const Color(0xFF6EE7F9),
            value: '${journal.focusMinutes}',
            label: 'focus min',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            icon: Icons.forum_outlined,
            color: const Color(0xFF5B8CFF),
            value: '${journal.conversationsCount}',
            label: 'chats',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            icon: Icons.flag_outlined,
            color: const Color(0xFF4ADE80),
            value: '${journal.goalsCompleted}',
            label: 'goals done',
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AuraCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HourHeader extends StatelessWidget {
  const _HourHeader({required this.time});

  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Text(
        DateFormat('h a').format(time),
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final JournalEntry entry;

  static const Map<JournalKind, (IconData, Color)> _styles = {
    JournalKind.conversation: (Icons.forum_outlined, Color(0xFF5B8CFF)),
    JournalKind.goal: (Icons.flag_outlined, Color(0xFF4ADE80)),
    JournalKind.note: (Icons.notes_rounded, Color(0xFFFBBF24)),
    JournalKind.focus: (Icons.center_focus_strong_rounded, Color(0xFF6EE7F9)),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = _styles[entry.kind]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AuraCard(
        padding: const EdgeInsets.all(14),
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
                    entry.title,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (entry.detail != null) ...[
                    const SizedBox(height: 4),
                    Text(entry.detail!, style: theme.textTheme.bodySmall),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    '${entry.kind.name} · ${DateFormat('HH:mm').format(entry.time)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
