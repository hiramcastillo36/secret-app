import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/token_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Single source of truth for "is there a session". The router listens to this
/// and redirects; the dio refresh interceptor flips it to [unauthenticated] when
/// a refresh fails.
class SessionController extends StateNotifier<AuthStatus> {
  SessionController(this._storage) : super(AuthStatus.unknown);

  final TokenStorage _storage;

  /// Called once at startup. Presence of a refresh token is enough to enter the
  /// authenticated branch; the splash screen then calls GET /me to decide the
  /// concrete landing route.
  Future<void> bootstrap() async {
    final refresh = await _storage.readRefresh();
    state = (refresh == null || refresh.isEmpty)
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
  }

  Future<void> onSignedIn({required String access, required String refresh}) async {
    await _storage.save(access: access, refresh: refresh);
    state = AuthStatus.authenticated;
  }

  Future<void> signOut() async {
    await _storage.clear();
    state = AuthStatus.unauthenticated;
  }
}

final sessionControllerProvider =
    StateNotifierProvider<SessionController, AuthStatus>((ref) {
  return SessionController(ref.watch(tokenStorageProvider));
});
