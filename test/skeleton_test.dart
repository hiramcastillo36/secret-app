import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:racha/features/common/skeleton.dart';

void main() {
  testWidgets('SkeletonList renders the requested number of blocks', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SkeletonList(rows: 5, rowHeight: 40)),
      ),
    );
    await tester.pump(); // one frame; don't settle (the shimmer repeats)

    expect(find.byType(SkeletonBox), findsNWidgets(5));
  });

  testWidgets('SkeletonBox is a flat block when motion is reduced', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: Scaffold(body: Center(child: SkeletonBox(width: 100))),
        ),
      ),
    );
    await tester.pumpAndSettle(); // settles because no repeating animation runs

    expect(find.byType(SkeletonBox), findsOneWidget);
  });
}
