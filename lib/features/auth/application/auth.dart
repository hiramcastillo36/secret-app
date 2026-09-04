import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

export '../data/auth_repository.dart' show meProvider;
export 'auth_controller.dart';

/// Auth / account actions that are not the login-register form (that is
/// [AuthController]). Presentation calls these instead of the repository; the
/// ones that change the bootstrap payload invalidate [meProvider].
class AuthActionsController extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> forgotPassword(String email) => _repo.forgotPassword(email);

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) => _repo.resetPassword(token: token, newPassword: newPassword);

  /// Returns the cooldown (seconds) before the button can be pressed again.
  Future<int> sendEmailVerification() => _repo.sendEmailVerification();

  Future<void> verifyEmail(String token) async {
    await _repo.verifyEmail(token);
    ref.invalidate(meProvider);
  }

  /// Returns the scheduled deletion date.
  Future<DateTime> requestAccountDeletion({
    required String confirmation,
    String? password,
    String? reason,
  }) async {
    final date = await _repo.requestAccountDeletion(
      confirmation: confirmation,
      password: password,
      reason: reason,
    );
    ref.invalidate(meProvider);
    return date;
  }

  Future<void> cancelAccountDeletion() async {
    await _repo.cancelAccountDeletion();
    ref.invalidate(meProvider);
  }

  Future<void> logout(String refreshToken) => _repo.logout(refreshToken);

  /// Sets the avatar to an already-uploaded media id and refreshes the
  /// cached profile.
  Future<void> updateAvatar(String mediaId) async {
    await _repo.updateAvatar(mediaId);
    ref.invalidate(meProvider);
  }

  /// Tells the server which language to use for messages sent outside a
  /// request (reminder emails, weekly recap, push). Fire-and-forget: never
  /// blocks or surfaces an error to the language screen — see
  /// [AuthRepository.updateLocale].
  Future<void> syncLocale(String resolvedTag) => _repo.updateLocale(resolvedTag);
}

final authActionsProvider =
    AutoDisposeNotifierProvider<AuthActionsController, void>(
      AuthActionsController.new,
    );
