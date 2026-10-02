import '../domain/models.dart';

final List<Course> kCourses = [
  Course(
    id: 'linux',
    title: 'Linux Fundamentals',
    subtitle: 'Own the command line.',
    level: 'Beginner',
    icon: 'terminal',
    modules: [
      Module(id: 'linux-m1', title: 'Getting around', lessons: [
        Lesson(
          id: 'linux-1',
          courseId: 'linux',
          title: 'The Shell & Filesystem',
          summary: 'Navigate, create and inspect files.',
          minutes: 8,
          blocks: [
            LessonBlock.text('l1-a', 'What the shell really is',
                'The shell is a program that reads the commands you type and asks the operating system to run them. Nearly every server you will ever defend or test is driven from a shell, so fluency here is your first real security skill.\n\nLinux organises everything as one tree of files that starts at / (the root). Your personal space lives under /home.'),
            LessonBlock.diagram('l1-b', 'The filesystem tree', r'''/
├── etc          system configuration
├── var
│   └── log      logs (auth.log lives here)
├── tmp          temporary files
└── home
    └── learner  <- you are here'''),
            LessonBlock.terminal('l1-c', 'Your first commands', r'''$ pwd
/home/learner
$ ls
logs  notes.txt  projects
$ cd projects
$ pwd
/home/learner/projects'''),
            LessonBlock.mc('l1-d', 'Which command prints the directory you are currently in?', ['ls', 'pwd', 'cd', 'cat'], 1,
                'pwd stands for "print working directory".'),
            LessonBlock.order('l1-e', 'Put these steps in order to create a file inside a new folder.',
                ['mkdir lab', 'cd lab', 'touch hello.txt', 'ls'], 'Create the folder, enter it, create the file, then list to confirm.'),
            LessonBlock.challenge('l1-f', 'Create a directory named lab.', 'mkdir lab', 'mkdir makes directories. Try it in the Terminal Lab too.'),
            LessonBlock.checkpoint('l1-g', 'You can now find where you are (pwd), look around (ls), move (cd), and create things (mkdir, touch). Next: who is allowed to touch what.'),
          ],
        ),
        Lesson(
          id: 'linux-2',
          courseId: 'linux',
          title: 'Permissions & Processes',
          summary: 'Read rwx, apply least privilege.',
          minutes: 9,
          blocks: [
            LessonBlock.text('l2-a', 'Who can do what',
                'Every file has permissions for three groups: the owner, the group, and everyone else. Each group can have read (r = 4), write (w = 2) and execute (x = 1). Add the numbers: rwx = 7, r-x = 5, r-- = 4.\n\nSo chmod 750 means the owner gets rwx, the group gets r-x, and others get nothing. Giving only the access that is needed is the principle of least privilege.'),
            LessonBlock.code('l2-b', 'Reading a permission string', '-rwxr-x---  1 learner learner  220 backup.sh\n^|_||_||_|\n| u  g  o   owner / group / others'),
            LessonBlock.match('l2-c', 'Match each chmod mode to what it allows.', {
              'chmod 755': 'Owner full; others read + execute',
              'chmod 600': 'Only the owner can read and write',
              'chmod 644': 'Owner read + write; others read-only',
              'chmod 777': 'Everyone can do everything (dangerous)',
            }, '600 is the right choice for secrets such as private keys. 777 is almost never correct.'),
            LessonBlock.mc('l2-d', 'An SSH private key should be readable by...', ['Everyone', 'Only its owner', 'Any logged-in user', 'Nobody, not even the owner'], 1,
                'SSH refuses keys that other users can read. Use chmod 600.'),
            LessonBlock.fill('l2-e', 'To make script.sh executable for its owner: chmod ____ script.sh', '+x|u+x|700|755', 'chmod +x adds the execute bit.'),
            LessonBlock.challenge('l2-f', 'List the running processes with the simplest command.', 'ps|ps aux|ps -ef', 'ps shows a snapshot of processes. top shows them live.'),
            LessonBlock.checkpoint('l2-g', 'You can read permission strings, set them with chmod, and you know why 777 is a red flag.'),
          ],
        ),
      ]),
    ],
  ),
  Course(
    id: 'net',
    title: 'Networking Fundamentals',
    subtitle: 'See how data really moves.',
    level: 'Beginner',
    icon: 'lan',
    modules: [
      Module(id: 'net-m1', title: 'How the internet works', lessons: [
        Lesson(
          id: 'net-1',
          courseId: 'net',
          title: 'How Data Travels',
          summary: 'Layers, packets and ports.',
          minutes: 8,
          blocks: [
            LessonBlock.text('n1-a', 'Everything is packets',
                'Data is cut into small packets. Each packet carries a source and destination address, travels through routers, and is reassembled on the other side. You cannot defend a network until you can picture this journey.'),
            LessonBlock.diagram('n1-b', 'The four-layer model', r'''Application  HTTP, DNS, SSH    what you use
Transport    TCP, UDP          ports, reliability
Internet     IP                addresses, routing
Link         Ethernet, Wi-Fi   local delivery'''),
            LessonBlock.mc('n1-c', 'Which layer handles IP addressing and routing?', ['Application', 'Transport', 'Internet', 'Link'], 2, 'The Internet layer (IP) moves packets between networks.'),
            LessonBlock.match('n1-d', 'Match each service to its default port.', {'HTTP': '80', 'HTTPS': '443', 'SSH': '22', 'DNS': '53'}, 'Knowing default ports helps you read scans and firewall rules.'),
            LessonBlock.order('n1-e', 'Put the TCP three-way handshake in order.', ['SYN', 'SYN-ACK', 'ACK', 'Data flows'], 'Client says SYN, server answers SYN-ACK, client confirms with ACK.'),
            LessonBlock.checkpoint('n1-f', 'You know the layers, the common ports, and how TCP starts a conversation.'),
          ],
        ),
        Lesson(
          id: 'net-2',
          courseId: 'net',
          title: 'IP, DNS & HTTP',
          summary: 'Addresses, names and requests.',
          minutes: 9,
          blocks: [
            LessonBlock.text('n2-a', 'Addresses and names',
                'An IP address identifies a device on a network. DNS is the phone book that turns names like example.com into IP addresses. HTTP is the language browsers and servers use to exchange pages and data.'),
            LessonBlock.terminal('n2-b', 'Peeking at HTTP', r'''$ curl -I https://example.com
HTTP/2 200
content-type: text/html; charset=UTF-8
strict-transport-security: max-age=31536000'''),
            LessonBlock.mc('n2-c', 'How many usable host addresses are in a /24 network?', ['24', '254', '256', '65534'], 1, '256 addresses minus the network and broadcast addresses leaves 254.'),
            LessonBlock.fill('n2-d', 'DNS translates names like example.com into ____ addresses.', 'ip', 'DNS maps names to IP addresses.'),
            LessonBlock.challenge('n2-e', 'Fetch only the HTTP response headers of https://example.com', 'curl -I https://example.com', 'The -I flag asks for headers only.'),
            LessonBlock.checkpoint('n2-f', 'You can explain IP, DNS and HTTP, and inspect a response with curl.'),
          ],
        ),
      ]),
    ],
  ),
  Course(
    id: 'py',
    title: 'Python Fundamentals',
    subtitle: 'Automate the boring security work.',
    level: 'Beginner',
    icon: 'code',
    modules: [
      Module(id: 'py-m1', title: 'Python for security', lessons: [
        Lesson(
          id: 'py-1',
          courseId: 'py',
          title: 'Variables & Types',
          summary: 'Store and test values.',
          minutes: 7,
          blocks: [
            LessonBlock.text('p1-a', 'Why Python?', 'Python is readable, ships with a huge standard library, and is the most common language for security scripting: log parsing, automation, and quick proofs of concept.'),
            LessonBlock.code('p1-b', 'Your first script', 'name = "cyberpath"\nattempts = 3\nis_locked = attempts >= 3\nprint(name.upper(), is_locked)'),
            LessonBlock.mc('p1-c', 'What does type(3.0) return?', ['int', 'float', 'str', 'bool'], 1, '3.0 has a decimal point, so it is a float.'),
            LessonBlock.fill('p1-d', 'len("hack") returns ____', '4', 'len counts characters: h-a-c-k = 4.'),
            LessonBlock.match('p1-e', 'Match each Python type to an example.', {'list': '[1, 2, 3]', 'dict': '{"a": 1}', 'tuple': '(1, 2)', 'str': '"hi"'}, 'Lists and dicts are mutable; tuples are not.'),
            LessonBlock.challenge('p1-f', 'Check which Python version the sandbox has.', 'python --version', 'python --version prints the interpreter version.'),
            LessonBlock.checkpoint('p1-g', 'You can create variables, reason about types, and run Python from the terminal.'),
          ],
        ),
        Lesson(
          id: 'py-2',
          courseId: 'py',
          title: 'Loops & Functions',
          summary: 'Write a password checker.',
          minutes: 9,
          blocks: [
            LessonBlock.text('p2-a', 'Repeat and reuse', 'Loops repeat work; functions package it up with a name. Together they turn a ten-minute manual check into a one-second script.'),
            LessonBlock.code('p2-b', 'A password-strength check', 'def is_strong(password):\n    checks = [\n        len(password) >= 12,\n        any(c.isdigit() for c in password),\n        any(c.isupper() for c in password),\n    ]\n    return all(checks)\n\nfor pw in ["abc", "CyberPath2026!"]:\n    print(pw, is_strong(pw))'),
            LessonBlock.mc('p2-c', 'What does range(3) produce?', ['1, 2, 3', '0, 1, 2', '0, 1, 2, 3', '3'], 1, 'range starts at 0 and stops before the number you give it.'),
            LessonBlock.order('p2-d', 'Arrange these lines into a working function and call.', ['def greet(name):', '    message = "Hi " + name', '    return message', 'print(greet("Ada"))'], 'Define, build, return, then call.'),
            LessonBlock.fill('p2-e', 'Read a file safely and auto-close it: ____ open("log.txt") as f:', 'with', 'with closes the file even if an error happens.'),
            LessonBlock.checkpoint('p2-f', 'You can write loops and functions, and you have seen real security-flavoured Python.'),
          ],
        ),
      ]),
    ],
  ),
  Course(
    id: 'sec',
    title: 'Cybersecurity Fundamentals',
    subtitle: 'Think like a defender.',
    level: 'Beginner',
    icon: 'shield',
    modules: [
      Module(id: 'sec-m1', title: 'Core ideas', lessons: [
        Lesson(
          id: 'sec-1',
          courseId: 'sec',
          title: 'The CIA Triad & Threats',
          summary: 'The three goals of security.',
          minutes: 7,
          blocks: [
            LessonBlock.text('s1-a', 'What are we protecting?', 'Security has three classic goals: Confidentiality (only the right people see data), Integrity (data is not changed without detection) and Availability (systems work when needed). Every attack breaks at least one of them.'),
            LessonBlock.match('s1-b', 'Match each goal to its meaning.', {
              'Confidentiality': 'Only authorised people can read data',
              'Integrity': 'Data cannot be altered undetected',
              'Availability': 'Systems work when needed',
            }, 'Learn to ask "which of the three is at risk?" for every incident.'),
            LessonBlock.mc('s1-c', 'Ransomware that locks your files mainly attacks...', ['Confidentiality', 'Integrity', 'Availability', 'Authentication'], 2, 'You lose access to your own data, so availability is hit first.'),
            LessonBlock.fill('s1-d', 'Giving users only the access they need is the principle of least ____', 'privilege', 'Least privilege limits the damage of any single compromise.'),
            LessonBlock.checkpoint('s1-e', 'You can describe the CIA triad and map incidents to it. Everything here is for learning and defending: practise only on systems you own or have written permission to test.'),
          ],
        ),
        Lesson(
          id: 'sec-2',
          courseId: 'sec',
          title: 'Passwords, Hashing & Phishing',
          summary: 'Store secrets safely, spot lures.',
          minutes: 9,
          blocks: [
            LessonBlock.text('s2-a', 'Never store passwords',
                'Services should never store your password. They store a hash: a one-way fingerprint. A random salt is added to each password before hashing so identical passwords produce different hashes, which defeats precomputed lookup tables. Slow algorithms such as bcrypt or Argon2 make guessing expensive.'),
            LessonBlock.order('s2-b', 'Put the safe password storage flow in order.', ['User submits password', 'Generate a random salt', 'Hash with a slow algorithm (bcrypt/Argon2)', 'Store the hash and salt'], 'The plain password is never written to disk.'),
            LessonBlock.mc('s2-c', 'What is the main purpose of a salt?', ['Make the password longer', 'Make identical passwords hash differently', 'Encrypt the database', 'Speed up logins'], 1, 'Salts defeat rainbow tables and reveal nothing about reuse.'),
            LessonBlock.mc('s2-d', 'Which is the strongest phishing red flag?', ['A message from a known colleague', 'Urgent pressure plus a link to a look-alike login page', 'An email with a company logo', 'A newsletter you subscribed to'], 1, 'Urgency plus a look-alike URL is the classic lure. Check the real domain before typing anything.'),
            LessonBlock.fill('s2-e', 'MFA stands for multi-____ authentication.', 'factor', 'A second factor stops most stolen-password attacks.'),
            LessonBlock.challenge('s2-f', 'Search logs/auth.log for lines containing Failed.', 'grep Failed logs/auth.log', 'grep PATTERN FILE prints matching lines. Repeated failures from one address are a brute-force sign.'),
            LessonBlock.checkpoint('s2-g', 'You can explain salted hashing, spot phishing lures, and search logs for suspicious activity.'),
          ],
        ),
      ]),
    ],
  ),
];

