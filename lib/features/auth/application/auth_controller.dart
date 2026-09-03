import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/auth/session_controller.dart';
import '../data/auth_repository.dart';
import '../domain/models.dart';

/// Drives the login and register forms. State is an [AsyncValue] over the
/// resulting session so the screen can show a spinner, an inline error, or
/// navigate on success.
class AuthController extends StateNotifier<AsyncValue<AuthSession?>> {
  AuthController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<AuthSession?> register({
    required String email,
    required String password,
    required String displayName,
    String? timezone,
  }) =>
      _run(() => _ref.read(authRepositoryProvider).register(
            email: email,
            password: password,
            displayName: displayName,
            timezone: timezone,
          ));

  Future<AuthSession?> login({required String email, required String password}) =>
      _run(() => _ref.read(authRepositoryProvider).login(email: email, password: password));

  Future<AuthSession?> _run(Future<AuthSession> Function() op) async {
    state = const AsyncValue.loading();
    try {
      final session = await op();
      await _ref.read(sessionControllerProvider.notifier).onSignedIn(
            access: session.accessToken,
            refresh: session.refreshToken,
          );
      state = AsyncValue.data(session);
      return session;
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  void clearError() {
    if (state.hasError) state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthSession?>>((ref) {
  return AuthController(ref);
});
