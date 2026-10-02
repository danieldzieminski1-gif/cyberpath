import 'dart:math';

class ReviewState {
  const ReviewState({required this.cardId, this.ease = 2.5, this.intervalDays = 0, this.reps = 0, required this.due});
  final String cardId;
  final double ease;
  final int intervalDays;
  final int reps;
  final DateTime due;

  bool isDue(DateTime now) => !due.isAfter(now);

  /// Simplified SM-2. quality: 1 = again, 3 = hard, 4 = good, 5 = easy.
  ReviewState review(int quality, DateTime now) {
    if (quality < 3) {
      return ReviewState(cardId: cardId, ease: max(1.3, ease - 0.2), intervalDays: 0, reps: 0, due: now.add(const Duration(minutes: 10)));
    }
    final r = reps + 1;
    final days = r == 1 ? 1 : (r == 2 ? 3 : max(1, (intervalDays * ease).round()));
    final q = 5 - quality;
    final e = max(1.3, ease + 0.1 - q * (0.08 + q * 0.02));
    return ReviewState(cardId: cardId, ease: e, intervalDays: days, reps: r, due: now.add(Duration(days: days)));
  }

  Map<String, dynamic> toJson() => {'id': cardId, 'ease': ease, 'interval': intervalDays, 'reps': reps, 'due': due.toIso8601String()};

  factory ReviewState.fromJson(Map<String, dynamic> j) => ReviewState(
        cardId: j['id'] as String,
        ease: (j['ease'] as num).toDouble(),
        intervalDays: j['interval'] as int,
        reps: j['reps'] as int,
        due: DateTime.parse(j['due'] as String),
      );
}

class UserNote {
  const UserNote({required this.id, required this.title, required this.body, this.lessonId, required this.updated});
  final String id;
  final String title;
  final String body;
  final String? lessonId;
  final DateTime updated;

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'body': body, 'lessonId': lessonId, 'updated': updated.toIso8601String()};

  factory UserNote.fromJson(Map<String, dynamic> j) => UserNote(
        id: j['id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        lessonId: j['lessonId'] as String?,
        updated: DateTime.parse(j['updated'] as String),
      );
}

class Achievement {
  const Achievement(this.id, this.title, this.description, this.iconKey, this.isUnlocked);
  final String id;
  final String title;
  final String description;
  final String iconKey;
  final bool Function(UserProgress) isUnlocked;
}

final List<Achievement> allAchievements = [
  Achievement('first_steps', 'First Steps', 'Complete your first lesson.', 'flag', (p) => p.completed.isNotEmpty),
  Achievement('committed', 'Committed', 'Complete 5 lessons.', 'school', (p) => p.completed.length >= 5),
  Achievement('perfectionist', 'Perfectionist', 'Score 100% on a lesson.', 'star', (p) => p.lessonScores.values.any((s) => s >= 100)),
  Achievement('rising_star', 'Rising Star', 'Earn 500 XP.', 'bolt', (p) => p.xp >= 500),
  Achievement('on_fire', 'On Fire', 'Reach a 3-day streak.', 'fire', (p) => p.streak >= 3),
  Achievement('sharp_mind', 'Sharp Mind', 'Review 20 flashcards.', 'memory', (p) => p.reviewsDone >= 20),
  Achievement('shell_shocked', 'Shell Shocked', 'Run 25 terminal commands.', 'terminal', (p) => p.commandsRun >= 25),
];

class UserProgress {
  const UserProgress({
    this.xp = 0,
    this.completed = const {},
    this.lessonScores = const {},
    this.streak = 0,
    this.activeDays = 0,
    this.lastActive,
    this.achievements = const {},
    this.reviews = const {},
    this.notes = const [],
    this.themeMode = 'dark',
    this.onboarded = false,
    this.totalCorrect = 0,
    this.totalAnswered = 0,
    this.reviewsDone = 0,
    this.commandsRun = 0,
  });

  factory UserProgress.initial() => const UserProgress();

  final int xp;
  final Set<String> completed;
  final Map<String, int> lessonScores;
  final int streak;
  final int activeDays;
  final String? lastActive;
  final Set<String> achievements;
  final Map<String, ReviewState> reviews;
  final List<UserNote> notes;
  final String themeMode; // system | dark | light
  final bool onboarded;
  final int totalCorrect;
  final int totalAnswered;
  final int reviewsDone;
  final int commandsRun;

  int get level => ProgressEngine.levelFor(xp);
  int get accuracy => ProgressEngine.accuracyPercent(totalCorrect, totalAnswered);

