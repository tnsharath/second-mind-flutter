import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/reminder_scheduler.dart';
import '../../../core/shared/widgets/aura_bottom_sheet.dart';
import '../../../core/shared/widgets/aura_button.dart';
import '../../../core/shared/widgets/aura_card.dart';
import '../../../core/shared/widgets/aura_empty_view.dart';
import '../../../core/shared/widgets/aura_error_view.dart';
import '../../../core/shared/widgets/aura_loading.dart';
import '../../../core/shared/widgets/aura_text_field.dart';
import '../application/calendar_providers.dart';
import '../domain/calendar_event.dart';

class CalendarScreen extends HookConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsState = ref.watch(upcomingEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar & Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(upcomingEventsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEventFormSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New event'),
      ),
      body: eventsState.when(
        loading: () => const AuraLoading(),
        error: (err, _) => AuraErrorView(
          message: 'Could not load calendar events.',
          onRetry: () => ref.invalidate(upcomingEventsProvider),
        ),
        data: (events) {
          if (events.isEmpty) {
            return const AuraEmptyView(
              title: 'No upcoming events',
              message: 'Tap + to add an event or reminder.',
              icon: Icons.calendar_today_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(upcomingEventsProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
              children: [
                for (final event in events) _EventTile(event: event),
              ],
            ),
          );
        },
      ),
    );
  }
}

Future<void> _showEventFormSheet(
  BuildContext context,
  WidgetRef ref, {
  CalendarEvent? event,
}) async {
  final result = await AuraBottomSheet.show<EventFormResult>(
    context,
    title: event == null ? 'New Event / Reminder' : 'Edit Event',
    child: _EventForm(
      initialTitle: event?.title ?? '',
      initialStart: event?.start ?? DateTime.now().add(const Duration(hours: 1)),
      initialLocation: event?.location ?? '',
    ),
  );
  if (result == null) return;

  if (event == null) {
    await ref.read(upcomingEventsProvider.notifier).create(
          title: result.title,
          start: result.start,
          location: result.location,
        );
  } else {
    await ref.read(upcomingEventsProvider.notifier).updateEvent(
          event.copyWith(
            title: result.title,
            start: result.start,
            location: result.location,
          ),
        );
  }
  await ReminderScheduler.rescheduleAll(ref);
}

typedef EventFormResult = ({String title, DateTime start, String? location});

class _EventForm extends HookConsumerWidget {
  const _EventForm({
    required this.initialTitle,
    required this.initialStart,
    required this.initialLocation,
  });

  final String initialTitle;
  final DateTime initialStart;
  final String initialLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = useTextEditingController(text: initialTitle);
    final location = useTextEditingController(text: initialLocation);
    final startDate = useState<DateTime>(initialStart);
    final startTime = useState<TimeOfDay>(TimeOfDay.fromDateTime(initialStart));

    void submit() {
      final trimmedTitle = title.text.trim();
      if (trimmedTitle.isEmpty) return;

      final dt = DateTime(
        startDate.value.year,
        startDate.value.month,
        startDate.value.day,
        startTime.value.hour,
        startTime.value.minute,
      );

      final loc = location.text.trim();
      Navigator.of(context).pop((
        title: trimmedTitle,
        start: dt,
        location: loc.isEmpty ? null : loc,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuraTextField(
          controller: title,
          hint: 'Event or reminder title',
          autofocus: true,
        ),
        const SizedBox(height: 12),
        AuraTextField(
          controller: location,
          hint: 'Location or link (optional)',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DatePickerTile(
                date: startDate.value,
                onChanged: (val) => startDate.value = val,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TimePickerTile(
                time: startTime.value,
                onChanged: (val) => startTime.value = val,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AuraButton(label: 'Save event', onPressed: submit),
      ],
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({required this.date, required this.onChanged});

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: AuraCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                DateFormat('MMM d, yyyy').format(date),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  const _TimePickerTile({required this.time, required this.onChanged});

  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: AuraCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                time.format(context),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventTile extends ConsumerWidget {
  const _EventTile({required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('EEE, MMM d · h:mm a').format(event.start);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AuraCard(
        padding: const EdgeInsets.all(14),
        onTap: () => _showEventFormSheet(context, ref, event: event),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.event_note_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  if (event.location != null && event.location!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      event.location!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              onPressed: () async {
                await ref.read(upcomingEventsProvider.notifier).delete(event.id);
                await ReminderScheduler.rescheduleAll(ref);
              },
            ),
          ],
        ),
      ),
    );
  }
}
