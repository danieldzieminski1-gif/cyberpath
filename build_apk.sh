#!/usr/bin/env bash
# Builds an installable CyberPath APK. Requires Flutter (stable) + Android SDK.
set -euo pipefail
cd "$(dirname "$0")"
if [ ! -d android ]; then
  flutter create --platforms=android --org com.cyberpath --project-name cyberpath .
fi
flutter pub get
flutter analyze
flutter test
flutter build apk --release
echo
echo "APK: build/app/outputs/flutter-apk/app-release.apk"
