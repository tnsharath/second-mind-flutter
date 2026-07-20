/// Environment configuration.
///
/// Values are injected at build time with --dart-define so that no
/// environment-specific URL is ever hardcoded in source:
///
///   flutter build apk --dart-define=API_BASE_URL=https://second-mind-backend.vercel.app \
///                     --dart-define=USE_MOCK_API=false
///
/// On the Android emulator, localhost refers to the emulator itself, so
/// point at the host machine instead:
///
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
class Env {
  const Env._();

  /// Base URL of the FastAPI backend (REST). No trailing slash — endpoint
  /// paths start with '/'.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://second-mind-backend.vercel.app',
  );

  /// Base URL of the FastAPI backend (WebSocket).
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'wss://api.aura.example.com/ws',
  );

  /// When true, feature repositories serve local mock data instead of
  /// calling the backend.
  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: false,
  );
}
