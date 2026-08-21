import 'weather_info.dart';

abstract class HomeRepository {
  /// GET /summary
  Future<String> getTodaySummary();

  /// Placeholder until a weather provider is integrated.
  Future<WeatherInfo> getWeather();
}
