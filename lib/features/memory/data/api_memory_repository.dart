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

  @override
  Future<MemoryItem> createMemory({
    required String title,
    required String description,
    MemoryCategory category = MemoryCategory.note,
    bool isImportant = false,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/memory',
      body: {
        'title': title,
        'description': description,
        'category': category.name,
        'isImportant': isImportant,
      },
    );
    return MemoryItem.fromJson(_normalizeId(response.data ?? const {}));
  }

  @override
  Future<MemoryItem> updateMemory(MemoryItem item) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/memory/${item.id}',
      body: {
        'title': item.title,
        'description': item.description,
        'category': item.category.name,
        'isImportant': item.isImportant,
      },
    );
    return MemoryItem.fromJson(_normalizeId(response.data ?? const {}));
  }

  @override
  Future<void> deleteMemory(String id) async {
    await _client.delete<void>('/memory/$id');
  }
}

/// Backend ids are integers; the Dart models use String ids.
Map<String, dynamic> _normalizeId(Map<String, dynamic> json) => {
      ...json,
      'id': json['id'].toString(),
    };
