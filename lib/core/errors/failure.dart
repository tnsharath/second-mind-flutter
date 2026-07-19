/// Application-wide failure type used to surface friendly messages.
class AppFailure implements Exception {
  const AppFailure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'AppFailure: $message';
}
