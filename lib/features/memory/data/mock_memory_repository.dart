import 'package:uuid/uuid.dart';

import '../domain/memory_item.dart';
import '../domain/memory_repository.dart';

/// Local dummy memories for offline/demo use.
class MockMemoryRepository implements MemoryRepository {
  static List<MemoryItem>? _memories;

  final Uuid _uuid = const Uuid();

  static List<MemoryItem> _seed() {
    final now = DateTime.now();
    return [
      MemoryItem(
        id: 'm1',
        title: 'Prefers concise morning briefings',
        description: 'You asked AURA to keep the morning summary under a minute.',
        category: MemoryCategory.preference,
        timestamp: now.subtract(const Duration(hours: 2)),
        isImportant: true,
      ),
      MemoryItem(
        id: 'm2',
        title: 'Design review moved to 14:00',
        description: 'Rescheduled from 13:00 — calendar updated automatically.',
        category: MemoryCategory.event,
        timestamp: now.subtract(const Duration(hours: 5)),
      ),
      MemoryItem(
        id: 'm3',
        title: 'Goal streak: 4 days of morning walks',
        description: 'One more day to match your best streak.',
        category: MemoryCategory.milestone,
        timestamp: now.subtract(const Duration(hours: 8)),
        isImportant: true,
      ),
      MemoryItem(
        id: 'm4',
        title: 'Book note: "Deep Work" chapter 3',
        description: 'Key idea captured: schedule shallow work in batches.',
        category: MemoryCategory.note,
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      MemoryItem(
        id: 'm5',
        title: 'Mom\'s birthday next Friday',
        description: 'AURA will suggest gift ideas on Monday.',
        category: MemoryCategory.event,
        timestamp: now.subtract(const Duration(days: 1, hours: 6)),
        isImportant: true,
      ),
      MemoryItem(
        id: 'm6',
        title: 'Weekly goal: finish proposal draft',
        description: 'Linked to Friday\'s calendar block.',
        category: MemoryCategory.goal,
        timestamp: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  @override
  Future<List<MemoryItem>> getMemories() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    _memories ??= _seed();
    return List.unmodifiable(_memories!);
  }

  @override
  Future<MemoryItem> createMemory({
    required String title,
    required String description,
    MemoryCategory category = MemoryCategory.note,
    bool isImportant = false,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final memories = _memories ??= _seed();
    final item = MemoryItem(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      timestamp: DateTime.now(),
      isImportant: isImportant,
    );
    memories.insert(0, item);
    return item;
  }

  @override
  Future<MemoryItem> updateMemory(MemoryItem item) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final memories = _memories ??= _seed();
    final index = memories.indexWhere((m) => m.id == item.id);
    if (index >= 0) {
      memories[index] = item;
    }
    return item;
  }

  @override
  Future<void> deleteMemory(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final memories = _memories ??= _seed();
    memories.removeWhere((m) => m.id == id);
  }
}