const List<Skill> kSkills = [
  Skill(id: 'sk-shell', name: 'Shell Navigator', description: 'Move and create files.', courseId: 'linux', lessonIds: ['linux-1']),
  Skill(id: 'sk-perm', name: 'Permission Guardian', description: 'Apply least privilege.', courseId: 'linux', lessonIds: ['linux-1', 'linux-2']),
  Skill(id: 'sk-net', name: 'Packet Reader', description: 'Understand traffic.', courseId: 'net', lessonIds: ['net-1', 'net-2']),
  Skill(id: 'sk-py', name: 'Script Smith', description: 'Automate with Python.', courseId: 'py', lessonIds: ['py-1', 'py-2']),
  Skill(id: 'sk-threat', name: 'Threat Modeler', description: 'Map risks to the CIA triad.', courseId: 'sec', lessonIds: ['sec-1']),
  Skill(id: 'sk-cred', name: 'Credential Defender', description: 'Protect secrets.', courseId: 'sec', lessonIds: ['sec-1', 'sec-2']),
];

const List<GlossaryTerm> kGlossary = [
  GlossaryTerm('Shell', 'A program that reads your commands and asks the OS to run them.', 'Linux'),
  GlossaryTerm('Kernel', 'The core of the operating system that manages hardware and processes.', 'Linux'),
  GlossaryTerm('Permission', 'A rule saying who may read, write or execute a file.', 'Linux'),
  GlossaryTerm('Process', 'A running instance of a program, identified by a PID.', 'Linux'),
  GlossaryTerm('Root', 'The all-powerful administrator account, or the top of the filesystem (/).', 'Linux'),
  GlossaryTerm('Least privilege', 'Giving each user or program only the access it needs.', 'Security'),
  GlossaryTerm('IP address', 'A number that identifies a device on a network.', 'Networking'),
  GlossaryTerm('DNS', 'The system that translates domain names into IP addresses.', 'Networking'),
  GlossaryTerm('Port', 'A numbered doorway on a device where a service listens.', 'Networking'),
  GlossaryTerm('Packet', 'A small chunk of data sent across a network.', 'Networking'),
  GlossaryTerm('TCP', 'A reliable, connection-based transport protocol.', 'Networking'),
  GlossaryTerm('Firewall', 'A filter that allows or blocks traffic based on rules.', 'Networking'),
  GlossaryTerm('HTTP', 'The protocol used to request and deliver web content.', 'Networking'),
  GlossaryTerm('Variable', 'A named place to store a value in a program.', 'Python'),
  GlossaryTerm('Function', 'A named, reusable block of code.', 'Python'),
  GlossaryTerm('CIA triad', 'Confidentiality, Integrity, Availability: the three goals of security.', 'Security'),
  GlossaryTerm('Encryption', 'Scrambling data so only holders of the key can read it.', 'Cryptography'),
  GlossaryTerm('Hash', 'A one-way fingerprint of data that cannot be reversed.', 'Cryptography'),
  GlossaryTerm('Salt', 'Random data added to a password before hashing.', 'Cryptography'),
  GlossaryTerm('MFA', 'Multi-factor authentication: proving identity in more than one way.', 'Security'),
  GlossaryTerm('Phishing', 'Tricking people into revealing secrets using fake messages or sites.', 'Security'),
  GlossaryTerm('Malware', 'Software designed to harm, spy on or take control of a system.', 'Security'),
  GlossaryTerm('Vulnerability', 'A weakness that could be abused to break security.', 'Security'),
  GlossaryTerm('Exploit', 'Code or a technique that abuses a vulnerability.', 'Security'),
  GlossaryTerm('SQL injection', 'Tricking a database query by inserting attacker-controlled SQL.', 'Web Security'),
  GlossaryTerm('XSS', 'Cross-site scripting: running attacker script in another user\'s browser.', 'Web Security'),
  GlossaryTerm('CTF', 'Capture The Flag: a legal hacking game with puzzles to solve.', 'CTF'),
];

