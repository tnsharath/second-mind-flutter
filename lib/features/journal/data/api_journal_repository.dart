import 'package:intl/intl.dart';

import '../../../core/services/api_client.dart';
import '../domain/day_journal.dart';
import '../domain/journal_entry.dart';
import '../domain/journal_repository.dart';

/// Real backend implementation — used when USE_MOCK_API=false.
class ApiJournalRepository implements JournalRepository {
  ApiJournalRepository(this._client);

  final ApiClient _client;

  @override
  Future<DayJournal> getJournal({DateTime? date}) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date ?? DateTime.now());
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/journal',
        query: date == null ? null : {'date': formattedDate},
      );
      final raw = response.data;
      if (raw == null) return _emptyJournal(formattedDate);
      final json = Map<String, dynamic>.from(raw);
      return DayJournal(
        date: (json['date'] ?? formattedDate).toString(),
        focusMinutes: (json['focusMinutes'] as num?)?.toInt() ?? 0,
        conversationsCount: (json['conversationsCount'] as num?)?.toInt() ?? 0,
        goalsCompleted: (json['goalsCompleted'] as num?)?.toInt() ?? 0,
        entries: (json['entries'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .map((e) => _parseJournalEntry(e))
                .whereType<JournalEntry>()
                .toList() ??
            const [],
      );
    } catch (_) {
      return _emptyJournal(formattedDate);
    }
  }

  DayJournal _emptyJournal(String dateStr) => DayJournal(
        date: dateStr,
        focusMinutes: 0,
        conversationsCount: 0,
        goalsCompleted: 0,
        entries: const [],
      );

  JournalEntry? _parseJournalEntry(Map<String, dynamic> map) {
    try {
      final kindStr = map['kind']?.toString().toLowerCase() ?? 'note';
      final kind = switch (kindStr) {
        'conversation' || 'chat' => JournalKind.conversation,
        'goal' => JournalKind.goal,
        'focus' => JournalKind.focus,
        _ => JournalKind.note,
      };
      final timeStr = map['time']?.toString() ?? map['createdAt']?.toString();
      final time = timeStr != null ? DateTime.tryParse(timeStr) ?? DateTime.now() : DateTime.now();
      return JournalEntry(
        time: time,
        kind: kind,
        title: map['title']?.toString() ?? map['text']?.toString() ?? 'Journal entry',
        detail: map['detail']?.toString() ?? map['description']?.toString(),
      );
    } catch (_) {
      return null;
    }
  }
}
