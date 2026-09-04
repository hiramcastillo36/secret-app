import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../data/couple_repository.dart';
import '../domain/models.dart';

/// Drives the create-couple and join-couple actions. State is an [AsyncValue]
/// over the resulting couple/join payload.
///
/// `autoDispose`: create and join share this provider, so without it the error
/// from one leaks onto the other screen. It is a `Notifier` —
/// `StateNotifierProvider` is removed in Riverpod 3.
class CoupleController extends AutoDisposeNotifier<AsyncValue<Object?>> {
  @override
  AsyncValue<Object?> build() => const AsyncValue.data(null);

  Future<Couple?> create({required String name, String? timezone}) async {
    state = const AsyncValue.loading();
    try {
      final couple = await ref
          .read(coupleRepositoryProvider)
          .create(name: name, timezone: timezone);
      state = AsyncValue.data(couple);
      return couple;
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<JoinResult?> join(String inviteCode) async {
    state = const AsyncValue.loading();
    try {
      final result = await ref.read(coupleRepositoryProvider).join(inviteCode);
      state = AsyncValue.data(result);
      return result;
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Drops a stale error so it does not surface on the sibling screen — create
  /// and join share this provider (audit F-H11). Screens call it on mount.
  void clearError() {
    if (state.hasError) state = const AsyncValue.data(null);
  }

  /// Change the couple name and/or timezone from settings (audit F, low: the
  /// zone was set once at creation and never editable). Throws [ApiException]
  /// on failure so the caller can surface it.
  Future<void> updateSettings({String? name, String? timezone}) async {
    await ref
        .read(coupleRepositoryProvider)
        .updateSettings(name: name, timezone: timezone);
    ref.invalidate(coupleMeProvider);
  }

  /// Issue a fresh invite code, replacing whatever was shared before. Throws
  /// [ApiException] on failure so the caller can surface it.
  Future<void> rotateInvite() async {
    await ref.read(coupleRepositoryProvider).rotateInvite();
    ref.invalidate(coupleMeProvider);
  }
}

final coupleControllerProvider =
    AutoDisposeNotifierProvider<CoupleController, AsyncValue<Object?>>(
      CoupleController.new,
    );
