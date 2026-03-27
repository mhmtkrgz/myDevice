# My Device - Project Guidelines

## Project Overview
A professional utility iOS app for device identifiers and system diagnostics.
- **Core Features:** IDFA/IDFV tracking, System Info, Network details, Hardware status.
- **App Management:** Localization (System settings), Theme management (Light/Dark), Support (Mail/Rate), and Privacy.
- **Tech Stack:** Swift 6, SwiftUI, XCTest, @AppStorage for persistence.
- **Architecture:** MVVM with Protocol-oriented networking/services for testability.

## Coding Standards
- **SwiftUI:** Use `@StateObject` or `@State` for local state; `@Published` in ViewModels.
- **Naming:** PascalCase for Types, camelCase for variables/functions.
- **Safety:** Avoid force unwrapping (`!`). Use `if let` or `guard let`.
- **UI:** Keep Views small. Decompose complex views into smaller components.

## Testing Strategy
- **Unit Tests:** All logic in ViewModels must be unit tested.
- **UI Tests:** Test the "Copy to Clipboard" flow and main list visibility.
- **Mocking:** Use protocols to mock system services (e.g., `DeviceServiceProvider`).

## Common Commands
- **Build:** `Cmd + B`
- **Test:** `Cmd + U`
- **Lint:** SwiftLint (if added)
