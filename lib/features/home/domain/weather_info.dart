import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_info.freezed.dart';
part 'weather_info.g.dart';

/// Placeholder weather model — a real provider plugs in later.
@freezed
class WeatherInfo with _$WeatherInfo {
  const factory WeatherInfo({
    required double temperatureC,
    required String condition,
    double? highC,
    double? lowC,
  }) = _WeatherInfo;

  factory WeatherInfo.fromJson(Map<String, dynamic> json) =>
      _$WeatherInfoFromJson(json);
}
