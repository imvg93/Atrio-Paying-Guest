# CLAUDE.md — PG Finder & Hostel Management App

> This file is the single source of truth for this project. Read it fully before
> writing any code. Every session must follow the rules here. If a request in a
> prompt conflicts with this file, stop and ask before proceeding.

---

## 1. What We Are Building

A mobile application (Android + iOS) for the Indian PG/hostel market with two roles:

- **Students** — search PGs by location, budget, gender type, sharing type, and
  amenities; view photos and details; request a visit; contact the owner; later
  become tenants; raise complaints; leave reviews.
- **Owners** — list and manage properties; manage rooms and beds; track tenants
  (occupancies); handle visit requests and complaints; later track rent.

It is **one app with role-based views**, not two apps. A user's `role` decides
which screens and APIs they can access. Role checks are ALWAYS enforced on the
backend — never trust the client.

---

## 2. Tech Stack (locked — do not substitute)

| Layer     | Choice                                              |
| --------- | --------------------------------------------------- |
| Mobile    | Flutter (Dart), single codebase for Android + iOS   |
| Backend   | NestJS (TypeScript)                                 |
| Database  | PostgreSQL with TypeORM, versioned migrations only  |
| Geo       | lat/lng columns + PostGIS-style distance queries    |
| Storage   | S3-compatible object storage for photos/documents   |
| Auth      | Phone OTP login + JWT access token + refresh token  |
| State mgmt (Flutter) | Riverpod                                 |
| Navigation (Flutter) | go_router with role-based redirect       |

---

## 3. Non-Negotiable Architecture Rules (future-proofing)

These rules exist so future phases never require breaking changes. Never violate
them, even if it makes a task slightly longer.

### Database
1. **UUID primary keys** on every table (`uuid`, default `gen_random_uuid()`).
2. **Soft deletes only.** Every table has `deleted_at TIMESTAMPTZ NULL`. Never
   hard-delete rows. All default queries must filter out soft-deleted rows.
3. **Timestamps everywhere.** Every table has `created_at` and `updated_at`
   (auto-managed).
4. **Versioned migrations only.** TypeORM `synchronize` must be `false` in all
   environments. Every schema change is a new migration file. Never edit an
   already-committed migration.
5. **Never overwrite history.** Occupancies and payments are append-style
   records: end/close a record and create a new one; do not mutate the past.
6. **Flexible attributes in JSONB.** `properties.amenities`, notification
   payloads, and similar open-ended data use JSONB so new options need no
   migration.
7. **Money is stored as integer paise** (e.g., ₹8,500 → `850000`)? No — use
   integer **rupees** only if amounts are always whole; PG rents can include
   paise in fines, so: store all money as `BIGINT` in **paise**. Never floats.

### API
8. **All routes under `/api/v1/`.** Breaking changes go to `/api/v2/` later;
   `/api/v1/` must keep working for old app versions in the field.
9. **Additive changes only within v1.** New fields may be added to responses;
   existing fields are never renamed, retyped, or removed.
10. **Consistent response envelope** for every endpoint:
    ```json
    { "success": true,  "data": { ... } }
    { "success": false, "error": { "code": "STRING_CODE", "message": "..." } }
    ```
11. **Pagination on every list endpoint** from day one: `?page=&limit=` in,
    `{ items, page, limit, total }` out. Default limit 20, max 100.
12. **Validation with class-validator DTOs** on every input. Global
    `ValidationPipe` with `whitelist: true` and `forbidNonWhitelisted: true`.
13. **Auth guards + role guards** on every non-public endpoint. Ownership
    checks (e.g., an owner can only edit their own property) live in services,
    not controllers.

### Code structure
14. **Backend:** one NestJS module per domain (`auth`, `users`, `properties`,
    `rooms`, `beds`, `occupancies`, `visit-requests`, `complaints`, `reviews`).
    Controller → Service → Repository. No business logic in controllers.
15. **Flutter:** feature-first folders (`lib/features/<feature>/`), each with
    `data/` (API + models), `application/` (providers/state), and
    `presentation/` (screens + widgets). Shared code in `lib/core/`
    (theme, api_client, router, constants, widgets).
16. **No secrets in code.** Backend uses `.env` (+ committed `.env.example`).
    Flutter uses `--dart-define` / env config, never hardcoded URLs or keys.
17. **Small verified steps.** After each meaningful unit of work, stop and
    summarize what was created so it can be reviewed before continuing.

---

## 4. Domain Model — Core Insight

Students rent **beds**, not rooms. The hierarchy is:

```
Property (a PG building, owned by an owner)
  └── Room (e.g., Room 101, triple sharing)
        └── Bed (e.g., Bed A — the unit that gets rented)
              └── Occupancy (a student occupying a bed for a period — the contract)
```

`Occupancy` is the historical record that everything in Phase 2+ (rent,
complaints context, tenant history) hangs off. It is never deleted or
overwritten — it is opened (`start_date`) and closed (`end_date`).

---

## 5. Database Schema (Phase 1 tables — create ALL of these now)

