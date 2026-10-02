import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/extras/presentation/extras_screens.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/learn/presentation/learn_screens.dart';
import 'features/lesson/presentation/lesson_screen.dart';
import 'features/practice/presentation/practice_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/progress/application/providers.dart';
import 'features/review/presentation/review_screens.dart';
import 'features/terminal/presentation/terminal_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final onboarded = ref.read(progressProvider).onboarded;
      final atOnboarding = state.matchedLocation == '/onboarding';
      if (!onboarded && !atOnboarding) return '/onboarding';
      if (onboarded && atOnboarding) return '/home';
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(child: FilledButton(onPressed: () => context.go('/home'), child: const Text('Back to Home'))),
    ),
    routes: [
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (c, s, shell) => ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (c, s) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/learn', builder: (c, s) => const LearnScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/practice', builder: (c, s) => const PracticeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/review', builder: (c, s) => const ReviewScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen())]),
        ],
      ),
      GoRoute(path: '/course/:id', builder: (c, s) => CourseScreen(courseId: s.pathParameters['id']!)),
      GoRoute(path: '/lesson/:id', builder: (c, s) => LessonScreen(lessonId: s.pathParameters['id']!)),
      GoRoute(path: '/terminal', builder: (c, s) => const TerminalScreen()),
      GoRoute(path: '/flashcards', builder: (c, s) => const FlashcardsScreen()),
      GoRoute(path: '/search', builder: (c, s) => const SearchScreen()),
      GoRoute(path: '/glossary', builder: (c, s) => const GlossaryScreen()),
      GoRoute(path: '/notes', builder: (c, s) => const NotesScreen()),
    ],
  );
});

class CyberPathApp extends ConsumerWidget {
  const CyberPathApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(progressProvider.select((p) => p.themeMode));
    return MaterialApp.router(
      title: 'CyberPath',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode == 'light' ? ThemeMode.light : (mode == 'system' ? ThemeMode.system : ThemeMode.dark),
      routerConfig: ref.watch(routerProvider),
    );
  }
}

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Learn'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Practice'),
          NavigationDestination(icon: Icon(Icons.replay_circle_filled_outlined), selectedIcon: Icon(Icons.replay_circle_filled), label: 'Review'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
