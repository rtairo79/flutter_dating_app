# Copilot Instructions for flutter_dating_app

## Project Overview
This is a Flutter-based cross-platform dating app. The codebase is organized for mobile (Android/iOS), desktop (Windows/Linux/macOS), and web targets. The main logic resides in the `lib/` directory, with platform-specific code in respective folders.

## Architecture & Key Components
- **Entry Point:** `lib/main.dart` sets up routing and authentication checks. Initial route is `/`, which triggers an auth check and redirects to `/map` or `/login`.
- **Screens:** UI is split into screens under `lib/screens/`, e.g. `map_screen.dart`, `music_matches_screen.dart`, and `auth/` for login/register.
- **Services:** Business logic and API calls are in `lib/services/`. Notable services:
  - `auth_service.dart`: Handles login, registration, token management.
  - `api_service.dart`: Centralizes API requests using Dio, with an `AuthInterceptor` for token injection.
  - `storage_service.dart`: Persists tokens and user IDs using secure storage and shared preferences.
- **Config:** API endpoints and timeouts are defined in `lib/config/api_config.dart`.

## Data Flow & Patterns
- **Authentication:** On launch, `AuthCheck` widget checks login state via `AuthService` and navigates accordingly. Tokens are stored securely and injected into requests.
- **API Communication:** All network calls use Dio. Endpoints are constructed from `ApiConfig`. Auth tokens are managed automatically.
- **State Management:** Uses the `provider` package (see `pubspec.yaml`), but explicit usage may be limited; check for `ChangeNotifierProvider` or similar patterns in screens.

## Developer Workflows
- **Build:**
  - Run: `flutter run` (auto-detects platform)
  - Build APK: `flutter build apk`
  - Build iOS: `flutter build ios`
  - Build Web: `flutter build web`
- **Test:**
  - Run all tests: `flutter test`
  - Widget tests are in `test/widget_test.dart` (default template, update as needed)
- **Debug:**
  - Use `flutter pub get` to fetch dependencies.
  - Use IDE or `flutter run --debug` for debugging.

## Conventions & Patterns
- **Routing:** All navigation uses named routes defined in `main.dart`.
- **API Usage:** Always use `ApiService.dio` for HTTP requests. Endpoints and base URL are in `api_config.dart`.
- **Token Handling:** Use `StorageService` for all token/user ID storage and retrieval.
- **Error Handling:** API errors are caught and surfaced via exceptions or UI messages (see `FutureBuilder` in screens).
- **Assets:** Add images/fonts in `pubspec.yaml` under the `flutter` section.

## Integration Points
- **External APIs:** Communicates with a backend at `http://192.168.8.14:8000/api/`.
- **Google Maps:** Used in `map_screen.dart` via `google_maps_flutter` and `geolocator`.
- **Spotify:** Music matching and sync via API endpoints and `spotify_auth_service.dart`.

## Examples
- To add a new screen, create a Dart file in `lib/screens/`, add a route in `main.dart`, and update navigation logic as needed.
- To add a new API call, extend `ApiService` and update `api_config.dart` for endpoints.

---
If any section is unclear or missing, please provide feedback so instructions can be improved for future AI agents.
