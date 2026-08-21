import 'package:intl/intl.dart';

import '../../../core/services/api_client.dart';
import '../domain/day_journal.dart';
import '../domain/journal_repository.dart';

/// Real backend implementation — used when USE_MOCK_API=false.
class ApiJournalRepository implements JournalRepository {
  ApiJournalRepository(this._client);

  final ApiClient _client;

  @override
  Future<DayJournal> getJournal({DateTime? date}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/journal',
      query:
          date == null ? null : {'date': DateFormat('yyyy-MM-dd').format(date)},
    );
    final json = Map<String, dynamic>.from(response.data ?? const {});
    return DayJournal.fromJson(json);
  }
}
