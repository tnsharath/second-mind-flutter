import 'auth_user.dart';

abstract class AuthRepository {
  /// Restores a persisted session, if any.
  Future<AuthUser?> getSessionUser();

  /// Google sign-in. Returns null when the user cancels.
  Future<AuthUser?> signInWithGoogle();

  /// "Skip for now" — creates a local guest session.
  Future<AuthUser> continueAsGuest();

  Future<void> signOut();
}
