# MaaMacGui Collaboration Guide (for Coding Agents)

## Scope and Inheritance

- In this standalone repository, this file applies to the repo root (`.`).
- When this project is used inside the mono-repo, the same rules apply to the `src/MaaMacGui` subtree.
- Rules not overridden here inherit from the parent/repository root `AGENTS.md` when available.
- If there is a conflict, this file takes precedence for this project subtree.

## Quick Checklist (Do This First)

1. Identify change type first: SwiftUI UI, task config models, MaaCore bridge, localization, or signing/packaging.
2. Ensure dependency artifacts exist (`../../build/*.xcframework`).
3. Format Swift code before build/static analysis.
4. Run only the smallest relevant validation set (see “Build and Validation”).
5. Do not commit local signing settings, user-specific files, archives, or temporary export artifacts.

## Architecture Overview

- `MeoAsstMac/MeoAsstMacApp.swift`: app entry point, menu commands, settings tabs.
- `MeoAsstMac/Core/`: bridge layer to `MaaCore` (`Maa.swift`).
  - Keep `Asst*` C API usage centralized here; do not call FFI directly elsewhere.
- `MeoAsstMac/Model/`: runtime state, task orchestration, callback handling (`MAAViewModel`, etc.).
- `MeoAsstMac/Task Configurations/`: task parameter models (`Codable` configs).
- `MeoAsstMac/Configuration Views/` and `Views/`: configuration and feature views.
- `MeoAsstMac/Navigation/`: main UI composition and navigation.
- `MeoAsstMac/Utils/`: updater/download/unzip/logging/OTA utilities.
- `Packages/LegacyUserTasks/`: legacy task config package used by migration logic.
- `Resources/Localizable.xcstrings`: localization source (`sourceLanguage: zh-Hans`).

## Build and Validation

### Prerequisites (run from repository root)

- Preferred one-click script (generates `build/*.xcframework`):
  - `MAA_DEBUG=1 ./tools/build_macos_universal.zsh`
- Or follow CI-style flow: build/install MaaCore first, then run `xcodebuild -create-xcframework ...`.

### Local build (run inside `src/MaaMacGui`)

- Resolve package dependencies:
  - `xcodebuild -resolvePackageDependencies -project MeoAsstMac.xcodeproj -scheme MAA`
- Unsigned build (recommended for daily development):
  - `xcodebuild CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=YES ARCHS="$(uname -m)" -destination "platform=macOS,arch=$(uname -m)" -project MeoAsstMac.xcodeproj -scheme MAA build`
- CI-aligned archive:
  - `xcodebuild CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=YES ARCHS="$(uname -m)" -destination "platform=macOS,arch=$(uname -m)" -project MeoAsstMac.xcodeproj -scheme MAA -archivePath MAA.xcarchive archive`
- Static analysis:
  - `xcodebuild CODE_SIGNING_ALLOWED=NO -project MeoAsstMac.xcodeproj -scheme MAA analyze`
- MaaMacGui CI gate script:
  - In mono-repo checkout: `MAA_MAIN_REPO_ROOT=../.. ./scripts/ci.sh`
  - In standalone MaaMacGui checkout, set dependency paths explicitly when needed:
    - `MAA_CORE_DIR=<path-to-install-libs> MAA_HEADERS_DIR=<path-to-include> MAA_XCFRAMEWORK_OUTPUT_DIR=<path-to-build> ./scripts/ci.sh`

### LegacyUserTasks (as needed)

- If you modify `Packages/LegacyUserTasks/**`, run at least:
  - `swift build --package-path Packages/LegacyUserTasks`
- This package currently has no test target by default. If logic changes, add tests and run:
  - `swift test --package-path Packages/LegacyUserTasks`

## Formatting and Code Quality

- Swift formatting follows `.swift-format` in this repo (4 spaces, line length 120).
- Before submitting, run:
  - `swift format --in-place --recursive MeoAsstMac Packages/LegacyUserTasks/Sources`
- Keep changes focused and minimal; avoid unrelated mass reformatting/reordering.

## Testing Policy (for this subtree)

- The `MAA` Xcode target currently has no XCTest target.
- For pure logic changes, prefer extracting logic into testable modules (for example `LegacyUserTasks`, or utility layers).
- Bug fixes must include regression coverage.
- If automation is not practical, document reproducible manual verification steps in the PR.
- For newly added/refactored modules, target at least 80% coverage of changed paths.

## Localization and Compatibility

- Use localization APIs (`String(localized:)`) and resource files for UI text; avoid hardcoded display strings.
- Treat `Localizable.xcstrings` as zh-Hans semantic source; keep `en` updated (and `ko` when needed).
- Keep display text and backend values separate:
  - Do not break MaaCore-required task keys/enums (some internal values still depend on Chinese keys).
- If task configuration structures change, verify migration paths:
  - `MeoAsstMac/Task Configurations/LegacyConfigurations.swift`
  - `Packages/LegacyUserTasks/**`

## Signing, Versioning, and Release Notes

- Do not commit personal development signing changes (Team/Provisioning Profile).
- Be extra careful when modifying:
  - `MeoAsstMac.entitlements`
  - `MAADev.entitlements`
  - `ExternalTools/adb.entitlements`
- `Version.xcconfig` is usually managed by release workflows; avoid changing it unless release work requires it.
- Do not commit build artifacts: `*.xcarchive`, `Export/`, `DerivedData/`, `*.dmg`.

## Commits and Documentation

- Use Conventional Commits (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`, etc.).
- If behavior changes, update:
  - this directory’s `README.md`
  - root-level docs when changes affect cross-component behavior.

## Keep This File Updated

- If you find stale or incomplete instructions, update this file in the same task.
- Goal: future agents should be able to execute tasks directly from this guide.