const List<Flashcard> _commandCards = [
  Flashcard(id: 'cmd-pwd', front: 'pwd', back: 'Print the current working directory.', topic: 'Linux'),
  Flashcard(id: 'cmd-ls', front: 'ls -la', back: 'List all files, including hidden, with details.', topic: 'Linux'),
  Flashcard(id: 'cmd-chmod', front: 'chmod 600 file', back: 'Only the owner can read and write the file.', topic: 'Linux'),
  Flashcard(id: 'cmd-grep', front: 'grep -i text file', back: 'Search a file for text, ignoring case.', topic: 'Linux'),
  Flashcard(id: 'cmd-find', front: 'find . -name "*.log"', back: 'Find files by name starting from the current folder.', topic: 'Linux'),
  Flashcard(id: 'cmd-curl', front: 'curl -I URL', back: 'Show only the HTTP response headers.', topic: 'Networking'),
];

final List<Flashcard> kFlashcards = [
  ..._commandCards,
  for (final g in kGlossary)
    Flashcard(id: 'g-${g.term.toLowerCase().replaceAll(' ', '-')}', front: 'What is "${g.term}"?', back: g.definition, topic: g.topic),
];

List<Lesson> get kAllLessons => [for (final c in kCourses) ...c.lessons];

Lesson? lessonById(String id) {
  for (final l in kAllLessons) {
    if (l.id == id) return l;
  }
  return null;
}

