import 'focus_session.dart';

abstract class FocusRepository {
  /// GET /focus/sessions?date=YYYY-MM-DD (all days when omitted)
  Future<List<FocusSession>> getSessions({DateTime? date});

  /// POST /focus/sessions {minutes, startedAt}
  Future<FocusSession> logSession({
    required int minutes,
    required DateTime startedAt,
  });
}
