# CyberPath: Learn Cybersecurity. Build Real Skills.

Offline-first Flutter (Android) learning app. Riverpod + GoRouter + Material 3.

## Build an APK

Requirements: Flutter stable (3.24+), Android SDK, JDK 17.

    ./build_apk.sh

This generates the `android/` scaffold (first run only), runs `flutter analyze` and
`flutter test`, then builds `build/app/outputs/flutter-apk/app-release.apk`.
Install on a device: `adb install build/app/outputs/flutter-apk/app-release.apk`

Manual steps:

    flutter create --platforms=android --org com.cyberpath --project-name cyberpath .
    flutter pub get
    flutter build apk --release

## Layout

    lib/
      core/            theme + shared widgets
      features/
        content/       models, courses, glossary, flashcards (data-driven lessons)
        progress/      XP, streak, achievements, review (SM-2), persistence
        lesson/        lesson engine + block renderers
        terminal/      sandboxed shell (never runs real commands)
        home, learn, practice, review, profile, extras
    test/              unit + widget tests
    integration_test/  end-to-end flow

Persistence uses shared_preferences with JSON (no code generation), so there is no
build_runner step between you and the APK.
