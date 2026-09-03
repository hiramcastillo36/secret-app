import 'package:flutter_test/flutter_test.dart';
import 'package:racha/features/streak/data/protect_repository.dart';

void main() {
  test('isoWeekKey matches ISO-8601 (Monday-based), locale-independent', () {
    // 2026-01-01 is a Thursday → ISO week 1 of 2026.
    expect(isoWeekKey(DateTime(2026, 1, 1)), '2026-W01');
    // 2026-01-04 (Sunday) is still ISO week 1.
    expect(isoWeekKey(DateTime(2026, 1, 4)), '2026-W01');
    // 2026-01-05 (Monday) starts ISO week 2.
    expect(isoWeekKey(DateTime(2026, 1, 5)), '2026-W02');
    // 2025-12-29 (Monday) belongs to ISO week 1 of 2026 (year rolls forward).
    expect(isoWeekKey(DateTime(2025, 12, 29)), '2026-W01');
    // Mid-year sanity: 2026-08-29 (Saturday).
    expect(isoWeekKey(DateTime(2026, 8, 29)), '2026-W35');
  });
}
