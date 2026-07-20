import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/providers/providers.dart';
import '../data/api_briefing_repository.dart';
import '../data/mock_briefing_repository.dart';
import '../domain/briefing_repository.dart';
import '../domain/daily_briefing.dart';

final briefingRepositoryProvider = Provider<BriefingRepository>(
  (ref) => Env.useMockApi
      ? MockBriefingRepository()
      : ApiBriefingRepository(ref.watch(apiClientProvider)),
);

final todayBriefingProvider = FutureProvider<DailyBriefing>(
  (ref) => ref.watch(briefingRepositoryProvider).getTodayBriefing(),
);