Common columns on every table (not repeated below):
`id UUID PK`, `created_at`, `updated_at`, `deleted_at`.

### users
| column         | type        | notes                                   |
| -------------- | ----------- | --------------------------------------- |
| phone          | varchar(15) | unique, E.164 format, login identifier  |
| name           | varchar     | nullable until profile completed        |
| email          | varchar     | nullable, unique when present           |
| role           | enum        | `student` \| `owner` \| `admin`         |
| gender         | enum        | `male` \| `female` \| `other`, nullable |
| avatar_url     | varchar     | nullable                                |
| is_active      | boolean     | default true                            |
| last_login_at  | timestamptz | nullable                                |

### otp_codes
| column      | type        | notes                                     |
| ----------- | ----------- | ----------------------------------------- |
| phone       | varchar(15) | indexed                                   |
| code_hash   | varchar     | hashed OTP, never store plaintext         |
| expires_at  | timestamptz | 5-minute expiry                           |
| attempts    | int         | default 0, max 5                          |
| consumed_at | timestamptz | nullable                                  |

### refresh_tokens
| column     | type        | notes                          |
| ---------- | ----------- | ------------------------------ |
| user_id    | UUID FK     | → users                        |
| token_hash | varchar     | hashed, rotated on use         |
| expires_at | timestamptz |                                |
| revoked_at | timestamptz | nullable                       |

### properties
| column       | type          | notes                                                |
| ------------ | ------------- | ---------------------------------------------------- |
| owner_id     | UUID FK       | → users (role owner)                                 |
| name         | varchar       |                                                      |
| description  | text          | nullable                                             |
| gender_type  | enum          | `male` \| `female` \| `coliving`                     |
| address_line | varchar       |                                                      |
| locality     | varchar       | indexed (search)                                     |
| city         | varchar       | indexed                                              |
| state        | varchar       |                                                      |
| pincode      | varchar(10)   |                                                      |
| latitude     | decimal(9,6)  |                                                      |
| longitude    | decimal(9,6)  |                                                      |
| amenities    | jsonb         | e.g. `{"wifi":true,"food":true,"ac":false,...}`      |
| rules        | jsonb         | nullable, e.g. gate timing, visitors policy          |
| food_included| boolean       | default false                                        |
| notice_period_days | int     | default 30                                           |
| status       | enum          | `draft` \| `published` \| `unlisted`                 |
| min_rent_paise | bigint      | denormalized for search cards, updated from rooms    |
| max_rent_paise | bigint      | denormalized for search cards, updated from rooms    |

### property_photos
| column      | type    | notes                          |
| ----------- | ------- | ------------------------------ |
| property_id | UUID FK | → properties                   |
| url         | varchar |                                |
| sort_order  | int     | default 0                      |
| caption     | varchar | nullable                       |

### rooms
| column        | type   | notes                                              |
| ------------- | ------ | -------------------------------------------------- |
| property_id   | UUID FK| → properties                                       |
| room_number   | varchar| unique per property                                |
| floor         | int    | nullable                                           |
| sharing_type  | enum   | `single` \| `double` \| `triple` \| `four_plus`    |
| rent_per_bed_paise | bigint |                                               |
| deposit_paise | bigint | default = rent, editable                           |
| has_attached_bathroom | boolean | default false                             |
| has_ac        | boolean| default false                                      |

### beds
| column   | type    | notes                                            |
| -------- | ------- | ------------------------------------------------ |
| room_id  | UUID FK | → rooms                                          |
| label    | varchar | e.g. "A", "B"; unique per room                   |
| status   | enum    | `available` \| `occupied` \| `maintenance`       |

### occupancies  *(table created now; UI comes in Phase 2)*
| column        | type        | notes                                        |
| ------------- | ----------- | -------------------------------------------- |
| bed_id        | UUID FK     | → beds                                       |
| student_id    | UUID FK     | → users                                      |
| start_date    | date        |                                              |
| end_date      | date        | nullable = ongoing                           |
| rent_paise    | bigint      | locked at move-in (rent may change later)    |
| deposit_paise | bigint      |                                              |
| status        | enum        | `active` \| `notice_period` \| `ended`       |

### visit_requests
| column        | type        | notes                                            |
| ------------- | ----------- | ------------------------------------------------ |
| property_id   | UUID FK     | → properties                                     |
| student_id    | UUID FK     | → users                                          |
| preferred_date| date        |                                                  |
| preferred_slot| enum        | `morning` \| `afternoon` \| `evening`            |
| message       | text        | nullable                                         |
| status        | enum        | `pending` \| `accepted` \| `declined` \| `completed` \| `cancelled` |
| responded_at  | timestamptz | nullable                                         |

### complaints  *(table now; UI in Phase 2)*
| column      | type    | notes                                                  |
| ----------- | ------- | ------------------------------------------------------ |
| occupancy_id| UUID FK | → occupancies                                          |
| category    | enum    | `electrical` \| `plumbing` \| `cleaning` \| `food` \| `wifi` \| `other` |
| title       | varchar |                                                        |
| description | text    |                                                        |
| photos      | jsonb   | array of URLs, nullable                                |
| status      | enum    | `open` \| `in_progress` \| `resolved` \| `closed`      |
| resolved_at | timestamptz | nullable                                           |

