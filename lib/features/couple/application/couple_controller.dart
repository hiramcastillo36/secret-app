import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../data/couple_repository.dart';
import '../domain/models.dart';

/// Drives the create-couple and join-couple actions. State is an [AsyncValue]
/// over the resulting couple/join payload.
class CoupleController extends StateNotifier<AsyncValue<Object?>> {
  CoupleController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<Couple?> create({required String name, String? timezone}) async {
    state = const AsyncValue.loading();
    try {
      final couple =
          await _ref.read(coupleRepositoryProvider).create(name: name, timezone: timezone);
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
      final result = await _ref.read(coupleRepositoryProvider).join(inviteCode);
      state = AsyncValue.data(result);
      return result;
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final coupleControllerProvider =
    StateNotifierProvider<CoupleController, AsyncValue<Object?>>((ref) {
  return CoupleController(ref);
});
