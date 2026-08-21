import 'package:freezed_annotation/freezed_annotation.dart';

import '../../calendar/domain/calendar_event.dart';
import '../../goals/domain/goal.dart';
import '../../home/domain/weather_info.dart';

part 'daily_briefing.freezed.dart';
part 'daily_briefing.g.dart';

@freezed
class DailyBriefing with _$DailyBriefing {
  const factory DailyBriefing({
    required DateTime date,
    required String headline,
    required String summary,
    WeatherInfo? weather,
    @Default([]) List<CalendarEvent> meetings,
    @Default([]) List<Goal> goals,
    @Default([]) List<String> suggestions,
  }) = _DailyBriefing;

  factory DailyBriefing.fromJson(Map<String, dynamic> json) =>
      _$DailyBriefingFromJson(json);
}
