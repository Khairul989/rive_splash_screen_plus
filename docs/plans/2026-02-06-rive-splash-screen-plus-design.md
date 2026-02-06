# rive_splash_screen_plus Design

**Goal:** Rename the package to `rive_splash_screen_plus` and update repo/docs references while keeping the API unchanged.

**Scope:** Package rename + repo URL updates. No behavior changes. Example app IDs remain unchanged.

## Approach Summary

1) Update package identity in metadata (pubspec name, homepage) and README badges/links.
2) Update import paths in library/example code to match new package name.
3) Provide migration notes in README (dependency + import swap, no API changes).
4) Bump version and add changelog entry describing the rename.
5) Verify with `flutter analyze` and `flutter build apk --release`.

## Touchpoints

- `pubspec.yaml`
  - `name: rive_splash_screen_plus`
  - `homepage: https://github.com/Khairul989/rive_splash_screen_plus`
  - version bump (recommend `0.2.0`)
- `README.md`
  - update badge and package links to `rive_splash_screen_plus`
  - add migration snippet
  - replace repo references
- Library imports
  - update any `package:rive_splash_screen/...` imports to `package:rive_splash_screen_plus/...`
- Example docs (if any)
  - update package name references
- `CHANGELOG.md` (if present)
  - entry for rename + Dart/Flutter requirement + API unchanged note

## Migration Guidance (README)

- Replace dependency:

```yaml
dependencies:
  rive_splash_screen_plus: ^0.2.0
```

- Update import:

```dart
import 'package:rive_splash_screen_plus/rive_splash_screen_plus.dart';
```

- No API changes required.

## Verification

- `flutter analyze`
- `flutter build apk --release`

## Risk Notes

- Rename is a breaking change for imports; mitigate with clear README + changelog.
- Keep library file name unchanged unless consistency is required; if renamed, update exports/imports accordingly.
