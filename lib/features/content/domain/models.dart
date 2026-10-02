enum BlockType { explanation, diagram, code, terminal, multipleChoice, fillBlank, ordering, matching, challenge, checkpoint }

extension BlockTypeX on BlockType {
  bool get isInteractive =>
      this == BlockType.multipleChoice ||
      this == BlockType.fillBlank ||
      this == BlockType.ordering ||
      this == BlockType.matching ||
      this == BlockType.challenge;

  String get label {
    switch (this) {
      case BlockType.explanation:
        return 'Concept';
      case BlockType.diagram:
        return 'Diagram';
      case BlockType.code:
        return 'Code';
      case BlockType.terminal:
        return 'Terminal';
      case BlockType.multipleChoice:
        return 'Quiz';
      case BlockType.fillBlank:
        return 'Fill in the blank';
      case BlockType.ordering:
        return 'Put in order';
      case BlockType.matching:
        return 'Match';
      case BlockType.challenge:
        return 'Challenge';
      case BlockType.checkpoint:
        return 'Checkpoint';
    }
  }
}

/// One renderable unit of a lesson. Lessons are data; screens never hardcode them.
class LessonBlock {
  const LessonBlock({
    required this.type,
    required this.id,
    this.title = '',
    this.body = '',
    this.options = const [],
    this.answerIndex = 0,
    this.answer = '',
    this.items = const [],
    this.pairs = const {},
    this.explanation = '',
  });

  final BlockType type;
  final String id;
  final String title;
  final String body;
  final List<String> options;
  final int answerIndex;
  final String answer; // alternatives separated by |
  final List<String> items; // correct order for ordering blocks
  final Map<String, String> pairs;
  final String explanation;

  factory LessonBlock.text(String id, String title, String body) =>
      LessonBlock(type: BlockType.explanation, id: id, title: title, body: body);
  factory LessonBlock.diagram(String id, String title, String body) =>
      LessonBlock(type: BlockType.diagram, id: id, title: title, body: body);
  factory LessonBlock.code(String id, String title, String body) =>
      LessonBlock(type: BlockType.code, id: id, title: title, body: body);
  factory LessonBlock.terminal(String id, String title, String body) =>
      LessonBlock(type: BlockType.terminal, id: id, title: title, body: body);
  factory LessonBlock.mc(String id, String question, List<String> options, int answerIndex, String explanation) =>
      LessonBlock(type: BlockType.multipleChoice, id: id, body: question, options: options, answerIndex: answerIndex, explanation: explanation);
  factory LessonBlock.fill(String id, String prompt, String answer, String explanation) =>
      LessonBlock(type: BlockType.fillBlank, id: id, body: prompt, answer: answer, explanation: explanation);
  factory LessonBlock.order(String id, String prompt, List<String> correct, String explanation) =>
      LessonBlock(type: BlockType.ordering, id: id, body: prompt, items: correct, explanation: explanation);
  factory LessonBlock.match(String id, String prompt, Map<String, String> pairs, String explanation) =>
      LessonBlock(type: BlockType.matching, id: id, body: prompt, pairs: pairs, explanation: explanation);
  factory LessonBlock.challenge(String id, String prompt, String answer, String explanation) =>
      LessonBlock(type: BlockType.challenge, id: id, title: 'Terminal challenge', body: prompt, answer: answer, explanation: explanation);
  factory LessonBlock.checkpoint(String id, String body) =>
      LessonBlock(type: BlockType.checkpoint, id: id, title: 'Checkpoint', body: body);
}

class Lesson {
  const Lesson({required this.id, required this.courseId, required this.title, required this.summary, required this.minutes, required this.blocks});
  final String id;
  final String courseId;
  final String title;
  final String summary;
  final int minutes;
  final List<LessonBlock> blocks;
  int get interactiveCount => blocks.where((b) => b.type.isInteractive).length;
}

class Module {
  const Module({required this.id, required this.title, required this.lessons});
  final String id;
  final String title;
  final List<Lesson> lessons;
}

class Course {
  const Course({required this.id, required this.title, required this.subtitle, required this.level, required this.icon, required this.modules});
  final String id;
  final String title;
  final String subtitle;
  final String level;
  final String icon;
  final List<Module> modules;
  List<Lesson> get lessons => [for (final m in modules) ...m.lessons];
}

class Skill {
  const Skill({required this.id, required this.name, required this.description, required this.courseId, required this.lessonIds});
  final String id;
  final String name;
  final String description;
  final String courseId;
  final List<String> lessonIds;
}

class GlossaryTerm {
  const GlossaryTerm(this.term, this.definition, this.topic);
  final String term;
  final String definition;
  final String topic;
}

class Flashcard {
  const Flashcard({required this.id, required this.front, required this.back, required this.topic});
  final String id;
  final String front;
  final String back;
  final String topic;
}

/// Normalises and compares free-text answers (case, spacing and quotes ignored).
class AnswerChecker {
  static String normalize(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ').replaceAll('"', '').replaceAll("'", '');

  static bool matches(String input, String answer) {
    final n = normalize(input);
    return answer.split('|').map(normalize).contains(n);
  }
}
