# ATRIO-PG — PG Finder & Hostel Management

Mobile app (Android + iOS) for the Indian PG/hostel market. One app, two roles:
students search and visit PGs; owners list and manage properties, rooms and beds.

## Repository layout

| Folder          | What it is                                                        |
| --------------- | ----------------------------------------------------------------- |
| `app/`          | Flutter app (Riverpod, go_router, Dio, freezed)                   |
| `backend-java/` | Spring Boot API (`/api/v1`) — the backend the app targets         |
| `backend/`      | Original NestJS backend (entities + migrations only, legacy)      |
| `docs/`         | Migration plan and current-state notes                            |

See `CLAUDE.md` for the full spec, architecture rules and roadmap.

## Running locally

Secrets are never committed. Copy the example env file and fill in your own
values (database connection, and two JWT secrets of at least 32 characters):

```
cp backend-java/.env.example backend-java/.env
```

**Java backend** (Java 21; Maven is provided by the wrapper):

```
cd backend-java
./mvnw spring-boot:run -Dspring-boot.run.profiles=local
./mvnw verify            # tests; DB integration tests need Docker
```

The `local` profile prints OTP codes to the console instead of sending SMS.
Without it, OTP requests fail with `SMS_DELIVERY_UNAVAILABLE`. Deployments must
set `SPRING_PROFILES_ACTIVE=prod` and supply every variable from
`backend-java/.env.example` as a real environment variable.

**Flutter app**:

```
cd app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
flutter analyze
flutter test --exclude-tags golden
```

**Android release signing:** create `app/android/key.properties` (git-ignored)
with `storeFile`, `storePassword`, `keyAlias` and `keyPassword`. Without it,
release builds fall back to the debug key and must not be published.

CI (`.github/workflows/ci.yml`) runs the backend tests and Flutter analyze/test
on every pull request.

## Status

Phase 1 in progress: auth, profile, owner property management and the property
wizard are done. Rooms/beds, photos, student search and visit requests are pending.
