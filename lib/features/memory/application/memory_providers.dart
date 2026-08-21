import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/providers/providers.dart';
import '../data/api_memory_repository.dart';
import '../data/mock_memory_repository.dart';
import '../domain/memory_item.dart';
import '../domain/memory_repository.dart';

final memoryRepositoryProvider = Provider<MemoryRepository>(
  (ref) => Env.useMockApi
      ? MockMemoryRepository()
      : ApiMemoryRepository(ref.watch(apiClientProvider)),
);

final memoriesProvider =
    AsyncNotifierProvider<MemoriesController, List<MemoryItem>>(
  MemoriesController.new,
);

class MemoriesController extends AsyncNotifier<List<MemoryItem>> {
  MemoryRepository get _repository => ref.read(memoryRepositoryProvider);

  @override
  Future<List<MemoryItem>> build() => _repository.getMemories();

  Future<MemoryItem> create({
    required String title,
    required String description,
    MemoryCategory category = MemoryCategory.note,
    bool isImportant = false,
  }) async {
    final current = state.valueOrNull ?? const <MemoryItem>[];
    try {
      final created = await _repository.createMemory(
        title: title,
        description: description,
        category: category,
        isImportant: isImportant,
      );
      state = AsyncData([created, ...current]);
      return created;
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }

  /// Optimistic update with rollback on failure.
  Future<void> updateMemory(MemoryItem item) async {
    final current = state.valueOrNull ?? const <MemoryItem>[];
    state = AsyncData([
      for (final m in current)
        if (m.id == item.id) item else m,
    ]);
    try {
      final updated = await _repository.updateMemory(item);
      state = AsyncData([
        for (final m in state.valueOrNull ?? current)
          if (m.id == updated.id) updated else m,
      ]);
    } catch (_) {
      state = AsyncData(current);
    }
  }

  Future<void> togglePin(MemoryItem item) =>
      updateMemory(item.copyWith(isImportant: !item.isImportant));

  /// Optimistic delete with rollback on failure.
  Future<void> delete(String id) async {
    final current = state.valueOrNull ?? const <MemoryItem>[];
    state = AsyncData([
      for (final m in current)
        if (m.id != id) m,
    ]);
    try {
      await _repository.deleteMemory(id);
    } catch (_) {
      state = AsyncData(current);
    }
  }
}

final memorySearchProvider = StateProvider<String>((ref) => '');

final filteredMemoriesProvider = Provider<AsyncValue<List<MemoryItem>>>((ref) {
  final query = ref.watch(memorySearchProvider).trim().toLowerCase();
  return ref.watch(memoriesProvider).whenData((memories) {
    if (query.isEmpty) return memories;
    return memories
        .where(
          (m) =>
              m.title.toLowerCase().contains(query) ||
              m.description.toLowerCase().contains(query),
        )
        .toList();
  });
});

bool isToday(DateTime time) {
  final now = DateTime.now();
  return time.year == now.year && time.month == now.month && time.day == now.day;
}
