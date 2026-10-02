import 'package:cyberpath/features/progress/data/progress_repository.dart';
import 'package:cyberpath/features/progress/domain/progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime(2026, 10, 2, 9);

  test('first lesson completion awards lesson XP plus 10 per correct answer', () {
    final o = ProgressEngine.completeLesson(const UserProgress(), lessonId: 'linux-1', correct: 3, total: 3, now: now);
    expect(o.xpGained, 60);
    expect(o.progress.xp, 60);
    expect(o.progress.completed, contains('linux-1'));
    expect(o.progress.lessonScores['linux-1'], 100);
  });

  test('repeating a lesson only awards 5 XP and keeps the best score', () {
    final first = ProgressEngine.completeLesson(const UserProgress(), lessonId: 'a', correct: 3, total: 3, now: now).progress;
    final again = ProgressEngine.completeLesson(first, lessonId: 'a', correct: 1, total: 3, now: now);
    expect(again.xpGained, 5);
    expect(again.progress.lessonScores['a'], 100);
  });

  test('quick quiz never marks a lesson complete', () {
    final o = ProgressEngine.completeLesson(const UserProgress(), lessonId: 'quick', correct: 4, total: 5, now: now);
    expect(o.progress.completed, isEmpty);
    expect(o.xpGained, 20);
  });

  test('levels and accuracy', () {
    expect(ProgressEngine.levelFor(0), 1);
    expect(ProgressEngine.levelFor(150), 2);
    expect(ProgressEngine.accuracyPercent(3, 4), 75);
    expect(ProgressEngine.accuracyPercent(0, 0), 100);
  });

  test('achievements unlock once', () {
    final o = ProgressEngine.completeLesson(const UserProgress(), lessonId: 'a', correct: 2, total: 2, now: now);
    final ids = o.unlocked.map((a) => a.id);
    expect(ids, containsAll(['first_steps', 'perfectionist']));
    final o2 = ProgressEngine.completeLesson(o.progress, lessonId: 'b', correct: 1, total: 1, now: now);
    expect(o2.unlocked.map((a) => a.id), isNot(contains('first_steps')));
  });

  test('streak grows on consecutive days and resets after a gap', () {
    var p = ProgressEngine.touch(const UserProgress(), DateTime(2026, 10, 1));
    expect(p.streak, 1);
    p = ProgressEngine.touch(p, DateTime(2026, 10, 2));
    expect(p.streak, 2);
    p = ProgressEngine.touch(p, DateTime(2026, 10, 2, 20));
    expect(p.streak, 2);
    p = ProgressEngine.touch(p, DateTime(2026, 10, 5));
    expect(p.streak, 1);
  });

  test('persistence round trip', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = ProgressRepository(await SharedPreferences.getInstance());
    final p = ProgressEngine.recordReview(const UserProgress().copyWith(xp: 120, completed: {'linux-1'}), 'card-1', 4, now);
    await repo.save(p);
    final loaded = repo.load();
    expect(loaded.xp, p.xp);
    expect(loaded.completed, {'linux-1'});
    expect(loaded.reviews['card-1']!.reps, 1);
  });

  test('corrupted storage falls back to a fresh profile', () async {
    SharedPreferences.setMockInitialValues({'cyberpath.progress.v1': '{not json'});
    final repo = ProgressRepository(await SharedPreferences.getInstance());
    expect(repo.load().xp, 0);
  });
}
