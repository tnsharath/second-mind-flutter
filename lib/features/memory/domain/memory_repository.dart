import 'memory_item.dart';

abstract class MemoryRepository {
  /// TODO(backend): GET /memory
  Future<List<MemoryItem>> getMemories();
}
