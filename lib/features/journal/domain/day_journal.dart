import 'package:freezed_annotation/freezed_annotation.dart';

import 'journal_entry.dart';

part 'day_journal.freezed.dart';
part 'day_journal.g.dart';

@freezed
class DayJournal with _$DayJournal {
  const factory DayJournal({
    required String date,
    required int focusMinutes,
    required int conversationsCount,
    required int goalsCompleted,
    @Default([]) List<JournalEntry> entries,
  }) = _DayJournal;

  factory DayJournal.fromJson(Map<String, dynamic> json) =>
      _$DayJournalFromJson(json);
}