  UserProgress copyWith({
    int? xp,
    Set<String>? completed,
    Map<String, int>? lessonScores,
    int? streak,
    int? activeDays,
    String? lastActive,
    Set<String>? achievements,
    Map<String, ReviewState>? reviews,
    List<UserNote>? notes,
    String? themeMode,
    bool? onboarded,
    int? totalCorrect,
    int? totalAnswered,
    int? reviewsDone,
    int? commandsRun,
  }) =>
      UserProgress(
        xp: xp ?? this.xp,
        completed: completed ?? this.completed,
        lessonScores: lessonScores ?? this.lessonScores,
        streak: streak ?? this.streak,
        activeDays: activeDays ?? this.activeDays,
        lastActive: lastActive ?? this.lastActive,
        achievements: achievements ?? this.achievements,
        reviews: reviews ?? this.reviews,
        notes: notes ?? this.notes,
        themeMode: themeMode ?? this.themeMode,
        onboarded: onboarded ?? this.onboarded,
        totalCorrect: totalCorrect ?? this.totalCorrect,
        totalAnswered: totalAnswered ?? this.totalAnswered,
        reviewsDone: reviewsDone ?? this.reviewsDone,
        commandsRun: commandsRun ?? this.commandsRun,
      );

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'completed': completed.toList(),
        'lessonScores': lessonScores,
        'streak': streak,
        'activeDays': activeDays,
        'lastActive': lastActive,
        'achievements': achievements.toList(),
        'reviews': reviews.map((k, v) => MapEntry(k, v.toJson())),
        'notes': notes.map((n) => n.toJson()).toList(),
        'themeMode': themeMode,
        'onboarded': onboarded,
        'totalCorrect': totalCorrect,
        'totalAnswered': totalAnswered,
        'reviewsDone': reviewsDone,
        'commandsRun': commandsRun,
      };

  factory UserProgress.fromJson(Map<String, dynamic> j) => UserProgress(
        xp: (j['xp'] as int?) ?? 0,
        completed: ((j['completed'] as List?) ?? const []).cast<String>().toSet(),
        lessonScores: ((j['lessonScores'] as Map?) ?? const {}).map((k, v) => MapEntry(k as String, v as int)),
        streak: (j['streak'] as int?) ?? 0,
        activeDays: (j['activeDays'] as int?) ?? 0,
        lastActive: j['lastActive'] as String?,
        achievements: ((j['achievements'] as List?) ?? const []).cast<String>().toSet(),
        reviews: ((j['reviews'] as Map?) ?? const {}).map((k, v) => MapEntry(k as String, ReviewState.fromJson(Map<String, dynamic>.from(v as Map)))),
        notes: ((j['notes'] as List?) ?? const []).map((n) => UserNote.fromJson(Map<String, dynamic>.from(n as Map))).toList(),
        themeMode: (j['themeMode'] as String?) ?? 'dark',
        onboarded: (j['onboarded'] as bool?) ?? false,
        totalCorrect: (j['totalCorrect'] as int?) ?? 0,
        totalAnswered: (j['totalAnswered'] as int?) ?? 0,
        reviewsDone: (j['reviewsDone'] as int?) ?? 0,
        commandsRun: (j['commandsRun'] as int?) ?? 0,
      );
}

class LessonOutcome {
  const LessonOutcome(this.progress, this.xpGained, this.unlocked);
  final UserProgress progress;
  final int xpGained;
  final List<Achievement> unlocked;
}

/// Pure, side-effect-free game logic (easy to unit test).
class ProgressEngine {
  static const int lessonXp = 30;
  static const int correctXp = 10;
  static const int xpPerLevel = 150;

  static int levelFor(int xp) => xp ~/ xpPerLevel + 1;
  static double levelProgress(int xp) => (xp % xpPerLevel) / xpPerLevel;
  static int accuracyPercent(int correct, int total) => total == 0 ? 100 : ((correct * 100) / total).round();

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static UserProgress touch(UserProgress p, DateTime now) {
    final today = _day(now);
    final last = p.lastActive == null ? null : DateTime.tryParse(p.lastActive!);
    if (last == null) return p.copyWith(streak: 1, activeDays: 1, lastActive: today.toIso8601String());
    final diff = today.difference(_day(last)).inDays;
    if (diff <= 0) return p;
    return p.copyWith(streak: diff == 1 ? p.streak + 1 : 1, activeDays: p.activeDays + 1, lastActive: today.toIso8601String());
  }

  static LessonOutcome _withAchievements(UserProgress n, int gained) {
    final newly = allAchievements.where((a) => !n.achievements.contains(a.id) && a.isUnlocked(n)).toList();
    final done = n.copyWith(achievements: {...n.achievements, ...newly.map((a) => a.id)});
    return LessonOutcome(done, gained, newly);
  }

  static LessonOutcome completeLesson(UserProgress p, {required String lessonId, required int correct, required int total, required DateTime now}) {
    final isQuick = lessonId.startsWith('quick');
    final first = !isQuick && !p.completed.contains(lessonId);
    final gained = isQuick ? correct * 5 : (first ? lessonXp + correct * correctXp : 5);
    final acc = accuracyPercent(correct, total);
    var n = touch(p, now).copyWith(xp: p.xp + gained, totalCorrect: p.totalCorrect + correct, totalAnswered: p.totalAnswered + total);
    if (!isQuick) {
      n = n.copyWith(
        completed: {...n.completed, lessonId},
        lessonScores: {...n.lessonScores, lessonId: max(acc, n.lessonScores[lessonId] ?? 0)},
      );
    }
    return _withAchievements(n, gained);
  }

  static UserProgress recordReview(UserProgress p, String cardId, int quality, DateTime now) {
    final cur = p.reviews[cardId] ?? ReviewState(cardId: cardId, due: now);
    final next = cur.review(quality, now);
    final n = touch(p, now).copyWith(reviews: {...p.reviews, cardId: next}, reviewsDone: p.reviewsDone + 1, xp: p.xp + 2);
    return _withAchievements(n, 2).progress;
  }

  static UserProgress recordCommand(UserProgress p, DateTime now) {
    final n = touch(p, now).copyWith(commandsRun: p.commandsRun + 1, xp: p.xp + 1);
    return _withAchievements(n, 1).progress;
  }
}
