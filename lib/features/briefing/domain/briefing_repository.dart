import 'daily_briefing.dart';

abstract class BriefingRepository {
  Future<DailyBriefing> getTodayBriefing();
}
