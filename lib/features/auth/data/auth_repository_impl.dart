import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/failure.dart';
import '../../../core/services/secure_storage_service.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._storage);

  final AuraSecureStorage _storage;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
  );
  final Uuid _uuid = const Uuid();

  @override
  Future<AuthUser?> getSessionUser() async {
    try {
      final json = await _storage.readUserJson();
      if (json == null) return null;
      return AuthUser.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null; // user cancelled
      final auth = await account.authentication;
      final user = AuthUser(
        id: account.id,
        name: account.displayName ?? 'AURA User',
        email: account.email,
        photoUrl: account.photoUrl,
      );
      await _storage.saveUserJson(jsonEncode(user.toJson()));
      final token = auth.idToken;
      if (token != null) await _storage.saveToken(token);
      // TODO(backend): exchange the Google idToken with the FastAPI backend
      // for an AURA session token once auth endpoints exist.
      return user;
    } catch (e) {
      throw AppFailure(
        'Google sign-in failed. You can also skip for now.',
        cause: e,
      );
    }
  }

  @override
  Future<AuthUser> continueAsGuest() async {
    final guest = AuthUser(
      id: _uuid.v4(),
      name: 'Explorer',
      email: '',
      isGuest: true,
    );
    await _storage.saveUserJson(jsonEncode(guest.toJson()));
    return guest;
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Best effort — local session is cleared regardless.
    }
    await _storage.clear();
  }
}
