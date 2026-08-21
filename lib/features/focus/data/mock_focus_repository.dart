import '../domain/focus_repository.dart';
import '../domain/focus_session.dart';

/// Serves local dummy focus sessions until the backend endpoint exists.
class MockFocusRepository implements FocusRepository {
  static final List<FocusSession> _sessions = [
    FocusSession(
      id: 'fs1',
      minutes: 25,
      startedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    FocusSession(
      id: 'fs2',
      minutes: 50,
      startedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  @override
  Future<List<FocusSession>> getSessions({DateTime? date}) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (date == null) return List.unmodifiable(_sessions);
    return List.unmodifiable(
      _sessions.where(
        (s) =>
            s.startedAt.year == date.year &&
            s.startedAt.month == date.month &&
            s.startedAt.day == date.day,
      ),
    );
  }

  @override
  Future<FocusSession> logSession({
    required int minutes,
    required DateTime startedAt,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final session = FocusSession(
      id: 'fs${_sessions.length + 1}',
      minutes: minutes,
      startedAt: startedAt,
    );
    _sessions.add(session);
    return session;
  }
}
