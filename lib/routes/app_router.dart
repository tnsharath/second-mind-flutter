import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/briefing/presentation/briefing_screen.dart';
import '../features/conversation/presentation/conversation_screen.dart';
import '../features/focus/presentation/focus_screen.dart';
import '../features/goals/presentation/goals_screen.dart';
import '../features/habits/presentation/habits_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/journal/presentation/journal_screen.dart';
import '../features/memory/presentation/memory_timeline_screen.dart';
import '../features/notes/presentation/notes_screen.dart';
import '../features/projects/presentation/projects_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/voice/presentation/voice_mode_screen.dart';
import 'app_shell.dart';

class AppRoutes {
  const AppRoutes._();

  static const String splash = '/splash';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String conversation = '/conversation';
  static const String voice = '/voice';
  static const String briefing = '/briefing';
  static const String memory = '/memory';
  static const String settings = '/settings';
  static const String journal = '/journal';
  static const String notes = '/notes';
  static const String goals = '/goals';
  static const String habits = '/habits';
  static const String focus = '/focus';
  static const String search = '/search';
  static const String projects = '/projects';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (authState.isLoading) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }
      final user = authState.valueOrNull;
      if (user == null) {
        return location == AppRoutes.auth ? null : AppRoutes.auth;
      }
      if (location == AppRoutes.auth || location == AppRoutes.splash) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      // Main tabs — tab state persists via the indexed stack.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.conversation,
                builder: (context, state) => const ConversationScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.memory,
                builder: (context, state) => const MemoryTimelineScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.journal,
                builder: (context, state) => const JournalScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Pushed on top of the shell (no bottom nav).
      GoRoute(
        path: AppRoutes.voice,
        builder: (context, state) => const VoiceModeScreen(),
      ),
      GoRoute(
        path: AppRoutes.briefing,
        builder: (context, state) => const BriefingScreen(),
      ),
      GoRoute(
        path: AppRoutes.notes,
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        path: AppRoutes.goals,
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: AppRoutes.habits,
        builder: (context, state) => const HabitsScreen(),
      ),
      GoRoute(
        path: AppRoutes.focus,
        builder: (context, state) => const FocusScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.projects,
        builder: (context, state) => const ProjectsScreen(),
      ),
    ],
  );
});
