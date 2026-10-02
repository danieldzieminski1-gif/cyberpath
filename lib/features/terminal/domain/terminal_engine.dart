/// A fully sandboxed, in-memory shell for learning. It never touches the real
/// device filesystem, network or processes.
class VNode {
  VNode(this.name, {this.isDir = false, this.content = '', this.mode = 420});
  final String name;
  final bool isDir;
  String content;
  int mode; // octal permission bits, e.g. 0644 = 420
  final Map<String, VNode> children = {};
}

class TerminalResult {
  const TerminalResult(this.output, {this.explanation = '', this.clear = false});
  final String output;
  final String explanation;
  final bool clear;
}

class TerminalEngine {
  TerminalEngine() {
    _seed();
  }

  static const List<String> supported = ['pwd', 'ls', 'cd', 'mkdir', 'touch', 'cat', 'echo', 'grep', 'find', 'chmod', 'ps', 'top', 'curl', 'git', 'python', 'help', 'clear'];
  static const List<String> _home = ['home', 'learner'];

  final VNode _root = VNode('', isDir: true, mode: 493);
  List<String> _cwd = List<String>.from(_home);
  bool _gitReady = false;
  final List<String> _commits = [];
  final Set<String> _staged = {};

  String get path {
    final p = '/${_cwd.join('/')}';
    return p.replaceFirst('/home/learner', '~');
  }

  String get prompt => 'learner@cyberpath:$path\$ ';

  void _seed() {
    _mkdirs(['home', 'learner', 'projects']);
    _mkdirs(['home', 'learner', 'logs']);
    _write(['home', 'learner', 'notes.txt'], 'Remember: least privilege.\nRotate passwords.\n');
    _write(['home', 'learner', '.bashrc'], '# shell config\n');
    _write(['home', 'learner', 'logs', 'auth.log'],
        'Oct 02 10:01 sshd: Accepted password for learner\nOct 02 10:03 sshd: Failed password for root from 203.0.113.9\nOct 02 10:03 sshd: Failed password for root from 203.0.113.9\nOct 02 10:07 sshd: Accepted publickey for learner\n');
    _write(['home', 'learner', 'projects', 'hello.py'], 'print("Hello, CyberPath")\n');
    _write(['etc', 'hostname'], 'cyberpath\n');
    _mkdirs(['tmp']);
  }

  VNode _mkdirs(List<String> parts) {
    var n = _root;
    for (final s in parts) {
      n = n.children.putIfAbsent(s, () => VNode(s, isDir: true, mode: 493));
    }
    return n;
  }

  void _write(List<String> parts, String content) {
    final dir = _mkdirs(parts.sublist(0, parts.length - 1));
    dir.children[parts.last] = VNode(parts.last, content: content);
  }

  List<String> _abs(String p) {
    var input = p;
    if (input == '~') input = '/home/learner';
    if (input.startsWith('~/')) input = '/home/learner/${input.substring(2)}';
    final parts = input.startsWith('/') ? <String>[] : List<String>.from(_cwd);
    for (final s in input.split('/')) {
      if (s.isEmpty || s == '.') continue;
      if (s == '..') {
        if (parts.isNotEmpty) parts.removeLast();
      } else {
        parts.add(s);
      }
    }
    return parts;
  }

  VNode? _node(List<String> parts) {
    var n = _root;
    for (final s in parts) {
      if (!n.isDir) return null;
      final c = n.children[s];
      if (c == null) return null;
      n = c;
    }
    return n;
  }

  List<String> _tokenize(String line) {
    final re = RegExp(r'''"([^"]*)"|'([^']*)'|(\S+)''');
    return re.allMatches(line).map((m) => m.group(1) ?? m.group(2) ?? m.group(3) ?? '').toList();
  }

  TerminalResult _err(String msg, [String why = '']) => TerminalResult(msg, explanation: why);

