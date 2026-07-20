import '../../../core/services/api_client.dart';
import '../domain/home_repository.dart';
import '../domain/weather_info.dart';

/// Real backend implementation — used when USE_MOCK_API=false.
class ApiHomeRepository implements HomeRepository {
  ApiHomeRepository(this._client);

  final ApiClient _client;

  @override
  Future<String> getTodaySummary() async {
    final response = await _client.get<Map<String, dynamic>>('/summary');
    final summary = response.data?['summary'];
    return summary is String ? summary : '';
  }

  @override
  Future<WeatherInfo> getWeather() async {
    final response = await _client.get<Map<String, dynamic>>('/weather');
    return WeatherInfo.fromJson(response.data ?? const {});
  }
}
