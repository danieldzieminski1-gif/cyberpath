import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../content/data/content_repository.dart';
import '../../content/domain/models.dart';
import '../data/progress_repository.dart';
import '../domain/progress.dart';

final prefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('prefsProvider must be overridden'));

final progressRepoProvider = Provider<ProgressRepository>((ref) => ProgressRepository(ref.watch(prefsProvider)));

final progressProvider = NotifierProvider<ProgressNotifier, UserProgress>(ProgressNotifier.new);

final dueCardsProvider = Provider<List<Flashcard>>((ref) {
  final p = ref.watch(progressProvider);
  final now = DateTime.now();
  return kFlashcards.where((c) {
    final r = p.reviews[c.id];
    return r == null || r.isDue(now);
  }).toList();
});

class ProgressNotifier extends Notifier<UserProgress> {
  ProgressRepository get _repo => ref.read(progressRepoProvider);

  @override
  UserProgress build() => _repo.load();

  void _set(UserProgress p) {
    state = p;
    _repo.save(p);
  }

  void finishOnboarding() => _set(state.copyWith(onboarded: true));

  void setTheme(String mode) => _set(state.copyWith(themeMode: mode));

  LessonOutcome completeLesson(String lessonId, {required int correct, required int total}) {
    final o = ProgressEngine.completeLesson(state, lessonId: lessonId, correct: correct, total: total, now: DateTime.now());
    _set(o.progress);
    return o;
  }

  void recordReview(String cardId, int quality) => _set(ProgressEngine.recordReview(state, cardId, quality, DateTime.now()));

  void recordCommand() => _set(ProgressEngine.recordCommand(state, DateTime.now()));

  void addNote(String title, String body, {String? lessonId}) {
    final now = DateTime.now();
    final note = UserNote(id: now.microsecondsSinceEpoch.toString(), title: title, body: body, lessonId: lessonId, updated: now);
    _set(state.copyWith(notes: [note, ...state.notes]));
  }

  void deleteNote(String id) => _set(state.copyWith(notes: state.notes.where((n) => n.id != id).toList()));

  Future<void> reset() async {
    await _repo.clear();
    state = UserProgress.initial().copyWith(onboarded: true);
    await _repo.save(state);
  }
}
