import 'package:aura/features/memory/data/mock_memory_repository.dart';
import 'package:aura/features/memory/domain/memory_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockMemoryRepository', () {
    late MockMemoryRepository repository;

    setUp(() {
      repository = MockMemoryRepository();
    });

    test('seeds memories on first read', () async {
      final memories = await repository.getMemories();
      expect(memories, isNotEmpty);
    });

    test('createMemory prepends a new memory', () async {
      final before = await repository.getMemories();
      final created = await repository.createMemory(
        title: 'Test memory',
        description: 'This is a test memory created from unit tests',
        category: MemoryCategory.goal,
        isImportant: true,
      );

      expect(created.title, 'Test memory');
      expect(created.description, 'This is a test memory created from unit tests');
      expect(created.category, MemoryCategory.goal);
      expect(created.isImportant, isTrue);

      final after = await repository.getMemories();
      expect(after.length, before.length + 1);
      expect(after.first.id, created.id);
    });

    test('updateMemory modifies an existing item', () async {
      final memories = await repository.getMemories();
      final original = memories.first;
      final updated = await repository.updateMemory(
        original.copyWith(title: 'Updated title'),
      );

      expect(updated.title, 'Updated title');

      final fetched = await repository.getMemories();
      final match = fetched.firstWhere((m) => m.id == original.id);
      expect(match.title, 'Updated title');
    });

    test('deleteMemory removes the item', () async {
      final before = await repository.getMemories();
      final target = before.first;
      await repository.deleteMemory(target.id);

      final after = await repository.getMemories();
      expect(after.length, before.length - 1);
      expect(after.any((m) => m.id == target.id), isFalse);
    });
  });
}
