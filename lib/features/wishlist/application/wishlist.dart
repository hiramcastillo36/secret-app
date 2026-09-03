import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/wishlist_repository.dart';
import '../domain/models.dart';

export '../data/wishlist_repository.dart'
    show wishlistProvider, suggestionsProvider;

/// Wishlist actions. Presentation calls these instead of the repository; each
/// mutation invalidates the list.
class WishlistController extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  WishlistRepository get _repo => ref.read(wishlistRepositoryProvider);

  Future<WishItem> create({
    required String title,
    String? placeId,
    String? note,
    String? costBand,
    String? category,
  }) async {
    final item = await _repo.create(
      title: title,
      placeId: placeId,
      note: note,
      costBand: costBand,
      category: category,
    );
    ref.invalidate(wishlistProvider);
    return item;
  }

  Future<WishItem> setStatus(String id, String status) async {
    final item = await _repo.patch(id, status: status);
    ref.invalidate(wishlistProvider);
    return item;
  }

  Future<void> delete(String id, {bool force = false}) async {
    await _repo.delete(id, force: force);
    ref.invalidate(wishlistProvider);
  }

  /// A random open wish for the roulette. Read-only — no invalidation.
  Future<WishItem> pick({bool cheap = false, String? category}) =>
      _repo.pick(cheap: cheap, category: category);
}

final wishlistControllerProvider =
    AutoDisposeNotifierProvider<WishlistController, void>(
      WishlistController.new,
    );
