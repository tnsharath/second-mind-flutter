import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura/app.dart';
import 'package:aura/features/briefing/application/briefing_providers.dart';
import 'package:aura/features/briefing/data/mock_briefing_repository.dart';
import 'package:aura/features/calendar/application/calendar_providers.dart';
import 'package:aura/features/calendar/data/mock_calendar_repository.dart';
import 'package:aura/features/conversation/application/chat_controller.dart';
import 'package:aura/features/conversation/data/mock_chat_repository.dart';
import 'package:aura/features/goals/application/goals_providers.dart';
import 'package:aura/features/goals/data/mock_goals_repository.dart';
import 'package:aura/features/home/application/home_providers.dart';
import 'package:aura/features/home/data/mock_home_repository.dart';
import 'package:aura/features/memory/application/memory_providers.dart';
import 'package:aura/features/memory/data/mock_memory_repository.dart';

void main() {
  testWidgets('AuraApp builds and renders a MaterialApp', (WidgetTester tester) async {
    // Keep the test hermetic: force the mock repositories regardless of
    // Env.useMockApi so nothing reaches the network.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeRepositoryProvider.overrideWithValue(MockHomeRepository()),
          goalsRepositoryProvider.overrideWithValue(MockGoalsRepository()),
          calendarRepositoryProvider.overrideWithValue(MockCalendarRepository()),
          memoryRepositoryProvider.overrideWithValue(MockMemoryRepository()),
          briefingRepositoryProvider.overrideWithValue(MockBriefingRepository()),
          chatRepositoryProvider.overrideWithValue(MockChatRepository()),
        ],
        child: const AuraApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
