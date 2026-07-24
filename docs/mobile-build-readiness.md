# Mobile Build Readiness

Use this checklist before pushing or handing the app to testers.

## Current Status

- Flutter SDK is installed at `/Users/vaneVanessa_KidNationssa_kidnation/development/flutter`.
- Flutter is not currently on the shell `PATH`; commands in this repo use the full Flutter path.
- Impeller is explicitly enabled:
  - Android: `io.flutter.embedding.android.EnableImpeller=true`
  - iOS: `FLTEnableImpeller=true`
- Dart tests and analyzer pass locally.

## Current Machine Blockers

Android debug build currently stops before app compilation because Flutter cannot find an Android SDK:

```text
[!] No Android SDK found. Try setting the ANDROID_HOME environment variable.
```

iOS debug build currently stops before app compilation because this Mac has Command Line Tools selected instead of full Xcode, and CocoaPods is missing:

```text
xcode-select: error: tool 'xcodebuild' requires Xcode
pod: command not found
```

Flutter then reports:

```text
Application not configured for iOS
```

Flutter's iOS package resolution needs `xcodebuild` to resolve the generated `$(PRODUCT_BUNDLE_IDENTIFIER)` in `ios/Runner/Info.plist`, so this is an environment readiness blocker rather than a Bubble Blast code blocker.

## Setup Needed

1. Add Flutter to `PATH` or keep using the full binary path:

```bash
export PATH="/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin:$PATH"
```

2. Install Android Studio or Android command line tools, then set the SDK path:

```bash
flutter config --android-sdk "$HOME/Library/Android/sdk"
export ANDROID_HOME="$HOME/Library/Android/sdk"
```

3. Install full Xcode and select it:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

4. Install CocoaPods:

```bash
sudo gem install cocoapods
```

## Verification Gate

Run:

```bash
FLUTTER_BIN=/Users/vaneVanessa_KidNationssa_kidnation/development/flutter/bin/flutter \
  bash scripts/check_mobile_builds.sh
```

The app is mobile-build ready when all sections complete without errors.
