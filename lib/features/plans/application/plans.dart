import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/plans_repository.dart';
import '../domain/models.dart';

export '../data/plans_repository.dart'
    show plansListProvider, planProvider, calendarProvider;

/// Plan actions. Presentation calls these instead of the repository; each
/// mutation invalidates the plan list and, where relevant, the single plan.
class PlansController extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  PlansRepository get _repo => ref.read(plansRepositoryProvider);

  void _refresh([String? id]) {
    ref.invalidate(plansListProvider);
    if (id != null) ref.invalidate(planProvider(id));
  }

  Future<Plan> create({
    String title = '',
    String? placeId,
    DateTime? scheduledAt,
    bool hasTime = false,
    String? notes,
    String? wishlistItemId,
  }) async {
    final plan = await _repo.create(
      title: title,
      placeId: placeId,
      scheduledAt: scheduledAt,
      hasTime: hasTime,
      notes: notes,
      wishlistItemId: wishlistItemId,
    );
    _refresh();
    return plan;
  }

  Future<Plan> reschedule(
    String id, {
    required DateTime scheduledAt,
    required bool hasTime,
  }) async {
    final plan = await _repo.patch(
      id,
      scheduledAt: scheduledAt,
      hasTime: hasTime,
    );
    _refresh(id);
    return plan;
  }

  Future<Plan> respond(String id, String decision, {String? note}) async {
    final plan = await _repo.respond(id, decision, note: note);
    _refresh(id);
    return plan;
  }

  Future<Plan> cancel(String id) async {
    final plan = await _repo.cancel(id);
    _refresh(id);
    return plan;
  }

  /// Turns a plan into a date. Returns the new date id. Callers still refresh
  /// the streak themselves (cross-feature).
  Future<String> complete(
    String id, {
    required DateTime happenedAt,
    String? title,
    String? placeId,
    int? rating,
    double? cost,
    String? notes,
  }) async {
    final dateId = await _repo.complete(
      id,
      happenedAt: happenedAt,
      title: title,
      placeId: placeId,
      rating: rating,
      cost: cost,
      notes: notes,
    );
    _refresh(id);
    return dateId;
  }
}

final plansControllerProvider =
    AutoDisposeNotifierProvider<PlansController, void>(PlansController.new);
