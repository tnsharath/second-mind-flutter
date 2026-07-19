/// Environment configuration.
///
/// Values are injected at build time with --dart-define so that no
/// environment-specific URL is ever hardcoded in source:
///
///   flutter build apk --dart-define=API_BASE_URL=https://api.aura.dev \
///                     --dart-define=USE_MOCK_API=false
class Env {
  const Env._();

  /// Base URL of the FastAPI backend (REST).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.aura.example.com',
  );

  /// Base URL of the FastAPI backend (WebSocket).
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'wss://api.aura.example.com/ws',
  );

  /// When true, feature repositories serve local mock data instead of
  /// calling the backend. Flip to false once the FastAPI backend exists.
  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: true,
  );
}
