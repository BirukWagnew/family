import 'package:family/features/common/presentation/utils/time_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 14, 12, 0);

  test('formats recent times relative to now', () {
    expect(formatRelativeTime(now.subtract(const Duration(seconds: 10)), now: now), 'Just now');
    expect(formatRelativeTime(now.subtract(const Duration(minutes: 5)), now: now), '5m ago');
    expect(formatRelativeTime(now.subtract(const Duration(hours: 3)), now: now), '3h ago');
    expect(formatRelativeTime(now.subtract(const Duration(days: 2)), now: now), '2d ago');
  });
}
