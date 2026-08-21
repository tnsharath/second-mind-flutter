import 'package:intl/intl.dart';

import '../domain/day_journal.dart';
import '../domain/journal_entry.dart';
import '../domain/journal_repository.dart';

/// Serves a believable sample day until the backend /journal endpoint exists.
class MockJournalRepository implements JournalRepository {
  @override
  Future<DayJournal> getJournal({DateTime? date}) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final day = date ?? DateTime.now();
    DateTime at(int hour, [int minute = 0]) =>
        DateTime(day.year, day.month, day.day, hour, minute);

    return DayJournal(
      date: DateFormat('yyyy-MM-dd').format(day),
      focusMinutes: 75,
      conversationsCount: 3,
      goalsCompleted: 2,
      entries: [
        JournalEntry(
          time: at(8, 15),
          kind: JournalKind.conversation,
          title: 'Morning briefing with AURA',
          detail: 'Two meetings before lunch — the proposal draft is the '
              'one worth protecting time for.',
        ),
        JournalEntry(
          time: at(9, 0),
          kind: JournalKind.focus,
          title: 'Deep work · 50 min',
          detail: 'Proposal draft, sections 1–2.',
        ),
        JournalEntry(
          time: at(10, 40),
          kind: JournalKind.goal,
          title: 'Goal completed: Morning walk — 20 minutes',
        ),
        JournalEntry(
          time: at(13, 45),
          kind: JournalKind.conversation,
          title: 'Design review follow-up',
          detail: 'Captured action items; review moved to 14:00.',
        ),
        JournalEntry(
          time: at(15, 20),
          kind: JournalKind.note,
          title: 'Book note: "Deep Work" chapter 3',
          detail: 'Schedule shallow work in batches.',
        ),
        JournalEntry(
          time: at(17, 0),
          kind: JournalKind.focus,
          title: 'Deep work · 25 min',
          detail: 'Revised the proposal intro.',
        ),
        JournalEntry(
          time: at(18, 30),
          kind: JournalKind.goal,
          title: 'Goal completed: Read 15 pages of current book',
        ),
        JournalEntry(
          time: at(20, 10),
          kind: JournalKind.conversation,
          title: 'Evening recap',
          detail: 'AURA reserved a reading window after 20:00 tomorrow.',
        ),
      ],
    );
  }
}
