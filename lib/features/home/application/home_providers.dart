import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/providers/providers.dart';
import '../../memory/application/memory_providers.dart';
import '../../memory/domain/memory_item.dart';
import '../data/api_home_repository.dart';
import '../data/mock_home_repository.dart';
import '../domain/home_repository.dart';
import '../domain/weather_info.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => Env.useMockApi
      ? MockHomeRepository()
      : ApiHomeRepository(ref.watch(apiClientProvider)),
);

final todaySummaryProvider = FutureProvider<String>(
  (ref) => ref.watch(homeRepositoryProvider).getTodaySummary(),
);

final weatherProvider = FutureProvider<WeatherInfo>(
  (ref) => ref.watch(homeRepositoryProvider).getWeather(),
);

/// Important memories surfaced on the home dashboard.
final memoryHighlightsProvider = FutureProvider<List<MemoryItem>>((ref) async {
  final memories = await ref.watch(memoryRepositoryProvider).getMemories();
  final important = memories.where((m) => m.isImportant).toList();
  return (important.isNotEmpty ? important : memories).take(3).toList();
});

/// True when the device reports no connectivity.
final isOfflineProvider = Provider<bool>((ref) {
  final results = ref.watch(connectivityProvider).valueOrNull;
  if (results == null) return false;
  return results.isEmpty || results.contains(ConnectivityResult.none);
});
