import 'package:freezed_annotation/freezed_annotation.dart';

part 'journal_entry.freezed.dart';
part 'journal_entry.g.dart';

/// Matches the lowercase `kind` strings sent by the backend.
enum JournalKind { conversation, goal, note, focus }

@freezed
class JournalEntry with _$JournalEntry {
  const factory JournalEntry({
    required DateTime time,
    required JournalKind kind,
    required String title,
    String? detail,
  }) = _JournalEntry;

  factory JournalEntry.fromJson(Map<String, dynamic> json) =>
      _$JournalEntryFromJson(json);
}
