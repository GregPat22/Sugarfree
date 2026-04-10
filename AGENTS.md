# AGENTS.md

## Cursor Cloud specific instructions

### Overview

Sugarfree is a **native iOS app** (Swift 6.0 / SwiftUI / SwiftData) that helps users track and reduce added sugar intake. It has no backend services — persistence is on-device via SwiftData with optional iCloud/CloudKit sync. The only external API is the public OpenFoodFacts API (no key required).

### Environment limitations

- **This is an iOS-only project.** Full builds (`xcodebuild`), unit tests, and UI tests require **macOS 15+ with Xcode 16+** and an iOS Simulator. These cannot run on Linux.
- On Linux, the available development tools are:
  - **SwiftLint** (`swiftlint`) — runs all 23 Swift source files against `.swiftlint.yml` rules. This is the primary lint/quality check available on Linux.
  - **Swift 6.0.3 toolchain** at `/opt/swift/usr/bin/swift` — can syntax-check files that only use Foundation (e.g., `Date+Extensions.swift`, `NutritionModels.swift`). Files importing SwiftUI/SwiftData/AVFoundation will fail on Linux (expected).
  - **project.yml validation** — `python3 -c "import yaml; yaml.safe_load(open('project.yml'))"` validates the XcodeGen spec as YAML.

### Commands reference

| Task | Command | Notes |
|------|---------|-------|
| Lint | `swiftlint` | Run from repo root; uses `.swiftlint.yml` |
| Lint + autofix | `swiftlint --fix` | Fixes auto-correctable violations |
| Swift syntax check | `swift -frontend -typecheck <file.swift>` | Only works for Foundation-only files on Linux |
| Validate project.yml | `python3 -c "import yaml; yaml.safe_load(open('project.yml'))"` | Checks YAML structure |
| Test OpenFoodFacts API | `curl -s "https://world.openfoodfacts.org/api/v2/product/<barcode>.json"` | Public API, no key needed |

### Key gotchas

- The pre-existing codebase has 9 SwiftLint violations (8 warnings, 1 error for `force_cast`). These are in the existing code, not introduced by agent changes.
- `xcodegen generate` is required before `xcodebuild` to produce `Sugarfree.xcodeproj` from `project.yml`. XcodeGen is a macOS-only tool (installed via `brew install xcodegen`).
- The CI workflow (`.github/workflows/ci.yml`) runs on `macos-15` and does: install xcodegen → generate project → build → test.
- The app's barcode scanner requires a physical iOS device camera; on the simulator, use the manual entry fallback.
