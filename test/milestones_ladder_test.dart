import 'package:flutter_test/flutter_test.dart';

import 'package:racha/features/milestones/domain/models.dart';

void main() {
  test('a rung is reached once the current number passes its target', () {
    const reached = Milestone(kind: MilestoneKind.dates, target: 10, current: 12);
    const notYet = Milestone(kind: MilestoneKind.dates, target: 25, current: 12);

    expect(reached.achieved, isTrue);
    expect(reached.progress, 1.0);

    expect(notYet.achieved, isFalse);
    expect(notYet.progress, closeTo(0.48, 0.001));
  });

  test('progress never exceeds 1 and id is stable per kind+target', () {
    const m = Milestone(kind: MilestoneKind.streakWeeks, target: 4, current: 40);
    expect(m.progress, 1.0);
    expect(m.id, 'streakWeeks_4');
  });
}
