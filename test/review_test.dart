import 'package:cyberpath/features/progress/domain/progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 2, 9);

  test('successful reviews space out over time', () {
    var r = ReviewState(cardId: 'c', due: now);
    r = r.review(5, now);
    expect(r.intervalDays, 1);
    r = r.review(5, now);
    expect(r.intervalDays, 3);
    r = r.review(5, now);
    expect(r.intervalDays, greaterThan(3));
  });

  test('failing a card resets it and makes it due within the hour', () {
    var r = ReviewState(cardId: 'c', due: now).review(5, now).review(5, now);
    r = r.review(1, now);
    expect(r.reps, 0);
    expect(r.due.difference(now).inMinutes, 10);
    expect(r.ease, greaterThanOrEqualTo(1.3));
  });

  test('isDue respects the due date', () {
    final r = ReviewState(cardId: 'c', due: now.add(const Duration(days: 1)));
    expect(r.isDue(now), isFalse);
    expect(r.isDue(now.add(const Duration(days: 2))), isTrue);
  });
}