  String _perm(VNode n) {
    String t(int d) => '${(d & 4) != 0 ? 'r' : '-'}${(d & 2) != 0 ? 'w' : '-'}${(d & 1) != 0 ? 'x' : '-'}';
    return '${n.isDir ? 'd' : '-'}${t((n.mode >> 6) & 7)}${t((n.mode >> 3) & 7)}${t(n.mode & 7)}';
  }

  TerminalResult run(String line) {
    final tokens = _tokenize(line.trim());
    if (tokens.isEmpty) return const TerminalResult('');
    final cmd = tokens.first;
    final a = tokens.sublist(1);
    switch (cmd) {
      case 'pwd':
        return TerminalResult('/${_cwd.join('/')}', explanation: 'pwd prints your current working directory as an absolute path.');
      case 'ls':
        return _ls(a);
      case 'cd':
        return _cd(a);
      case 'mkdir':
        return _mkdir(a);
      case 'touch':
        return _touch(a);
      case 'cat':
        return _cat(a);
      case 'echo':
        return _echo(a);
      case 'grep':
        return _grep(a);
      case 'find':
        return _find(a);
      case 'chmod':
        return _chmod(a);
      case 'ps':
        return const TerminalResult(
            '  PID TTY          TIME CMD\n    1 pts/0    00:00:00 bash\n   42 pts/0    00:00:00 sshd\n  107 pts/0    00:00:00 ps',
            explanation: 'ps lists processes. Every process has a PID. Try "ps aux" on a real system for all users.');
      case 'top':
        return const TerminalResult(
            'top - 10:12:01 up 3 days,  1 user,  load average: 0.12, 0.08, 0.05\nTasks:   3 total,   1 running\n  PID USER      %CPU %MEM COMMAND\n    1 root       0.0  0.1 bash\n   42 root       0.1  0.3 sshd\n  107 learner    0.2  0.1 python',
            explanation: 'top shows live resource use. Unexpected high CPU can be a sign of malware such as a crypto-miner. (Simulated snapshot.)');
      case 'curl':
        return _curl(a);
      case 'git':
        return _git(a);
      case 'python':
        return _python(a);
      case 'help':
        return TerminalResult('Available commands:\n${supported.join(', ')}', explanation: 'This is a safe sandbox. Nothing you type here touches your real device.');
      case 'clear':
        return const TerminalResult('', clear: true);
      default:
        return _err('$cmd: command not found', 'The sandbox only supports: ${supported.join(', ')}. Real commands are never executed on your device.');
    }
  }

  TerminalResult _ls(List<String> a) {
    final flags = a.where((x) => x.startsWith('-')).join();
    final paths = a.where((x) => !x.startsWith('-')).toList();
    final target = paths.isEmpty ? _cwd : _abs(paths.first);
    final n = _node(target);
    if (n == null) return _err("ls: cannot access '${paths.first}': No such file or directory");
    const why = 'ls lists a directory. -l shows permissions and sizes, -a also shows hidden files that start with a dot.';
    if (!n.isDir) return TerminalResult(paths.first, explanation: why);
    var names = n.children.keys.toList()..sort();
    if (!flags.contains('a')) names = names.where((x) => !x.startsWith('.')).toList();
    if (flags.contains('l')) {
      final lines = names.map((k) {
        final c = n.children[k]!;
        return '${_perm(c)} learner learner ${c.isDir ? 4096 : c.content.length} $k${c.isDir ? '/' : ''}';
      });
      return TerminalResult(lines.join('\n'), explanation: why);
    }
    return TerminalResult(names.join('  '), explanation: why);
  }

  TerminalResult _cd(List<String> a) {
    final target = a.isEmpty ? List<String>.from(_home) : _abs(a.first);
    final n = _node(target);
    if (n == null) return _err('cd: ${a.first}: No such file or directory');
    if (!n.isDir) return _err('cd: ${a.first}: Not a directory');
    _cwd = target;
    return const TerminalResult('', explanation: 'cd changes your working directory. ".." goes up one level and "~" jumps home.');
  }

