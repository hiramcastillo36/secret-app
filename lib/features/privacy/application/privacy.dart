import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/privacy_repository.dart';

export '../data/privacy_repository.dart'
    show PrivacySettings, privacySettingsProvider;

/// Privacy-screen actions. Presentation calls these instead of the repository;
/// each invalidates the read providers it affects.
class PrivacyController extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  PrivacyRepository get _repo => ref.read(privacyRepositoryProvider);

  Future<PrivacySettings> save(Map<String, dynamic> changes) async {
    final updated = await _repo.patch(changes);
    ref.invalidate(privacySettingsProvider);
    return updated;
  }

  Future<void> requestDataExport() => _repo.requestDataExport();

  Future<void> leaveCouple() => _repo.leaveCouple();
}

final privacyControllerProvider =
    AutoDisposeNotifierProvider<PrivacyController, void>(PrivacyController.new);
