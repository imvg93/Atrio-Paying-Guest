# ATRIO-PG — Project Status, Tech Stack & Database

**Snapshot date:** 2026-09-30
**Scope:** Phase 1 of `CLAUDE.md` (PG Finder & Hostel Management App)
**How this was produced:** read-only review of the repository files. Nothing
was executed, so "done" below means "code exists", not "verified working end to
end". Items I could not confirm are marked **unverified**.

---

## 1. Summary

ATRIO-PG is a mobile app (Android + iOS) for the Indian PG/hostel market. One
app, two roles: **students** search and visit PGs; **owners** list and manage
properties, rooms and beds.

**Overall Phase 1 completion: about 45%.**

| Area | Done | Approx. |
| --- | --- | --- |
| Database schema (11 tables) | 11 of 11 | 100% |
| Backend API endpoints (Java) | 12 of ~25 | 48% |
| Flutter screens (spec list) | 6 of 12 | 50% |
| Cross-cutting (envelope, validation, security, tests) | mostly | ~70% |
| Phase 2 / Phase 3 features | not started (by design) | 0% |

The foundation is solid: database, authentication, and the owner's
property-creation flow work in code. The gap is the student side (search,
detail, visit requests) and the owner's rooms/beds/photos/visit inbox.

---

## 2. Tech stack

### 2.1 What is actually in use

| Layer | Technology | Version / notes |
| --- | --- | --- |
| Mobile app | Flutter (Dart) | Dart SDK `^3.11.5`, app version `1.0.0+1`; Android + iOS |
| App state management | Riverpod | `flutter_riverpod ^3.3.2` |
| App navigation | go_router | `^17.3.0`, role-based route prefixes |
| App networking | Dio | `^5.10.0`, auth interceptor + refresh-token retry |
| App token storage | flutter_secure_storage | `^10.3.1` |
| App models | freezed + json_serializable | freezed `^3.2.5`, json_serializable `^6.14.0` (generated files committed) |
| **Backend (active)** | **Java 21, Spring Boot 3.4.1** | Folder `backend-java/`, artifact `atrio-pg-api`, port 8080 |
| Backend libraries | Spring Web, Spring Data JPA (Hibernate), Spring Security, Bean Validation, Actuator | |
| Backend auth | JWT (jjwt) access token + opaque refresh token | Access TTL 15 min, refresh TTL 30 days |
| Backend mapping | MapStruct + Lombok | |
| Backend DB migrations | Flyway | `V1` baseline, `V2` role_settable_once |
| Backend tests | JUnit 5, Spring Boot Test, Spring Security Test, Testcontainers | 10 test files |
| Backend (legacy) | NestJS 10 + TypeORM 0.3 + TypeScript 5.7 | Folder `backend/` — schema + entities only, no endpoints |

### 2.2 Deviation from `CLAUDE.md` — needs a decision

`CLAUDE.md` §2 locks the backend to **NestJS**. The project moved to **Java
Spring Boot** (see `docs/MIGRATION_PLAN.md`). The NestJS code in `backend/` is
kept as the original schema source and is not the running API. Before release,
either update `CLAUDE.md` §2 to say Spring Boot, or remove `backend/`.

All other stack choices match `CLAUDE.md` (Flutter, Riverpod, go_router,
PostgreSQL, JWT + phone OTP).

---

## 3. Database

| Item | Detail |
| --- | --- |
| Engine | **PostgreSQL** |
| Hosting | **Supabase** (hosted PostgreSQL); connection over SSL (`sslmode=require`) |
| Access (Java) | Spring Data JPA / Hibernate, `ddl-auto: validate` (never creates or alters tables), HikariCP pool (max 10) |
| Migrations | Original 12 TypeORM migrations built the schema; Flyway now manages changes (baseline at V1, then V2+). `synchronize` / `ddl-auto` never modify the schema. |
| Object storage | S3-compatible (Supabase Storage). Env keys exist; **upload code is not implemented yet** |

### 3.1 Tables (11) — all created

`users`, `otp_codes`, `refresh_tokens`, `properties`, `property_photos`,
`rooms`, `beds`, `occupancies`, `visit_requests`, `complaints`, `reviews`

Every table follows the `CLAUDE.md` rules: UUID primary key, `created_at`,
`updated_at`, and `deleted_at` (soft delete). Money is stored as `BIGINT` paise.
Flexible data (`amenities`, `rules`, complaint `photos`) is `JSONB`.

Phase 3 tables (`payments`, `notices`, `agreements`) are intentionally not
created yet.

### 3.2 Domain model

```
Property (owned by an owner)
  └── Room (e.g. 101, triple sharing)
        └── Bed (the unit that is rented)
              └── Occupancy (student in a bed for a period — never deleted)
```

---

## 4. Backend status (Java, `backend-java/`)

About 100 Java files (~6,600 lines), organised one package per domain under
`com.atrio.pg`: `auth`, `users`, `properties`, `rooms`, `beds`, `occupancies`,
`visitrequests`, `complaints`, `reviews`, `meta`, `health`, `common`, `config`.

### 4.1 Endpoints (all under `/api/v1`)

