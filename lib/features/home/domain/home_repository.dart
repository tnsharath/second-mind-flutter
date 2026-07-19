import 'weather_info.dart';

abstract class HomeRepository {
  /// TODO(backend): GET /context (aggregated "today" summary)
  Future<String> getTodaySummary();

  /// Placeholder until a weather provider is integrated.
  Future<WeatherInfo> getWeather();
}