  TerminalResult _mkdir(List<String> a) {
    final p = a.contains('-p');
    final names = a.where((x) => x != '-p').toList();
    if (names.isEmpty) return _err('mkdir: missing operand');
    final out = <String>[];
    for (final name in names) {
      final parts = _abs(name);
      if (parts.isEmpty) continue;
      if (_node(parts) != null) {
        if (!p) out.add("mkdir: cannot create directory '$name': File exists");
        continue;
      }
      final parent = _node(parts.sublist(0, parts.length - 1));
      if (parent == null || !parent.isDir) {
        if (p) {
          _mkdirs(parts);
        } else {
          out.add("mkdir: cannot create directory '$name': No such file or directory");
        }
        continue;
      }
      parent.children[parts.last] = VNode(parts.last, isDir: true, mode: 493);
    }
    return TerminalResult(out.join('\n'), explanation: 'mkdir creates directories. Add -p to create missing parent folders too.');
  }

  TerminalResult _touch(List<String> a) {
    if (a.isEmpty) return _err('touch: missing file operand');
    final out = <String>[];
    for (final name in a) {
      final parts = _abs(name);
      final parent = parts.isEmpty ? null : _node(parts.sublist(0, parts.length - 1));
      if (parent == null || !parent.isDir) {
        out.add("touch: cannot touch '$name': No such file or directory");
        continue;
      }
      parent.children.putIfAbsent(parts.last, () => VNode(parts.last));
    }
    return TerminalResult(out.join('\n'), explanation: 'touch creates an empty file, or updates the timestamp of an existing one.');
  }

  TerminalResult _cat(List<String> a) {
    if (a.isEmpty) return _err('cat: missing file operand');
    final out = <String>[];
    for (final f in a) {
      final n = _node(_abs(f));
      if (n == null) {
        out.add('cat: $f: No such file or directory');
      } else if (n.isDir) {
        out.add('cat: $f: Is a directory');
      } else {
        out.add(n.content.replaceAll(RegExp(r'\n$'), ''));
      }
    }
    return TerminalResult(out.join('\n'), explanation: 'cat prints a file to the screen.');
  }

  TerminalResult _echo(List<String> a) {
    const why = 'echo prints text. ">" writes it to a file (overwriting), ">>" appends.';
    final i = a.indexWhere((x) => x == '>' || x == '>>');
    if (i == -1) return TerminalResult(a.join(' '), explanation: why);
    final text = a.sublist(0, i).join(' ');
    if (i + 1 >= a.length) return _err('bash: syntax error: expected a file name after redirect');
    final parts = _abs(a[i + 1]);
    final parent = parts.isEmpty ? null : _node(parts.sublist(0, parts.length - 1));
    if (parent == null || !parent.isDir) return _err('bash: ${a[i + 1]}: No such file or directory');
    final existing = parent.children[parts.last];
    if (existing != null && existing.isDir) return _err('bash: ${a[i + 1]}: Is a directory');
    if (a[i] == '>>' && existing != null) {
      existing.content = '${existing.content}$text\n';
    } else {
      parent.children[parts.last] = VNode(parts.last, content: '$text\n');
    }
    return const TerminalResult('', explanation: why);
  }

