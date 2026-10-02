import 'package:cyberpath/features/content/domain/models.dart';
import 'package:cyberpath/features/terminal/domain/terminal_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TerminalEngine t;
  setUp(() => t = TerminalEngine());

  test('pwd and navigation', () {
    expect(t.run('pwd').output, '/home/learner');
    t.run('cd projects');
    expect(t.run('pwd').output, '/home/learner/projects');
    t.run('cd ..');
    expect(t.run('pwd').output, '/home/learner');
  });

  test('mkdir, touch and ls', () {
    t.run('mkdir lab');
    t.run('touch lab/a.txt');
    expect(t.run('ls lab').output, 'a.txt');
    expect(t.run('mkdir lab').output, contains('File exists'));
  });

  test('echo redirect and cat', () {
    t.run('echo hello > a.txt');
    t.run('echo world >> a.txt');
    expect(t.run('cat a.txt').output, 'hello\nworld');
  });

  test('grep finds log lines and counts', () {
    final r = t.run('grep Failed logs/auth.log');
    expect(r.output.split('\n').length, 2);
    expect(t.run('grep -c Failed logs/auth.log').output, '2');
    expect(t.run('grep -i FAILED logs/auth.log').output, contains('root'));
  });

  test('find by name', () {
    expect(t.run('find . -name "*.py"').output, contains('hello.py'));
  });

  test('chmod updates the permission string', () {
    t.run('chmod 600 notes.txt');
    expect(t.run('ls -l').output, contains('-rw------- learner learner'));
    t.run('chmod +x notes.txt');
    expect(t.run('ls -l').output, contains('-rwx--x--x'));
  });

  test('python simulation and unknown commands', () {
    expect(t.run('python --version').output, contains('Python 3'));
    expect(t.run('python -c "print(2+3)"').output, '5');
    expect(t.run('python projects/hello.py').output, 'Hello, CyberPath');
    final r = t.run('rm -rf /');
    expect(r.output, contains('command not found'));
  });

  test('git workflow', () {
    expect(t.run('git status').output, contains('not a git repository'));
    t.run('git init');
    t.run('git add notes.txt');
    expect(t.run('git commit -m first').output, contains('first'));
    expect(t.run('git log').output, contains('first'));
  });

  test('clear flag and empty input', () {
    expect(t.run('clear').clear, isTrue);
    expect(t.run('   ').output, '');
  });

  test('answer checker ignores case, spacing and quotes', () {
    expect(AnswerChecker.matches('  MKDIR   lab ', 'mkdir lab'), isTrue);
    expect(AnswerChecker.matches('grep "Failed" logs/auth.log', 'grep Failed logs/auth.log'), isTrue);
    expect(AnswerChecker.matches('ps aux', 'ps|ps aux|ps -ef'), isTrue);
    expect(AnswerChecker.matches('ls', 'mkdir lab'), isFalse);
  });
}
