# Sugarfree

A native iOS app that helps you break free from added sugar. Scan barcodes to instantly check sugar content, track your daily intake, and build sugar-free streaks with personalized goals. Built with SwiftUI and SwiftData, with iCloud sync across your Apple devices.

## Tech Stack

| Layer | Technology | Rationale |
|---|---|---|
| Language | Swift 6.0 | Strict concurrency for production safety |
| UI | SwiftUI | Declarative, modern iOS development |
| Architecture | MVVM | Natural fit for SwiftUI data binding |
| Persistence | SwiftData | Apple's modern ORM, minimal boilerplate |
| Cloud Sync | CloudKit via SwiftData | Free iCloud sync, zero backend |
| Barcode Scanning | AVFoundation | Native camera barcode detection |
| Nutrition Data | OpenFoodFacts API | Free open-source food database |
| Networking | URLSession + async/await | Native Swift concurrency |
| Testing | Swift Testing + XCTest | Unit tests + UI tests |
| Linting | SwiftLint | Consistent code style |
| Project Gen | XcodeGen | Reproducible .xcodeproj from YAML |
| CI | GitHub Actions | Build + test on every push/PR |
| Min iOS | 17.0 | Required for SwiftData |

## Architecture Overview

The app follows MVVM with SwiftData as the persistence layer:

```
User → View (SwiftUI) → ViewModel (@Observable) → SwiftData (ModelContext)
                                ↓
                        OpenFoodFacts API
```

**Barcode flow:** User points camera at a product → AVFoundation detects the barcode → `ScannerViewModel` calls `OpenFoodFactsService` with the barcode → API returns sugar content → user confirms → `FoodEntry` is saved to SwiftData.

**Tracking flow:** `FoodEntry` records accumulate throughout the day → `DashboardViewModel` queries today's entries and computes total sugar intake → displayed against the user's `SugarGoal` daily limit → `DailyLog` is updated at end of day for streak calculation.

SwiftData handles iCloud sync automatically via CloudKit -- any data saved on one device appears on the user's other Apple devices.

## Project Structure

```
Sugarfree/
├── project.yml              ← XcodeGen spec (generates .xcodeproj)
├── .swiftlint.yml           ← Linting rules
├── .github/workflows/ci.yml ← CI pipeline
├── Sugarfree/
│   ├── App/                 ← App entry point, SwiftData container setup
│   ├── Models/              ← SwiftData @Model types (FoodEntry, DailyLog, SugarGoal)
│   ├── Views/               ← SwiftUI views organized by feature
│   │   ├── ContentView.swift    (tab bar root)
│   │   ├── Dashboard/           (daily overview, sugar gauge, streaks)
│   │   ├── Scanner/             (camera barcode scanning)
│   │   ├── Tracker/             (food entry log, manual entry)
│   │   └── Goals/               (daily limit, streak stats)
│   ├── ViewModels/          ← @Observable view models per feature
│   ├── Services/            ← API clients (OpenFoodFacts) and response types
│   ├── Utilities/           ← Extensions and helpers
│   └── Resources/           ← Assets.xcassets, Info.plist
├── SugarfreeTests/          ← Unit tests (Swift Testing)
└── SugarfreeUITests/        ← UI tests (XCTest)
```

Models define the data schema. Views are grouped by feature tab. Each major view has a corresponding ViewModel that owns the business logic. Services handle external API calls.

## Getting Started

### Prerequisites

- **macOS 15+** (Sequoia or later)
- **Xcode 16+** with iOS 17 SDK
- **XcodeGen** — `brew install xcodegen`
- **SwiftLint** (optional) — `brew install swiftlint`

### Environment Setup

No environment variables are required for development. The OpenFoodFacts API is free and requires no API key. Copy `.env.example` to `.env` if you want to override the API base URL.

### Installation & Running

```bash
git clone https://github.com/GregPat22/Sugarfree.git
cd Sugarfree

# Generate the Xcode project from project.yml
xcodegen generate

# Open in Xcode
open Sugarfree.xcodeproj
```

In Xcode, select an iPhone simulator or your connected device, then press **Cmd+R** to build and run.

> **Note:** The barcode scanner requires a physical device with a camera. On the simulator, use the manual entry fallback.

## Development

### Available Commands

| Command | Description |
|---|---|
| `xcodegen generate` | Regenerate .xcodeproj from project.yml |
| `swiftlint` | Run linter on all Swift files |
| `swiftlint --fix` | Auto-fix lintable violations |
| `open Sugarfree.xcodeproj` | Open project in Xcode |

In Xcode:

| Shortcut | Action |
|---|---|
| Cmd+R | Build & Run |
| Cmd+U | Run all tests |
| Cmd+Shift+U | Run tests without building |

### Code Style & Conventions

- **SwiftLint** enforces style rules (see `.swiftlint.yml`)
- **Naming:** types are `PascalCase`, properties/functions are `camelCase`
- **Architecture:** one ViewModel per feature view, models in `Models/`, API types in `Services/`
- **Concurrency:** use `async/await` and `@Observable` (no Combine unless necessary)
- **Views:** prefer small, composable views extracted into their own files when they exceed ~50 lines

### Testing

- **Unit tests** live in `SugarfreeTests/` using Swift Testing (`@Test`, `#expect`)
- **UI tests** live in `SugarfreeUITests/` using XCTest
- Run from Xcode with Cmd+U, or via CLI:

```bash
xcodebuild test \
  -project Sugarfree.xcodeproj \
  -scheme SugarfreeTests \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO
```

## Deployment

### App Store

1. Set your Apple Developer Team in Xcode → Sugarfree target → Signing & Capabilities
2. Update the bundle identifier from `com.sugarfree.app` to your own
3. Enable the iCloud capability and select your CloudKit container
4. Archive via Product → Archive in Xcode
5. Upload to App Store Connect via the Organizer

### TestFlight

Same as App Store deployment, but distribute via TestFlight in App Store Connect for beta testing.

## Contributing

1. Create a feature branch: `feature/barcode-scanner`, `fix/streak-calculation`
2. Make changes, ensure `swiftlint` passes with no errors
3. Run tests (Cmd+U in Xcode)
4. Open a PR against `main` — CI will build and test automatically
5. Commit messages: use imperative mood ("Add barcode scanner", "Fix streak reset logic")
