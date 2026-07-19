import '../domain/memory_item.dart';
import '../domain/memory_repository.dart';

/// Local dummy memories until the backend /memory endpoint exists.
class MockMemoryRepository implements MemoryRepository {
  @override
  Future<List<MemoryItem>> getMemories() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
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
}
