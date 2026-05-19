# WAVE — Flutter Mobile App

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.11.5`)
- Android Studio or Xcode (for device/emulator)
- A connected device or running emulator

## Setup

**1. Clone the repo and install dependencies**

```bash
flutter pub get
```

**2. Configure environment**

Create a `.env` file in the project root:

```
API_URL=https://your-api-host.com
```

## Running the App

```bash
# Run on the default connected device
flutter run

# List available devices first
flutter devices

# Run on a specific device
flutter run -d <device-id>
```

## Building

```bash
# Android APK
flutter build apk

# iOS (requires macOS + Xcode)
flutter build ios
```

## Other Commands

```bash
# Static analysis
flutter analyze

# Run tests
flutter test
```

## Architecture

Feature-first folder structure under `lib/`:

```
lib/
  main.dart             # Entry point — loads .env then runs App
  app.dart              # MaterialApp.router with theme
  router.dart           # GoRouter route definitions
  core/
    network/            # Shared HTTP layer (DioClient, interceptors)
  features/
    auth/               # Login, register
    home/
    profile/
```

Each feature follows: `data/models/` → `data/repositories/` → `presentation/pages/` → `presentation/providers/` → `presentation/widgets/`

### Key Dependencies

| Package | Role |
|---|---|
| `flutter_riverpod` | State management |
| `go_router` | Declarative routing |
| `dio` | HTTP client |
| `flutter_dotenv` | Environment config |
| `shared_preferences` | Local storage |
