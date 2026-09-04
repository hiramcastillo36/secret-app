import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/protect_repository.dart';

export '../data/protect_repository.dart'
    show
        ActiveFreeze,
        PendingRepair,
        ProtectHub,
        protectHubProvider,
        isoWeekKey;

/// Streak-protection actions (freezes and repairs). Presentation calls these
/// instead of the repository; each refreshes the protection hub.
class ProtectController extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  ProtectRepository get _repo => ref.read(protectRepositoryProvider);

  Future<void> createFreeze({
    required String reason,
    required String startsWeekKey,
    required String endsWeekKey,
  }) async {
    await _repo.createFreeze(
      reason: reason,
      startsWeekKey: startsWeekKey,
      endsWeekKey: endsWeekKey,
    );
    ref.invalidate(protectHubProvider);
  }

  Future<void> cancelFreeze(String id) async {
    await _repo.cancelFreeze(id);
    ref.invalidate(protectHubProvider);
  }

  Future<void> createRepair({
    required DateTime happenedAt,
    String? title,
  }) async {
    await _repo.createRepair(happenedAt: happenedAt, title: title);
    ref.invalidate(protectHubProvider);
  }

  Future<void> respondRepair(String id, String decision) async {
    await _repo.respondRepair(id, decision);
    ref.invalidate(protectHubProvider);
  }
}

final protectControllerProvider =
    AutoDisposeNotifierProvider<ProtectController, void>(ProtectController.new);
