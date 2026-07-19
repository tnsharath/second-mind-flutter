import '../domain/home_repository.dart';
import '../domain/weather_info.dart';

class MockHomeRepository implements HomeRepository {
  @override
  Future<String> getTodaySummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return 'Two meetings today, three goals still open, and a clear evening. '
        'AURA will keep an eye on the standup notes for you.';
  }

  @override
  Future<WeatherInfo> getWeather() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const WeatherInfo(
      temperatureC: 22,
      condition: 'Clear',
      highC: 26,
      lowC: 17,
    );
  }
}
