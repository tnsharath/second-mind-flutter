import 'memory_item.dart';

abstract class MemoryRepository {
  /// GET /memory
  Future<List<MemoryItem>> getMemories();

  /// POST /memory
  Future<MemoryItem> createMemory({
    required String title,
    required String description,
    MemoryCategory category,
    bool isImportant,
  });

  /// PATCH /memory/{id}
  Future<MemoryItem> updateMemory(MemoryItem item);

  /// DELETE /memory/{id}
  Future<void> deleteMemory(String id);
}
