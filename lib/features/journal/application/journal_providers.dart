import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/providers/providers.dart';
import '../data/api_journal_repository.dart';
import '../data/mock_journal_repository.dart';
import '../domain/day_journal.dart';
import '../domain/journal_repository.dart';

final journalRepositoryProvider = Provider<JournalRepository>(
  (ref) => Env.useMockApi
      ? MockJournalRepository()
      : ApiJournalRepository(ref.watch(apiClientProvider)),
);

/// Pass a date-only [DateTime]; today is the sensible default.
final journalProvider = FutureProvider.family<DayJournal, DateTime>(
  (ref, date) => ref.watch(journalRepositoryProvider).getJournal(date: date),
);