  TerminalResult _grep(List<String> a) {
    bool isFlag(String x) => x.startsWith('-') && x.length > 1;
    final flags = a.where(isFlag).join();
    final rest = a.where((x) => !isFlag(x)).toList();
    if (rest.length < 2) return _err('usage: grep [-i] [-n] [-c] PATTERN FILE...');
    final ci = flags.contains('i');
    RegExp re;
    try {
      re = RegExp(rest.first, caseSensitive: !ci);
    } catch (_) {
      re = RegExp(RegExp.escape(rest.first), caseSensitive: !ci);
    }
    final files = rest.sublist(1);
    final out = <String>[];
    for (final f in files) {
      final n = _node(_abs(f));
      if (n == null) {
        out.add('grep: $f: No such file or directory');
        continue;
      }
      if (n.isDir) {
        out.add('grep: $f: Is a directory');
        continue;
      }
      final prefix = files.length > 1 ? '$f:' : '';
      final lines = n.content.split('\n');
      var count = 0;
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].isEmpty || !re.hasMatch(lines[i])) continue;
        count++;
        if (!flags.contains('c')) out.add('$prefix${flags.contains('n') ? '${i + 1}:' : ''}${lines[i]}');
      }
      if (flags.contains('c')) out.add('$prefix$count');
    }
    return TerminalResult(out.join('\n'), explanation: 'grep searches text. -i ignores case, -n shows line numbers, -c counts matches. Defenders use it to hunt through logs.');
  }

  TerminalResult _find(List<String> a) {
    var start = '.';
    if (a.isNotEmpty && !a.first.startsWith('-')) start = a.first;
    String? pattern;
    final ni = a.indexOf('-name');
    if (ni != -1 && ni + 1 < a.length) pattern = a[ni + 1];
    final n = _node(_abs(start));
    if (n == null) return _err("find: '$start': No such file or directory");
    final RegExp? re = pattern == null ? null : RegExp('^${RegExp.escape(pattern).replaceAll(r'\*', '.*').replaceAll(r'\?', '.')}\$');
    final out = <String>[];
    void walk(VNode node, String shown) {
      if (re == null || re.hasMatch(node.name)) out.add(shown);
      if (node.isDir) {
        final keys = node.children.keys.toList()..sort();
        for (final k in keys) {
          walk(node.children[k]!, shown.endsWith('/') ? '$shown$k' : '$shown/$k');
        }
      }
    }

    walk(n, start);
    return TerminalResult(out.join('\n'), explanation: 'find walks a directory tree. -name matches file names; * is a wildcard.');
  }

  TerminalResult _chmod(List<String> a) {
    if (a.length < 2) return _err('chmod: missing operand');
    final mode = a.first;
    final n = _node(_abs(a[1]));
    if (n == null) return _err("chmod: cannot access '${a[1]}': No such file or directory");
    if (RegExp(r'^[0-7]{3}$').hasMatch(mode)) {
      n.mode = int.parse(mode, radix: 8);
    } else if (RegExp(r'^[ugoa]*[+-][rwx]+$').hasMatch(mode)) {
      final who = mode.replaceAll(RegExp(r'[+\-rwx]'), '');
      final add = mode.contains('+');
      var bits = 0;
      if (mode.contains('r')) bits |= 4;
      if (mode.contains('w')) bits |= 2;
      if (mode.contains('x')) bits |= 1;
      final shifts = <int>[];
      if (who.isEmpty || who.contains('a')) {
        shifts.addAll([6, 3, 0]);
      } else {
        if (who.contains('u')) shifts.add(6);
        if (who.contains('g')) shifts.add(3);
        if (who.contains('o')) shifts.add(0);
      }
      for (final s in shifts) {
        n.mode = add ? (n.mode | (bits << s)) : (n.mode & ~(bits << s));
      }
    } else {
      return _err("chmod: invalid mode: '$mode'");
    }
    return const TerminalResult('', explanation: 'chmod changes permissions. Digits: r=4, w=2, x=1 per group (owner, group, others). 600 = owner read/write only.');
  }

  TerminalResult _curl(List<String> a) {
    final url = a.firstWhere((x) => !x.startsWith('-'), orElse: () => '');
    if (url.isEmpty) return _err('curl: no URL specified');
    const why = 'curl makes HTTP requests. This sandbox returns a simulated response; no real network request is made.';
    const headers = 'HTTP/2 200\ncontent-type: text/html; charset=UTF-8\nserver: example-server\ncache-control: max-age=604800\nstrict-transport-security: max-age=31536000';
    if (a.contains('-I') || a.contains('--head')) return const TerminalResult(headers, explanation: why);
    return const TerminalResult('<!doctype html>\n<html><head><title>Example Domain</title></head>\n<body><h1>Example Domain</h1></body></html>', explanation: why);
  }

  TerminalResult _git(List<String> a) {
    if (a.isEmpty) return _err('usage: git <init|status|add|commit|log>');
    const why = 'git tracks changes to files. Typical flow: init, add, commit.';
    switch (a.first) {
      case 'init':
        _gitReady = true;
        return TerminalResult('Initialized empty Git repository in /${_cwd.join('/')}/.git/', explanation: why);
      case 'status':
        if (!_gitReady) return _err('fatal: not a git repository (or any of the parent directories): .git');
        return TerminalResult(_staged.isEmpty ? 'On branch main\nnothing to commit, working tree clean' : 'On branch main\nChanges to be committed:\n${_staged.map((s) => '  new file:   $s').join('\n')}', explanation: why);
      case 'add':
        if (!_gitReady) return _err('fatal: not a git repository (or any of the parent directories): .git');
        _staged.addAll(a.sublist(1));
        return const TerminalResult('', explanation: why);
      case 'commit':
        if (!_gitReady) return _err('fatal: not a git repository (or any of the parent directories): .git');
        if (_staged.isEmpty) return const TerminalResult('nothing to commit');
        final mi = a.indexOf('-m');
        final msg = mi != -1 && mi + 1 < a.length ? a[mi + 1] : 'no message';
        _commits.insert(0, msg);
        final count = _staged.length;
        _staged.clear();
        return TerminalResult('[main ${_commits.length.toString().padLeft(7, 'a')}] $msg\n $count file(s) changed', explanation: why);
      case 'log':
        if (!_gitReady) return _err('fatal: not a git repository (or any of the parent directories): .git');
        return TerminalResult(_commits.isEmpty ? 'fatal: your current branch has no commits yet' : _commits.map((c) => 'commit  $c').join('\n'), explanation: why);
      default:
        return _err("git: '${a.first}' is not supported in this sandbox");
    }
  }

  TerminalResult _python(List<String> a) {
    if (a.isEmpty) return _err('Interactive mode is not available. Try: python --version, python -c "print(1+1)", or python projects/hello.py');
    if (a.first == '--version' || a.first == '-V') {
      return const TerminalResult('Python 3.12.3 (simulated)', explanation: 'The sandbox runs a tiny simulated interpreter that understands print(...) statements.');
    }
    final String src;
    if (a.first == '-c' && a.length > 1) {
      src = a[1];
    } else {
      final n = _node(_abs(a.first));
      if (n == null || n.isDir) return _err("python: can't open file '${a.first}': [Errno 2] No such file or directory");
      src = n.content;
    }
    final out = <String>[];
    for (final line in src.split(RegExp(r'[\n;]'))) {
      if (line.trim().isEmpty) continue;
      final m = RegExp(r'^\s*print\((.*)\)\s*$').firstMatch(line);
      if (m == null) return _err('SyntaxError: this sandbox only runs print(...) statements');
      out.add(_evalExpr(m.group(1)!.trim()));
    }
    return TerminalResult(out.join('\n'), explanation: 'python runs scripts. Here only print("text") and simple arithmetic are simulated.');
  }

  String _evalExpr(String e) {
    final s = RegExp(r'''^(?:"([^"]*)"|'([^']*)')$''').firstMatch(e);
    if (s != null) return s.group(1) ?? s.group(2) ?? '';
    final m = RegExp(r'^(\d+)\s*([+\-*/])\s*(\d+)$').firstMatch(e);
    if (m != null) {
      final x = int.parse(m.group(1)!);
      final y = int.parse(m.group(3)!);
      switch (m.group(2)) {
        case '+':
          return '${x + y}';
        case '-':
          return '${x - y}';
        case '*':
          return '${x * y}';
        default:
          return y == 0 ? 'ZeroDivisionError' : '${x / y}';
      }
    }
    return e;
  }
}
