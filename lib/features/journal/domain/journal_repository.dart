import 'day_journal.dart';

abstract class JournalRepository {
  /// GET /journal?date=YYYY-MM-DD (today when omitted)
  Future<DayJournal> getJournal({DateTime? date});
}
