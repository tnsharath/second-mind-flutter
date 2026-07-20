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

final memoriesProvider = FutureProvider<List<MemoryItem>>(
  (ref) => ref.watch(memoryRepositoryProvider).getMemories(),
);

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
