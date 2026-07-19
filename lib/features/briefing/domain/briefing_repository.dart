import 'daily_briefing.dart';

abstract class BriefingRepository {
  /// TODO(backend): GET /briefing
  Future<DailyBriefing> getTodayBriefing();
}