### reviews  *(table now; UI in Phase 2)*
| column      | type    | notes                                    |
| ----------- | ------- | ---------------------------------------- |
| property_id | UUID FK | → properties                             |
| student_id  | UUID FK | → users; one review per student/property |
| rating      | int     | 1–5                                      |
| comment     | text    | nullable                                 |

**Phase 3 tables (`payments`, `notices`, `agreements`) are NOT created yet** —
but nothing above may be designed in a way that blocks them. `payments` will FK
to `occupancies`, which is why occupancy history is sacred.

---

## 6. API Surface — Phase 1 (`/api/v1`)

### Auth (public)
- `POST /auth/otp/request` — body `{ phone }`; rate-limited (max 3/phone/10min)
- `POST /auth/otp/verify` — body `{ phone, code }` → `{ accessToken, refreshToken, user, isNewUser }`
- `POST /auth/refresh` — rotate refresh token
- `POST /auth/logout` — revoke refresh token
- `PATCH /auth/profile` — complete profile: name, role (settable once), gender, email

### Owner (role: owner)
- `POST /owner/properties` · `GET /owner/properties` · `GET /owner/properties/:id`
- `PATCH /owner/properties/:id` · `PATCH /owner/properties/:id/status`
- `POST /owner/properties/:id/photos` (multipart upload) · `DELETE /owner/photos/:photoId`
- `POST /owner/properties/:id/rooms` · `PATCH /owner/rooms/:id` · `DELETE /owner/rooms/:id`
- Beds are auto-created from `sharing_type` when a room is created; `PATCH /owner/beds/:id` to change status/label
- `GET /owner/visit-requests?status=` · `PATCH /owner/visit-requests/:id` (accept/decline/complete)

### Student (role: student)
- `GET /properties/search` — public-readable; filters:
  `city`, `locality`, `lat`+`lng`+`radius_km`, `gender_type`, `min_rent`,
  `max_rent`, `sharing_type`, `amenities` (csv), `food_included`,
  `sort` (`distance` | `rent_asc` | `rent_desc` | `newest`), paginated.
  Only `status = published` properties with at least one available bed.
- `GET /properties/:id` — full detail: photos, rooms grouped by sharing type
  with rent + availability count, amenities, rules, location, owner display name
- `POST /visit-requests` · `GET /me/visit-requests` · `PATCH /me/visit-requests/:id/cancel`

### Shared
- `GET /me` — current user profile
- `GET /meta/amenities` — canonical amenity list (server-driven so new
  amenities need no app update)

---

## 7. Flutter App — Phase 1 Screens

### Common
1. Splash → auth check → route by role
2. Phone entry → OTP entry
3. Complete profile (name, choose role, gender) — role chosen once
4. Profile / settings (edit profile, logout)

### Student flow
5. Home / Search — search bar, filter sheet (budget slider, gender, sharing,
   amenities, food), results as cards (photo, name, locality, min rent,
   gender badge, distance)
6. Map view toggle for results
7. Property detail — photo carousel, rooms & pricing table, amenities grid,
   rules, map preview, "Request a Visit" CTA + call owner button
8. Visit request form (date + slot + message) and "My Visits" list with status

### Owner flow
9. Dashboard — properties list with occupancy summary (X/Y beds filled)
10. Add/Edit property (multi-step: basics → location w/ map pin → amenities →
    photos → publish)
11. Property manage screen — rooms list; add/edit room (auto-creates beds);
    bed status grid (tap to toggle available/maintenance)
12. Visit requests inbox — accept / decline / mark completed

### Flutter rules
- All API calls through one `ApiClient` (Dio) with auth interceptor +
  automatic refresh-token retry.
- Models via `freezed` + `json_serializable`.
- Every screen handles: loading, empty, error (with retry), success.
- No business logic in widgets — it lives in Riverpod providers.

---

## 8. Phase Roadmap (context for future sessions)

- **Phase 1 (now):** everything above. No payments, no rent tracking UI.
- **Phase 2:** occupancy management UI (owner assigns student to bed),
  rent-due tracking + reminders (manual "mark paid"), complaints UI, reviews UI.
- **Phase 3:** online payments (Razorpay) writing to `payments` table,
  owner analytics dashboard, notices/announcements, food menu, digital
  agreements.

Rule: Phases add tables and columns. They must never require renaming,
retyping, or restructuring anything that exists.

---

## 9. Definition of Done (every task, every session)

- Migrations run cleanly on a fresh database (`up`) and revert (`down`).
- Lint passes (`eslint` backend, `flutter analyze` app) with zero errors.
- New endpoints have DTO validation + auth/role guards + ownership checks.
- Soft-delete filtering verified on any new queries.
- A short summary of files created/changed is given for review before moving
  to the next task.
