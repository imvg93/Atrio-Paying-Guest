# ATRIO-PG mobile app

Flutter app (Android + iOS) for ATRIO-PG. Riverpod for state, go_router for
navigation, Dio for HTTP, freezed/json_serializable for models. Feature-first
layout: `lib/features/<feature>/{data,application,presentation}`, shared code in
`lib/core/`. See the root `README.md` and `CLAUDE.md` for the full picture.

## Run

```
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

`API_BASE_URL` defaults to the Android emulator address above. Use
`http://localhost:8080/api/v1` for the iOS simulator, or your machine's LAN IP
for a physical device.

## Check

```
flutter analyze
flutter test --exclude-tags golden
```

- Golden renders (`test/owner_screens_golden_test.dart`, tag `golden`) are for
  visual review; regenerate with `--update-goldens`.
- Live contract tests (`*_live_test.dart`) skip unless a backend is running:
  `flutter test --dart-define=API_BASE_URL=http://localhost:8080/api/v1 --dart-define=BACKEND_LOG=<path to backend log>`

## Code generation

Generated `*.freezed.dart` / `*.g.dart` files are committed. After changing a
model:

```
dart run build_runner build --delete-conflicting-outputs
```
