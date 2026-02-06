# Flutter Compatibility + 16KB Play Compliance Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Update the package and example app to work on Flutter 3.35.7 and latest stable, and verify Android 15 16KB page-size compliance.

**Architecture:** Keep the package API stable while modernizing SDK constraints and the example app/toolchain. Use Flutter's current Android template conventions to ensure 16KB-ready builds without adding native code.

**Tech Stack:** Flutter (stable), Dart 3, Android Gradle Plugin 8.x, Gradle 8.x, Android SDK build-tools 35.x

---

### Task 1: Confirm dependency compatibility (rive_loading)

**Files:**
- Modify: `pubspec.yaml`

**Step 1: Check upstream constraints**

Run: `dart pub outdated --mode=null-safety`
Expected: `rive_loading` shows Dart 3 compatible versions (or not).

**Step 2: Decide version bump**

- If `rive_loading` supports Dart 3: update constraint to latest compatible version.
- If not: document limitation and pin to latest available, then decide whether to fork.

**Step 3: Commit**

```bash
git add pubspec.yaml
git commit -m "chore: update rive_loading constraint"
```

### Task 2: Update SDK constraints to Dart 3

**Files:**
- Modify: `pubspec.yaml`
- Modify: `example/pubspec.yaml`

**Step 1: Update SDK ranges**

- Set `sdk: ">=3.0.0 <4.0.0"` for both package and example.
- Keep `flutter: ">=3.0.0"` for package; add Flutter constraint to example.

**Step 2: Run pub get**

Run: `flutter pub get`
Expected: No SDK constraint errors.

**Step 3: Commit**

```bash
git add pubspec.yaml example/pubspec.yaml
git commit -m "chore: raise Dart SDK constraints"
```

### Task 3: Migrate example Dart code to null safety + Material 3 text styles

**Files:**
- Modify: `example/lib/main.dart`
- Modify: `example/lib/callback.dart`
- Modify: `example/lib/isLoading.dart`

**Step 1: Add null-safety updates**

- Convert constructors to `const` where possible.
- Replace `Key key` with `Key? key` and use `required` for non-null fields.
- Remove any legacy patterns that violate Dart 3 null safety.

**Step 2: Update deprecated text styles**

- Replace `textTheme.subtitle1` with `textTheme.titleMedium` (or `bodyLarge` if more appropriate per UI).

**Step 3: Run analyzer**

Run: `flutter analyze`
Expected: No deprecation or null-safety errors in example code.

**Step 4: Commit**

```bash
git add example/lib/main.dart example/lib/callback.dart example/lib/isLoading.dart
git commit -m "refactor: migrate example to Dart 3"
```

### Task 4: Modernize example Android build for 16KB support

**Files:**
- Modify: `example/android/build.gradle`
- Modify: `example/android/app/build.gradle`
- Modify: `example/android/gradle/wrapper/gradle-wrapper.properties`
- Modify: `example/android/settings.gradle`
- Modify: `example/android/gradle.properties`

**Step 1: Align with current Flutter Android template**

- Replace old `buildscript` block with modern `plugins` + `pluginManagement`.
- Update Gradle wrapper to 8.x and AGP to 8.5.1+.
- Enable AndroidX and Jetifier in `gradle.properties`.

**Step 2: Update Android SDK levels**

- Set `compileSdkVersion` and `targetSdkVersion` to 35.
- Update `minSdkVersion` to the current Flutter default (21) unless there is a project-specific need.

**Step 3: Remove legacy support dependencies**

- Replace old `com.android.support.*` test deps with AndroidX or remove if unused.

**Step 4: Build example release APK**

Run (from `example/`): `flutter build apk --release`
Expected: Successful build on Flutter 3.35.7 and latest stable.

**Step 5: Commit**

```bash
git add example/android
git commit -m "chore: modernize example Android build"
```

### Task 5: Document compatibility + 16KB verification

**Files:**
- Modify: `README.md`

**Step 1: Add compatibility notes**

- Document supported Flutter/Dart range (3.35.x and latest stable).
- Mention that Android 15 16KB compliance depends on Flutter engine/toolchain version.

**Step 2: Add verification instructions**

- Include the `check_elf_alignment.sh` usage example for the example APK.

**Step 3: Commit**

```bash
git add README.md
git commit -m "docs: add Flutter/16KB compatibility guidance"
```

### Task 6: Verify 16KB alignment using the provided script

**Files:**
- No file changes

**Step 1: Run the checker**

Run: `./check_elf_alignment.sh example/build/app/outputs/flutter-apk/app-release.apk`
Expected: PASS for arm64-v8a and x86_64 libraries.

**Step 2: Rebuild if needed**

- If FAIL, update toolchain (NDK/AGP) per script guidance and rebuild.

**Step 3: Log results**

- Capture the output summary for release notes or README if required.
