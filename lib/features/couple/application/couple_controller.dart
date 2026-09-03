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
}

final coupleControllerProvider =
    AutoDisposeNotifierProvider<CoupleController, AsyncValue<Object?>>(
      CoupleController.new,
    );
