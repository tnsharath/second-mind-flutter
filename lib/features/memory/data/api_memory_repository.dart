import '../../../core/services/api_client.dart';
import '../domain/memory_item.dart';
import '../domain/memory_repository.dart';

/// Real backend implementation — used when USE_MOCK_API=false.
class ApiMemoryRepository implements MemoryRepository {
  ApiMemoryRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<MemoryItem>> getMemories() async {
    final response = await _client.get<List<dynamic>>('/memory');
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((json) => MemoryItem.fromJson(_normalizeId(json)))
        .toList();
  }
}

/// Backend ids are integers; the Dart models use String ids.
Map<String, dynamic> _normalizeId(Map<String, dynamic> json) => {
      ...json,
      'id': json['id'].toString(),
    };
