import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(secureStorageProvider)),
);

final authStateProvider = AsyncNotifierProvider<AuthController, AuthUser?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AuthUser?> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<AuthUser?> build() => _repository.getSessionUser();

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => _repository.signInWithGoogle(),
    );
  }

  Future<void> continueAsGuest() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => _repository.continueAsGuest());
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AsyncData(null);
  }
}
