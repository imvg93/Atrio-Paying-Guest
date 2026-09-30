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

Secrets are never committed. Copy the example env file and fill in your own values:

```
cp backend/.env.example backend/.env
```

**Java backend** (needs `DB_*`, `JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET` as environment variables):

```
cd backend-java
mvn spring-boot:run
```

**Flutter app**:

```
cd app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

## Status

Phase 1 in progress: auth, profile, owner property management and the property
wizard are done. Rooms/beds, photos, student search and visit requests are pending.
