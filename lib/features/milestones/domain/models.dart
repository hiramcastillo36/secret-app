/// A milestone is a threshold on one of the couple's running numbers. The set is
/// a fixed ladder; whether each rung is reached is derived from the summary
/// overview, so there is no dedicated endpoint or stored state.
enum MilestoneKind { dates, streakWeeks, daysTogether }

class Milestone {
  const Milestone({
    required this.kind,
    required this.target,
    required this.current,
  });

  final MilestoneKind kind;
  final int target;
  final int current;

  bool get achieved => current >= target;

  /// 0..1 toward [target]. 1.0 once achieved.
  double get progress =>
      target == 0 ? 1 : (current / target).clamp(0, 1).toDouble();

  String get id => '${kind.name}_$target';
}
