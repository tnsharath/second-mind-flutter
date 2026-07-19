import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around [FlutterSecureStorage] for tokens and session data.
class AuraSecureStorage {
  AuraSecureStorage();

  static const String _tokenKey = 'aura_auth_token';
  static const String _userKey = 'aura_user_json';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveUserJson(String json) =>
      _storage.write(key: _userKey, value: json);

  Future<String?> readUserJson() => _storage.read(key: _userKey);

  Future<void> clear() => _storage.deleteAll();
}
