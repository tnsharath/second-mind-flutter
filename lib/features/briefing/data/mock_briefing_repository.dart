import '../../calendar/data/mock_calendar_repository.dart';
import '../../goals/data/mock_goals_repository.dart';
import '../../home/domain/weather_info.dart';
import '../domain/briefing_repository.dart';
import '../domain/daily_briefing.dart';

/// Composes a briefing from the other mock repositories until
/// the backend /briefing endpoint exists.
class MockBriefingRepository implements BriefingRepository {
  @override
  Future<DailyBriefing> getTodayBriefing() async {
    final meetings = await MockCalendarRepository().getUpcomingEvents();
    final goals = await MockGoalsRepository().getTodayGoals();
    return DailyBriefing(
      date: DateTime.now(),
      headline: 'A clear, focused day ahead',
      summary: 'Two meetings before lunch, then open space for deep work. '
          'Three goals are still open — the proposal draft is the one '
          'worth protecting time for.',
      weather: const WeatherInfo(
        temperatureC: 22,
        condition: 'Clear',
        highC: 26,
        lowC: 17,
      ),
      meetings: meetings,
      goals: goals,
      suggestions: const [
        'Block 45 minutes after the design review for the proposal draft.',
        'You usually read best after 20:00 — I reserved that window.',
        'Standup notes from yesterday are in your memory timeline.',
      ],
    );
  }
}