| Endpoint | Status |
| --- | --- |
| `POST /auth/otp/request` | Done |
| `POST /auth/otp/verify` | Done |
| `POST /auth/refresh` | Done |
| `POST /auth/logout` | Done |
| `PATCH /auth/profile` | Done |
| `GET /me` | Done |
| `GET /meta/amenities` | Done |
| `POST/GET /owner/properties`, `GET/PATCH /owner/properties/:id`, `PATCH /owner/properties/:id/status` | Done (plus `DELETE /owner/properties/:id`, an addition to the spec) |
| `GET /health` (root, for platform health checks) | Done |
| `POST /owner/properties/:id/photos`, `DELETE /owner/photos/:id` | **Not done** |
| `POST /owner/properties/:id/rooms`, `PATCH/DELETE /owner/rooms/:id`, `PATCH /owner/beds/:id` | **Not done** |
| `GET /owner/visit-requests`, `PATCH /owner/visit-requests/:id` | **Not done** |
| `GET /properties/search`, `GET /properties/:id` | **Not done** |
| `POST /visit-requests`, `GET /me/visit-requests`, `PATCH /me/visit-requests/:id/cancel` | **Not done** |

Entities and repositories already exist for rooms, beds, occupancies, visit
requests, complaints and reviews; only controllers and services are missing.

### 4.2 Cross-cutting work done

- Response envelope `{ success, data | error }` and error-code table
- Pagination (`page`, `limit`, `items`, `total`)
- Request validation, unknown JSON fields rejected (`fail-on-unknown-properties`)
- Spring Security: JWT filter, role-based access, ownership checks in services
- Phone OTP: 6-digit code, 5-minute expiry, max 5 attempts, request limit
  (3 per 10 minutes) — configured through environment variables
- SMS sender abstraction (logging / disabled implementations only; **no real
  SMS provider is connected**)
- Soft-delete handling on entities
- Config through environment variables; no secrets in code

### 4.3 Backend not done

- Real SMS provider integration
- S3 photo upload
- Search with distance queries (lat/lng) and filters
- Rate limiting beyond the OTP request limit — **unverified**
- Whether the 10 test files currently pass — **not run**

---

## 5. Flutter app status (`app/`)

About 58 hand-written Dart files (~8,000 lines) plus generated freezed/json
files, and 6 test files. Feature-first structure: `lib/features/<feature>/`
with `data/`, `application/`, `presentation/`, and shared code in `lib/core/`
(network, router, theme, storage, config, utils, widgets).

### 5.1 Screens against the Phase 1 list

| # | Screen | Status |
| --- | --- | --- |
| 1 | Splash + role routing | Done |
| 2 | Phone entry + OTP entry | Done |
| 3 | Complete profile | Done |
| 4 | Profile / settings | Done |
| 5 | Student search + filters | Placeholder ("Coming soon") |
| 6 | Map view | Placeholder |
| 7 | Property detail | Placeholder |
| 8 | Visit request form + My Visits | Placeholder |
| 9 | Owner dashboard | Done |
| 10 | Add/Edit property wizard (multi-step) | Done — photo upload step **unverified** (backend has no photo endpoint) |
| 11 | Property manage (rooms + bed grid) | Placeholder |
| 12 | Owner visit-requests inbox | Placeholder |

Extra screens beyond the list: owner property overview, and Phase 2/3
placeholder tabs (tenants, rent).

Data layer exists only for auth, meta (amenities) and owner properties. There
is no repository yet for student search, visits or rooms.

---

## 6. What was done so far (chronology)

1. **Foundation** — project rules written (`CLAUDE.md`); NestJS project created
   with all domain modules, TypeORM entities and 12 migrations; schema applied
   to Supabase and verified.
2. **Audit and plan** — `docs/CURRENT_STATE.md` and `docs/MIGRATION_PLAN.md`
   written; decision taken to build the API in Java Spring Boot.
3. **Java backend** — Spring Boot project, JPA entities, Flyway baseline,
   envelope/error handling, JWT security, OTP auth flow, `/me`, `/meta/amenities`,
   owner property CRUD, tests.
4. **Flutter app** — core (API client, router, theme), auth flow, profile,
   owner dashboard, property wizard, property overview.
5. **Repository preparation** — git initialised, `.gitignore` and `README.md`
   added, checked that no secrets or build output are staged.

Note: `docs/CURRENT_STATE.md` and `docs/MIGRATION_PLAN.md` are dated
2026-07-24 and describe the project **before** the Java backend and Flutter app
existed. They are historical; this file is the current status.

---

## 7. Remaining work for Phase 1

Suggested order:

1. Decide Java vs NestJS and update `CLAUDE.md` §2 accordingly.
2. Backend: rooms + auto-created beds, bed status, property min/max rent update.
3. Backend: photo upload (S3) and delete.
4. Backend: student search (filters, distance, sort, pagination) and property detail.
5. Backend: visit requests (student create/list/cancel; owner list/respond).
6. Flutter: property manage screen (rooms + bed grid).
7. Flutter: student search, filter sheet, map view, property detail.
8. Flutter: visit request form, My Visits, owner inbox.
9. Real SMS provider, then run all tests and `flutter analyze`.
10. Definition of Done pass: migrations up/down on a fresh DB, lint clean,
    soft-delete filtering verified on all new queries.

## 8. Later phases (not started)

- **Phase 2:** occupancy management UI, rent-due tracking, complaints UI,
  reviews UI.
- **Phase 3:** Razorpay payments, owner analytics, notices, food menu, digital
  agreements.

## 9. Security notes

- Real secrets live only in `backend/.env` (git-ignored). Only `.env.example`
  is committed.
- The Java backend reads `../backend/.env` as an optional config source. In
  production, use real environment variables.
- If any key was ever shared outside this machine, rotate it.
