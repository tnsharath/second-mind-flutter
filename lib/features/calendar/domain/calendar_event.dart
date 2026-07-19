import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_event.freezed.dart';
part 'calendar_event.g.dart';

@freezed
class CalendarEvent with _$CalendarEvent {
  const factory CalendarEvent({
    required String id,
    required String title,
    required DateTime start,
    DateTime? end,
    String? location,
  }) = _CalendarEvent;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventFromJson(json);
}