Course? courseById(String id) {
  for (final c in kCourses) {
    if (c.id == id) return c;
  }
  return null;
}

Lesson? nextLesson(Set<String> done) {
  for (final l in kAllLessons) {
    if (!done.contains(l.id)) return l;
  }
  return null;
}

Lesson buildQuickQuiz({int count = 5}) {
  final pool = [
    for (final l in kAllLessons) ...l.blocks.where((b) => b.type == BlockType.multipleChoice),
  ]..shuffle();
  return Lesson(id: 'quick', courseId: 'quick', title: 'Quick Quiz', summary: 'Mixed questions from every course.', minutes: 3, blocks: pool.take(count).toList());
}

class SearchHit {
  const SearchHit(this.title, this.subtitle, this.route);
  final String title;
  final String subtitle;
  final String route;
}

List<SearchHit> searchContent(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  final hits = <SearchHit>[];
  for (final l in kAllLessons) {
    final hay = '${l.title} ${l.summary} ${l.blocks.map((b) => '${b.title} ${b.body}').join(' ')}'.toLowerCase();
    if (hay.contains(q)) hits.add(SearchHit(l.title, 'Lesson · ${l.summary}', '/lesson/${l.id}'));
  }
  for (final g in kGlossary) {
    if ('${g.term} ${g.definition}'.toLowerCase().contains(q)) hits.add(SearchHit(g.term, 'Glossary · ${g.definition}', '/glossary'));
  }
  return hits;
}
