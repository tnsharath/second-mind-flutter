import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_briefing_repository.dart';
import '../domain/briefing_repository.dart';
import '../domain/daily_briefing.dart';

final briefingRepositoryProvider = Provider<BriefingRepository>(
  (ref) => MockBriefingRepository(),
);

final todayBriefingProvider = FutureProvider<DailyBriefing>(
  (ref) => ref.watch(briefingRepositoryProvider).getTodayBriefing(),
);
