# ATRIO-PG — Current State Audit

**Audit date:** 2026-07-24
**Audited by:** automated read-only review of the full repository + a live
introspection of the running Supabase database.
**Purpose:** this document is the contract a replacement (Java) backend must
match. Where something is *specified but not built*, it is labelled as such —
do not read an unbuilt spec as an observed behaviour.

---

## 0. Executive summary — read this first

> **The backend has no API. Zero HTTP endpoints exist.**

The repository contains a complete, migrated, verified **database schema** and
the **NestJS scaffolding** around it (config, envelope, validation pipe, base
entity, ORM entities). It contains **no controllers, no services, no DTOs
beyond pagination, no guards, no authentication, and no external
integrations.**

| Layer | State |
| --- | --- |
| Database schema (11 tables) | ✅ Built, migrated, verified live |
| TypeORM entities + enums | ✅ Built (11 entities, 9 enums) |
| App scaffolding (envelope, validation, config) | ✅ Built |
| HTTP endpoints | ❌ **None** (0 of ~25 specified) |
| Auth / OTP / JWT | ❌ None |
| Business logic (services) | ❌ None |
| External integrations (SMS, S3) | ❌ None — config keys exist, no client code |
| Flutter app | ❌ Does not exist |
| Tests | ❌ None, no test framework installed |
| Version control | ❌ **Not a git repository** |

**Consequence for the Java port:** sections 3 (database) and the envelope/error
contract in section 2 are real, binding, and portable. Section 2's endpoint
list and section 4's business rules are *design intent from `CLAUDE.md`*, not
working code — the Java implementation will be the first implementation, not a
reimplementation. Section 6 lists every gap and ambiguity that must be resolved
before or during that work.

---

## 1. Project structure

Repository root: `ATRIO-PG/`

| Path | Responsibility |
| --- | --- |
| `CLAUDE.md` | Project constitution. Tech stack, architecture rules, target schema, target API surface, phase roadmap. Single source of truth for intent. |
| `docs/CURRENT_STATE.md` | This document. |
| `backend/` | The NestJS API. The only application code that exists. |
| *(no `app/` or `mobile/`)* | **The Flutter app required by `CLAUDE.md` §2 and §7 has not been started.** |

### 1.1 `backend/` — top level

| Path | Responsibility |
| --- | --- |
| `package.json` | Deps + scripts. Notably: no test runner, no auth libs, no cloud SDKs. |
| `tsconfig.json`, `nest-cli.json` | TypeScript / Nest build config. |
| `.eslintrc.js`, `.prettierrc` | Lint + format. `npm run lint` passes with 0 errors. |
| `.env.example` | Committed template of every env var. No secrets. |
| `.env` | Real secrets (Supabase password, JWT secrets). Git-ignored. **Present on disk.** |
| `.gitignore` | Ignores `node_modules/`, `dist/`, `.env*`, logs, editor dirs. Currently inert — no git repo exists. |
| `docker-compose.yml` | Postgres 16 container. **Unused** — the project runs against hosted Supabase. Dead weight. |
| `README.md` | Setup + conventions. Accurate as of this audit. |

### 1.2 `backend/src/` — module map

| Path | Responsibility | Contains |
| --- | --- | --- |
| `main.ts` | Bootstrap. Sets global prefix, ValidationPipe, response interceptor, exception filter, shutdown hooks. | — |
| `app.module.ts` | Root module. Loads config (Joi-validated), `DatabaseModule`, and all 9 domain modules. | — |
| `config/configuration.ts` | Typed config factory: `env`, `port`, `apiPrefix`, `database`, `jwt`, `otp`, `s3`. | — |
| `config/env.validation.ts` | Joi schema. Fails boot on missing/invalid env. | — |
| `database/typeorm.config.ts` | Single source of connection options, shared by the Nest runtime and the TypeORM CLI. `synchronize: false` hardcoded. | — |
| `database/data-source.ts` | TypeORM CLI entrypoint. Loads `.env` via dotenv (CLI runs outside Nest DI). | — |
| `database/database.module.ts` | `TypeOrmModule.forRootAsync` wrapper. | — |
| `database/migrations/` | 12 versioned migrations. | See §3.14 |
| `common/entities/base.entity.ts` | `BaseEntity`: `id` (uuid PK), `createdAt`, `updatedAt`, `deletedAt` (`@DeleteDateColumn`). Every entity extends it. | — |
| `common/dto/pagination.dto.ts` | `PaginationQueryDto` (page/limit + `skip` getter), `PaginatedResult<T>` interface, `paginated()` helper. **Defined, never used.** | — |
| `common/interceptors/response.interceptor.ts` | Wraps every success in `{success:true,data}`. | — |
| `common/filters/all-exceptions.filter.ts` | Renders every failure as `{success:false,error:{code,message,details?}}`. | — |
| `common/transformers/numeric.transformer.ts` | `bigintTransformer` (pg bigint string → JS number), `decimalTransformer` (pg numeric string → JS float). | — |

### 1.3 `backend/src/modules/` — the 9 domain modules

Every module follows the same shape and is currently a **skeleton**: it
registers its entities with `TypeOrmModule.forFeature()` and re-exports
`TypeOrmModule`. None declares a controller or provider.

| Module | Entities | Enums | Controller | Service |
| --- | --- | --- | --- | --- |
| `auth` | `OtpCode`, `RefreshToken` | — | ❌ | ❌ |
| `users` | `User` | `UserRole`, `Gender` | ❌ | ❌ |
| `properties` | `Property`, `PropertyPhoto` | `PropertyGenderType`, `PropertyStatus`, `PropertyAmenities`, `PropertyRules` | ❌ | ❌ |
| `rooms` | `Room` | `SharingType`, `BEDS_PER_SHARING_TYPE` | ❌ | ❌ |
| `beds` | `Bed` | `BedStatus` | ❌ | ❌ |
| `occupancies` | `Occupancy` | `OccupancyStatus` | ❌ | ❌ |
| `visit-requests` | `VisitRequest` | `VisitSlot`, `VisitRequestStatus` | ❌ | ❌ |
| `complaints` | `Complaint` | `ComplaintCategory`, `ComplaintStatus` | ❌ | ❌ |
| `reviews` | `Review` | — | ❌ | ❌ |

`auth` additionally imports `UsersModule`. That is the only inter-module
dependency wired so far.

---

## 2. API inventory

### 2.1 Implemented endpoints

**None.** A repository-wide search for `@Controller`, `@Injectable` (outside
the response interceptor), `@UseGuards`, `CanActivate`, and `PassportStrategy`
returns no matches in any domain module. The application boots and listens on
`http://localhost:3000/api/v1`, but every path returns 404.

Verified by boot: all 9 domain modules initialise, `TypeOrmCoreModule`
connects, `Nest application successfully started`. No routes are mapped.

### 2.2 Global request/response contract — **this part is real and binding**

The envelope, validation, and error-code machinery exist and work. Any Java
implementation must reproduce them exactly.

#### Global prefix

Every route is served under `/{API_PREFIX}`, default `api/v1`
(`main.ts:14`, config key `apiPrefix`).

#### Success envelope

`ResponseInterceptor` wraps **every** successful handler return value:

```json
{ "success": true, "data": <handler return value> }
```

There is no opt-out. A handler returning a list must return the paginated
object as its value, producing:

```json
{ "success": true, "data": { "items": [], "page": 1, "limit": 20, "total": 0 } }
```

#### Error envelope

`AllExceptionsFilter` catches everything (`@Catch()` with no argument):

```json
{ "success": false, "error": { "code": "STRING_CODE", "message": "..." } }
```

`details` is added only for validation failures:

```json
{ "success": false,
  "error": { "code": "VALIDATION_ERROR",
             "message": "Request validation failed.",
             "details": ["phone must be a valid phone number"] } }
```

#### Error code table — complete and exhaustive

Derived from `all-exceptions.filter.ts:20-29` and the branch logic at
`:49-76`.

| HTTP status | `error.code` | `error.message` | When |
| --- | --- | --- | --- |
| 400 | `BAD_REQUEST` | from the exception | Any `BadRequestException` with a string/object message |
| 400 | `VALIDATION_ERROR` | `Request validation failed.` | `ValidationPipe` failure — message is an array; array is echoed in `details` |
| 401 | `UNAUTHORIZED` | from the exception | `UnauthorizedException` |
| 403 | `FORBIDDEN` | from the exception | `ForbiddenException` |
| 404 | `NOT_FOUND` | from the exception | `NotFoundException` |
| 409 | `CONFLICT` | from the exception | `ConflictException` |
| 422 | `UNPROCESSABLE_ENTITY` | from the exception | `UnprocessableEntityException` |
| 429 | `TOO_MANY_REQUESTS` | from the exception | `ThrottlerException` — **no throttler is installed**, so unreachable today |
| 500 | `INTERNAL_ERROR` | `Something went wrong. Please try again.` | Any non-`HttpException` throwable. Logged with stack. |
| *any other* | `HTTP_ERROR` | from the exception | Any `HttpException` whose status is not in the table above |
| *as thrown* | **custom** | from the exception | **Override:** if a thrown `HttpException`'s response object has a string `code` property, it replaces the mapped code. This is the intended mechanism for domain codes such as `OTP_EXPIRED`. |

**Note for the Java port:** the custom-code override is the only extension
point. No domain error codes are defined anywhere in the codebase yet — the
list of `OTP_INVALID` / `OTP_EXPIRED` / `PHONE_RATE_LIMITED` style codes
implied by `CLAUDE.md` §6 **does not exist and must be designed.**

#### Validation pipe settings (`main.ts:17-24`)

| Option | Value | Effect |
| --- | --- | --- |
| `whitelist` | `true` | Strips properties with no decorator |
| `forbidNonWhitelisted` | `true` | **400** if the body/query carries any undeclared property |
| `transform` | `true` | Instantiates the DTO class |
| `transformOptions.enableImplicitConversion` | `false` | No implicit string→number coercion; each field needs `@Type()` |

#### The only DTO that exists

`PaginationQueryDto` (`common/dto/pagination.dto.ts`) — defined but referenced
by nothing.

| Field | Type | Rules | Default |
| --- | --- | --- | --- |
| `page` | number | `@IsOptional` `@Type(()=>Number)` `@IsInt` `@Min(1)` | `1` |
| `limit` | number | `@IsOptional` `@Type(()=>Number)` `@IsInt` `@Min(1)` `@Max(100)` | `20` |

Exposes `get skip()` → `(page - 1) * limit`.
Helper `paginated(items, total, query)` → `{ items, page, limit, total }`.

### 2.3 Specified-but-unbuilt endpoint surface

Everything below comes from `CLAUDE.md` §6. **None of it is implemented.**
There are no DTOs, no validation rules, no response shapes, and no error codes
for any of it — those must be designed as part of the Java build. Request/
response columns below say only what `CLAUDE.md` states; anything more would
be invention.

#### Auth (public)

| Method | Path | Auth | Body per `CLAUDE.md` | Response per `CLAUDE.md` | Notes |
| --- | --- | --- | --- | --- | --- |
| POST | `/auth/otp/request` | public | `{ phone }` | not specified | Rate limit: max 3 per phone per 10 min |
| POST | `/auth/otp/verify` | public | `{ phone, code }` | `{ accessToken, refreshToken, user, isNewUser }` | Shape of `user` not specified |
| POST | `/auth/refresh` | public (bearer refresh) | not specified | not specified | "rotate refresh token" |
| POST | `/auth/logout` | authenticated | not specified | not specified | "revoke refresh token" |
| PATCH | `/auth/profile` | authenticated | `name`, `role`, `gender`, `email` | not specified | **`role` settable once** — no mechanism exists |

#### Owner (role: `owner`)

| Method | Path | Auth | Notes |
| --- | --- | --- | --- |
| POST | `/owner/properties` | owner | — |
| GET | `/owner/properties` | owner | List → must paginate |
| GET | `/owner/properties/:id` | owner + ownership | — |
| PATCH | `/owner/properties/:id` | owner + ownership | — |
| PATCH | `/owner/properties/:id/status` | owner + ownership | draft/published/unlisted |
| POST | `/owner/properties/:id/photos` | owner + ownership | multipart upload |
| DELETE | `/owner/photos/:photoId` | owner + ownership | Soft delete only |
| POST | `/owner/properties/:id/rooms` | owner + ownership | **Auto-creates beds** from `sharing_type` |
| PATCH | `/owner/rooms/:id` | owner + ownership | — |
| DELETE | `/owner/rooms/:id` | owner + ownership | Soft delete only |
| PATCH | `/owner/beds/:id` | owner + ownership | Change status/label |
| GET | `/owner/visit-requests?status=` | owner | List → must paginate |
| PATCH | `/owner/visit-requests/:id` | owner + ownership | accept / decline / complete |

#### Student / public

| Method | Path | Auth | Notes |
| --- | --- | --- | --- |
| GET | `/properties/search` | public-readable | Filters: `city`, `locality`, `lat`+`lng`+`radius_km`, `gender_type`, `min_rent`, `max_rent`, `sharing_type`, `amenities` (csv), `food_included`, `sort` (`distance`\|`rent_asc`\|`rent_desc`\|`newest`), paginated. Only `status='published'` **with ≥1 available bed**. |
| GET | `/properties/:id` | public-readable | Photos, rooms grouped by sharing type with rent + availability count, amenities, rules, location, owner display name |
| POST | `/visit-requests` | student | — |
| GET | `/me/visit-requests` | student | List → must paginate |
| PATCH | `/me/visit-requests/:id/cancel` | student + ownership | — |

#### Shared

| Method | Path | Auth | Notes |
| --- | --- | --- | --- |
| GET | `/me` | authenticated | Current user profile |
| GET | `/meta/amenities` | not specified | Canonical amenity list, server-driven. **No source of truth for this list exists anywhere in the codebase or database.** |

**Total: ~25 specified endpoints, 0 implemented.**

---

## 3. Database

**Live target:** Supabase-hosted PostgreSQL, project ref
`ljcwcjwiyeiyzgkmmbhn`, database `postgres`, schema `public`, SSL required.
Connection settings live in `backend/.env`; `synchronize` is hardcoded `false`
in `typeorm.config.ts:24`.

Everything in this section was **verified against the live database** by
introspecting `information_schema`, `pg_indexes`, `pg_constraint`, and
`pg_enum`. The live schema matches the migrations exactly — no drift.

### 3.0 Conventions applied to every table

- `id uuid PRIMARY KEY DEFAULT gen_random_uuid()` (pgcrypto).
- `created_at timestamptz NOT NULL DEFAULT now()`.
- `updated_at timestamptz NOT NULL DEFAULT now()`, maintained by **both**
  TypeORM's `@UpdateDateColumn` **and** a per-table `BEFORE UPDATE` trigger
  `trg_<table>_updated_at` calling `set_updated_at()`. The trigger exists so
  raw SQL writes stay correct.
- `deleted_at timestamptz NULL` — soft delete. Present on all 11 tables.
- Every unique constraint is a **partial unique index** scoped
  `WHERE deleted_at IS NULL`, so a soft-deleted row never blocks re-creating
  the same natural key.
- Every foreign key is `ON DELETE RESTRICT` — the database refuses hard
  deletes rather than relying on discipline.

### 3.1 `users`

| Column | Type | Null | Default |
| --- | --- | --- | --- |
| `id` | uuid | NOT NULL | `gen_random_uuid()` |
| `phone` | varchar(15) | NOT NULL | — |
| `name` | varchar(255) | NULL | — |
| `email` | varchar(255) | NULL | — |
| `role` | `users_role_enum` | NOT NULL | `'student'` |
| `gender` | `users_gender_enum` | NULL | — |
| `avatar_url` | varchar(512) | NULL | — |
| `is_active` | boolean | NOT NULL | `true` |
| `last_login_at` | timestamptz | NULL | — |
| `created_at` | timestamptz | NOT NULL | `now()` |
| `updated_at` | timestamptz | NOT NULL | `now()` |
| `deleted_at` | timestamptz | NULL | — |

**Indexes**
- `users_pkey` UNIQUE (`id`)
- `uq_users_phone` UNIQUE (`phone`) `WHERE deleted_at IS NULL`
- `uq_users_email` UNIQUE (`lower(email)`) `WHERE deleted_at IS NULL AND email IS NOT NULL` — **case-insensitive; the Java port must replicate `lower()`**
- `idx_users_role` (`role`)

**FKs:** none. **Checks:** none.

### 3.2 `otp_codes`

| Column | Type | Null | Default |
| --- | --- | --- | --- |
| `id` | uuid | NOT NULL | `gen_random_uuid()` |
| `phone` | varchar(15) | NOT NULL | — |
| `code_hash` | varchar(255) | NOT NULL | — |
| `expires_at` | timestamptz | NOT NULL | — |
| `attempts` | integer | NOT NULL | `0` |
| `consumed_at` | timestamptz | NULL | — |
| `created_at` | timestamptz | NOT NULL | `now()` |
| `updated_at` | timestamptz | NOT NULL | `now()` |
| `deleted_at` | timestamptz | NULL | — |

**Indexes**
- `otp_codes_pkey` UNIQUE (`id`)
- `idx_otp_codes_phone` (`phone`)
- `idx_otp_codes_expires_at` (`expires_at`)
- `idx_otp_codes_phone_created_at` (`phone`, `created_at DESC`) `WHERE deleted_at IS NULL` — serves both the rate limiter and the "latest live code" lookup

**FKs:** none — deliberately not FK'd to `users`, since an OTP is requested
before a user exists. **Checks:** none (no DB-level cap on `attempts`).

### 3.3 `refresh_tokens`

| Column | Type | Null | Default |
| --- | --- | --- | --- |
| `id` | uuid | NOT NULL | `gen_random_uuid()` |
| `user_id` | uuid | NOT NULL | — |
| `token_hash` | varchar(255) | NOT NULL | — |
| `expires_at` | timestamptz | NOT NULL | — |
| `revoked_at` | timestamptz | NULL | — |
| `created_at` | timestamptz | NOT NULL | `now()` |
| `updated_at` | timestamptz | NOT NULL | `now()` |
| `deleted_at` | timestamptz | NULL | — |

**Indexes**
- `refresh_tokens_pkey` UNIQUE (`id`)
- `uq_refresh_tokens_token_hash` UNIQUE (`token_hash`) `WHERE deleted_at IS NULL`
- `idx_refresh_tokens_user_id` (`user_id`)
- `idx_refresh_tokens_expires_at` (`expires_at`)

**FKs:** `fk_refresh_tokens_user` (`user_id`) → `users(id)` ON DELETE RESTRICT.
**Checks:** none.

### 3.4 `properties`

| Column | Type | Null | Default |
| --- | --- | --- | --- |
| `id` | uuid | NOT NULL | `gen_random_uuid()` |
| `owner_id` | uuid | NOT NULL | — |
| `name` | varchar(255) | NOT NULL | — |
| `description` | text | NULL | — |
| `gender_type` | `properties_gender_type_enum` | NOT NULL | — |
| `address_line` | varchar(512) | NOT NULL | — |
| `locality` | varchar(255) | NOT NULL | — |
| `city` | varchar(255) | NOT NULL | — |
| `state` | varchar(255) | NOT NULL | — |
| `pincode` | varchar(10) | NOT NULL | — |
| `latitude` | numeric(9,6) | NOT NULL | — |
| `longitude` | numeric(9,6) | NOT NULL | — |
| `amenities` | jsonb | NOT NULL | `'{}'::jsonb` |
| `rules` | jsonb | NULL | — |
| `food_included` | boolean | NOT NULL | `false` |
| `notice_period_days` | integer | NOT NULL | `30` |
| `status` | `properties_status_enum` | NOT NULL | `'draft'` |
| `min_rent_paise` | bigint | **NULL** | — |
| `max_rent_paise` | bigint | **NULL** | — |
| `created_at` | timestamptz | NOT NULL | `now()` |
| `updated_at` | timestamptz | NOT NULL | `now()` |
| `deleted_at` | timestamptz | NULL | — |

**Indexes**
- `properties_pkey` UNIQUE (`id`)
- `idx_properties_owner_id` (`owner_id`)
- `idx_properties_city` (`city`)
- `idx_properties_locality` (`locality`)
- `idx_properties_status` (`status`)
- `idx_properties_lat_lng` (`latitude`, `longitude`) — bounding-box prefilter before distance maths
- `idx_properties_search` (`city`, `gender_type`, `min_rent_paise`) `WHERE deleted_at IS NULL AND status = 'published'` — the search hot path
- `idx_properties_amenities` **GIN** (`amenities`) — for JSONB containment (`@>`) amenity filtering

**FKs:** `fk_properties_owner` (`owner_id`) → `users(id)` ON DELETE RESTRICT.

**Checks**
- `chk_properties_latitude`: `latitude BETWEEN -90 AND 90`
- `chk_properties_longitude`: `longitude BETWEEN -180 AND 180`
- `chk_properties_notice_period_days`: `notice_period_days >= 0`
- `chk_properties_rent_range`: `min_rent_paise IS NULL OR max_rent_paise IS NULL OR min_rent_paise <= max_rent_paise`

### 3.5 `property_photos`

| Column | Type | Null | Default |
| --- | --- | --- | --- |
| `id` | uuid | NOT NULL | `gen_random_uuid()` |
| `property_id` | uuid | NOT NULL | — |
| `url` | varchar(1024) | NOT NULL | — |
| `sort_order` | integer | NOT NULL | `0` |
| `caption` | varchar(255) | NULL | — |
| `created_at` | timestamptz | NOT NULL | `now()` |
| `updated_at` | timestamptz | NOT NULL | `now()` |
| `deleted_at` | timestamptz | NULL | — |

**Indexes**
- `property_photos_pkey` UNIQUE (`id`)
- `idx_property_photos_property_id` (`property_id`, `sort_order`) `WHERE deleted_at IS NULL`

**FKs:** `fk_property_photos_property` (`property_id`) → `properties(id)` ON DELETE RESTRICT.
**Checks:** none.

### 3.6 `rooms`

| Column | Type | Null | Default |
| --- | --- | --- | --- |
| `id` | uuid | NOT NULL | `gen_random_uuid()` |
| `property_id` | uuid | NOT NULL | — |
| `room_number` | varchar(50) | NOT NULL | — |
| `floor` | integer | NULL | — |
| `sharing_type` | `rooms_sharing_type_enum` | NOT NULL | — |
| `rent_per_bed_paise` | bigint | NOT NULL | — |
| `deposit_paise` | bigint | NOT NULL | — |
| `has_attached_bathroom` | boolean | NOT NULL | `false` |
| `has_ac` | boolean | NOT NULL | `false` |
| `created_at` | timestamptz | NOT NULL | `now()` |
| `updated_at` | timestamptz | NOT NULL | `now()` |
| `deleted_at` | timestamptz | NULL | — |

**Indexes**
- `rooms_pkey` UNIQUE (`id`)
- `uq_rooms_property_room_number` UNIQUE (`property_id`, `room_number`) `WHERE deleted_at IS NULL`
- `idx_rooms_property_id` (`property_id`)
- `idx_rooms_sharing_type` (`sharing_type`)

**FKs:** `fk_rooms_property` (`property_id`) → `properties(id)` ON DELETE RESTRICT.

**Checks**
- `chk_rooms_rent_non_negative`: `rent_per_bed_paise >= 0`
- `chk_rooms_deposit_non_negative`: `deposit_paise >= 0`

Note: `deposit_paise` is `NOT NULL` with **no default**, though `CLAUDE.md` §5
says "default = rent, editable". That defaulting must happen in application
code — the database will reject an insert that omits it.

### 3.7 `beds`

| Column | Type | Null | Default |
| --- | --- | --- | --- |
| `id` | uuid | NOT NULL | `gen_random_uuid()` |
| `room_id` | uuid | NOT NULL | — |
| `label` | varchar(20) | NOT NULL | — |
| `status` | `beds_status_enum` | NOT NULL | `'available'` |
| `created_at` | timestamptz | NOT NULL | `now()` |
| `updated_at` | timestamptz | NOT NULL | `now()` |
| `deleted_at` | timestamptz | NULL | — |

**Indexes**
- `beds_pkey` UNIQUE (`id`)
- `uq_beds_room_label` UNIQUE (`room_id`, `label`) `WHERE deleted_at IS NULL`
- `idx_beds_room_id` (`room_id`)
- `idx_beds_status` (`status`)
- `idx_beds_available` (`room_id`) `WHERE deleted_at IS NULL AND status = 'available'` — supports the "≥1 available bed" search filter

**FKs:** `fk_beds_room` (`room_id`) → `rooms(id)` ON DELETE RESTRICT.
**Checks:** none. Nothing at the DB level ties bed count to `sharing_type`.

### 3.8 `occupancies`

| Column | Type | Null | Default |
| --- | --- | --- | --- |
| `id` | uuid | NOT NULL | `gen_random_uuid()` |
| `bed_id` | uuid | NOT NULL | — |
| `student_id` | uuid | NOT NULL | — |
| `start_date` | date | NOT NULL | — |
| `end_date` | date | NULL | — (null = ongoing) |
| `rent_paise` | bigint | NOT NULL | — |
| `deposit_paise` | bigint | NOT NULL | — |
| `status` | `occupancies_status_enum` | NOT NULL | `'active'` |
| `created_at` | timestamptz | NOT NULL | `now()` |
| `updated_at` | timestamptz | NOT NULL | `now()` |
| `deleted_at` | timestamptz | NULL | — |

**Indexes**
- `occupancies_pkey` UNIQUE (`id`)
- `uq_occupancies_open_per_bed` UNIQUE (`bed_id`) `WHERE deleted_at IS NULL AND end_date IS NULL` — **at most one open occupancy per bed**; closed rows are exempt so history accumulates
- `idx_occupancies_bed_id` (`bed_id`)
- `idx_occupancies_student_id` (`student_id`)
- `idx_occupancies_status` (`status`)

**FKs**
- `fk_occupancies_bed` (`bed_id`) → `beds(id)` ON DELETE RESTRICT
- `fk_occupancies_student` (`student_id`) → `users(id)` ON DELETE RESTRICT

**Checks**
- `chk_occupancies_date_order`: `end_date IS NULL OR end_date >= start_date`
- `chk_occupancies_rent_non_negative`: `rent_paise >= 0`
- `chk_occupancies_deposit_non_negative`: `deposit_paise >= 0`

This is the table `CLAUDE.md` calls sacred — Phase 3 `payments` will FK here.

### 3.9 `visit_requests`

| Column | Type | Null | Default |
| --- | --- | --- | --- |
| `id` | uuid | NOT NULL | `gen_random_uuid()` |
| `property_id` | uuid | NOT NULL | — |
| `student_id` | uuid | NOT NULL | — |
| `preferred_date` | date | NOT NULL | — |
| `preferred_slot` | `visit_requests_preferred_slot_enum` | NOT NULL | — |
| `message` | text | NULL | — |
| `status` | `visit_requests_status_enum` | NOT NULL | `'pending'` |
| `responded_at` | timestamptz | NULL | — |
| `created_at` | timestamptz | NOT NULL | `now()` |
| `updated_at` | timestamptz | NOT NULL | `now()` |
| `deleted_at` | timestamptz | NULL | — |

**Indexes**
- `visit_requests_pkey` UNIQUE (`id`)
- `idx_visit_requests_property_id` (`property_id`)
- `idx_visit_requests_student_id` (`student_id`)
- `idx_visit_requests_status` (`status`)
- `idx_visit_requests_property_status` (`property_id`, `status`, `preferred_date`) `WHERE deleted_at IS NULL` — the owner inbox query

**FKs**
- `fk_visit_requests_property` (`property_id`) → `properties(id)` ON DELETE RESTRICT
- `fk_visit_requests_student` (`student_id`) → `users(id)` ON DELETE RESTRICT

**Checks:** none. Nothing prevents duplicate pending requests for the same
student+property.

### 3.10 `complaints`

| Column | Type | Null | Default |
| --- | --- | --- | --- |
| `id` | uuid | NOT NULL | `gen_random_uuid()` |
| `occupancy_id` | uuid | NOT NULL | — |
| `category` | `complaints_category_enum` | NOT NULL | — |
| `title` | varchar(255) | NOT NULL | — |
| `description` | text | NOT NULL | — |
| `photos` | jsonb | NULL | — (array of URLs) |
| `status` | `complaints_status_enum` | NOT NULL | `'open'` |
| `resolved_at` | timestamptz | NULL | — |
| `created_at` | timestamptz | NOT NULL | `now()` |
| `updated_at` | timestamptz | NOT NULL | `now()` |
| `deleted_at` | timestamptz | NULL | — |

**Indexes**
- `complaints_pkey` UNIQUE (`id`)
- `idx_complaints_occupancy_id` (`occupancy_id`)
- `idx_complaints_status` (`status`)
- `idx_complaints_occupancy_created_at` (`occupancy_id`, `created_at DESC`) `WHERE deleted_at IS NULL`

**FKs:** `fk_complaints_occupancy` (`occupancy_id`) → `occupancies(id)` ON DELETE RESTRICT.

**Checks**
- `chk_complaints_photos_is_array`: `photos IS NULL OR jsonb_typeof(photos) = 'array'`

### 3.11 `reviews`

| Column | Type | Null | Default |
| --- | --- | --- | --- |
| `id` | uuid | NOT NULL | `gen_random_uuid()` |
| `property_id` | uuid | NOT NULL | — |
| `student_id` | uuid | NOT NULL | — |
| `rating` | integer | NOT NULL | — |
| `comment` | text | NULL | — |
| `created_at` | timestamptz | NOT NULL | `now()` |
| `updated_at` | timestamptz | NOT NULL | `now()` |
| `deleted_at` | timestamptz | NULL | — |

**Indexes**
- `reviews_pkey` UNIQUE (`id`)
- `uq_reviews_property_student` UNIQUE (`property_id`, `student_id`) `WHERE deleted_at IS NULL` — one live review per student per property
- `idx_reviews_property_id` (`property_id`)
- `idx_reviews_student_id` (`student_id`)

**FKs**
- `fk_reviews_property` (`property_id`) → `properties(id)` ON DELETE RESTRICT
- `fk_reviews_student` (`student_id`) → `users(id)` ON DELETE RESTRICT

**Checks**
- `chk_reviews_rating_range`: `rating BETWEEN 1 AND 5`

### 3.12 Enum types — complete, in declared order

Postgres enum ordering matters for `ORDER BY` on an enum column. Values are
listed in `enumsortorder`.

| Enum type | Values (ordered) |
| --- | --- |
| `users_role_enum` | `student`, `owner`, `admin` |
| `users_gender_enum` | `male`, `female`, `other` |
| `properties_gender_type_enum` | `male`, `female`, `coliving` |
| `properties_status_enum` | `draft`, `published`, `unlisted` |
| `rooms_sharing_type_enum` | `single`, `double`, `triple`, `four_plus` |
| `beds_status_enum` | `available`, `occupied`, `maintenance` |
| `occupancies_status_enum` | `active`, `notice_period`, `ended` |
| `visit_requests_preferred_slot_enum` | `morning`, `afternoon`, `evening` |
| `visit_requests_status_enum` | `pending`, `accepted`, `declined`, `completed`, `cancelled` |
| `complaints_category_enum` | `electrical`, `plumbing`, `cleaning`, `food`, `wifi`, `other` |
| `complaints_status_enum` | `open`, `in_progress`, `resolved`, `closed` |

### 3.13 Database objects that are not tables

| Object | Definition |
| --- | --- |
| Extension `pgcrypto` | Created by migration 1. Provides `gen_random_uuid()`. Intentionally **not** dropped on revert. |
| Extension `uuid-ossp` | **Not created by any migration.** TypeORM's Postgres driver issues `CREATE EXTENSION IF NOT EXISTS "uuid-ossp"` automatically on connect because entities use `@PrimaryGeneratedColumn('uuid')`. A Java port will not do this; harmless either way since column defaults use `gen_random_uuid()`. |
| Function `set_updated_at()` | `plpgsql`, `BEFORE UPDATE` trigger body: `NEW.updated_at = now(); RETURN NEW;` |
| 11 triggers `trg_<table>_updated_at` | One per table, `BEFORE UPDATE ... FOR EACH ROW EXECUTE FUNCTION set_updated_at()` |
| Table `migrations` | TypeORM bookkeeping (`id`, `timestamp`, `name`). Configured via `migrationsTableName: 'migrations'`. |

### 3.14 Migrations, in application order

All 12 are applied to the live database. Verified `up` **and** `down` both run
cleanly: the full stack was reverted to zero and re-applied during this
session, leaving no orphaned tables, enum types, or functions.

| # | Timestamp | Class | Creates |
| --- | --- | --- | --- |
| 1 | 1784500000000 | `InitExtensions` | `pgcrypto`, `set_updated_at()` |
| 2 | 1784500001000 | `CreateUsers` | `users_role_enum`, `users_gender_enum`, `users` |
| 3 | 1784500002000 | `CreateOtpCodes` | `otp_codes` |
| 4 | 1784500003000 | `CreateRefreshTokens` | `refresh_tokens` |
| 5 | 1784500004000 | `CreateProperties` | `properties_gender_type_enum`, `properties_status_enum`, `properties` |
| 6 | 1784500005000 | `CreatePropertyPhotos` | `property_photos` |
| 7 | 1784500006000 | `CreateRooms` | `rooms_sharing_type_enum`, `rooms` |
| 8 | 1784500007000 | `CreateBeds` | `beds_status_enum`, `beds` |
| 9 | 1784500008000 | `CreateOccupancies` | `occupancies_status_enum`, `occupancies` |
| 10 | 1784500009000 | `CreateVisitRequests` | both visit-request enums, `visit_requests` |
| 11 | 1784500010000 | `CreateComplaints` | both complaint enums, `complaints` |
| 12 | 1784500011000 | `CreateReviews` | `reviews` |

Each `down()` drops, in order: the trigger, the table, then its enum types.

### 3.15 Money representation

All money is **`BIGINT` paise**. Six columns:
`properties.min_rent_paise`, `properties.max_rent_paise`,
`rooms.rent_per_bed_paise`, `rooms.deposit_paise`,
`occupancies.rent_paise`, `occupancies.deposit_paise`.

Verified: all six are `bigint`. No floats or `numeric` anywhere in money.

In TypeScript, `bigintTransformer` converts the driver's string to a JS
`number` (safe: ₹10 crore = 1e11 paise, far under `Number.MAX_SAFE_INTEGER`).
**A Java port should use `long`** and must not adopt the JS number workaround.

---

## 4. Business logic worth preserving

**Status: essentially none of this is implemented.** What exists is the
*schema-level scaffolding* that the logic will hang off, plus one constant.
This section records what the database already guarantees versus what still
has to be written — the DB-level guarantees are the parts genuinely worth
carrying into Java.

### 4.1 Auth / OTP flow — ❌ not implemented

No service, no controller, no SMS provider, no hashing library.

What the schema provides:
- `otp_codes.code_hash` — the column is named for hashing; **no hashing code
  exists** and no hashing library (`bcrypt`, `argon2`) is installed.
- `otp_codes.attempts` (default 0) and `otp_codes.expires_at` support the
  5-minute expiry / max-5-attempts rules from `CLAUDE.md` §5.
- `idx_otp_codes_phone_created_at` is purpose-built for both the
  3-per-phone-per-10-minute rate limit and the "newest live code" lookup.
- `otp_codes` has **no FK to `users`**, correctly allowing an OTP request for a
  phone that has no account yet.

Config knobs already defined (`config/configuration.ts:29-34`, defaults in
`env.validation.ts:27-30`): `OTP_TTL_SECONDS=300`, `OTP_MAX_ATTEMPTS=5`,
`OTP_REQUEST_LIMIT=3`, `OTP_REQUEST_WINDOW_SECONDS=600`.

### 4.2 Refresh token rotation — ❌ not implemented

No JWT library is installed (`@nestjs/jwt`, `@nestjs/passport`, `jsonwebtoken`
are all absent). No signing, verification, or rotation code exists.

What the schema provides:
- `refresh_tokens.token_hash` with a partial UNIQUE index — tokens are stored
  hashed, and lookup on refresh is by hash.
- `revoked_at` for revocation; `expires_at` for expiry.
- Rotation is implied by "rotated on use" in the entity comment, but no
  implementation defines whether rotation revokes-and-inserts or updates.

Config: `JWT_ACCESS_SECRET`, `JWT_ACCESS_TTL=15m`, `JWT_REFRESH_SECRET`,
`JWT_REFRESH_TTL=30d`. Joi requires both secrets to be ≥16 chars.

### 4.3 Bed auto-creation from `sharing_type` — ⚠️ constant only

The **only** business logic artefact in the codebase:

```ts
// modules/rooms/enums/room.enums.ts
export const BEDS_PER_SHARING_TYPE: Record<SharingType, number> = {
  single: 1, double: 2, triple: 3, four_plus: 4,
};
```

Nothing consumes it. There is no room-creation service, so no beds are ever
created. Documented intent: `four_plus` means **4 is a floor, not an exact
count** — the owner may add more beds afterwards.

Undefined and needing a decision: the bed **labelling** scheme. The entity
comment says `"A"`, `"B"`, but no code generates labels, and
`uq_beds_room_label` will reject duplicates within a room.

### 4.4 Search filtering and distance sorting — ❌ not implemented

No search service exists. The schema is nonetheless clearly shaped for it:

- `idx_properties_search` (`city`, `gender_type`, `min_rent_paise`) partial on
  `deleted_at IS NULL AND status='published'` — the intended hot path.
- `idx_properties_amenities` GIN — amenity filtering is meant to use JSONB
  containment (`amenities @> '{"wifi":true}'`).
- `idx_properties_lat_lng` (`latitude`, `longitude`) btree — a **bounding-box
  prefilter**, per the migration comment, before computing true distance.
- `idx_beds_available` partial on `status='available'` — supports the
  "≥1 available bed" join.

**Critical gap:** `CLAUDE.md` §2 specifies "PostGIS-style distance queries",
but **PostGIS is not installed**, and neither are `cube`/`earthdistance`. Only
`pgcrypto` is created. Distance must therefore be computed as raw Haversine
SQL over the btree-prefiltered bounding box — or the extension decision must be
made explicitly. **No distance code exists in any form.**

`properties.min_rent_paise` / `max_rent_paise` are documented as "denormalized
for search cards, recomputed on room writes" — **nothing recomputes them.**
There is no trigger and no service. They will stay `NULL` until something
maintains them, which would silently break `sort=rent_asc` and rent-range
filtering.

### 4.5 Ownership checks — ❌ not implemented

`CLAUDE.md` §3.13 requires ownership checks in **services, not controllers**.
No services exist, so no ownership check exists anywhere.

The FK chain that ownership must traverse is in place and is the thing to
preserve:

```
users(id) ──< properties(owner_id)
                  ├──< rooms(property_id) ──< beds(room_id) ──< occupancies(bed_id)
                  ├──< property_photos(property_id)
                  ├──< visit_requests(property_id)
                  └──< reviews(property_id)
```

So `PATCH /owner/beds/:id` must verify `bed → room → property.owner_id ==
currentUser.id`, a three-hop join. Same for `DELETE /owner/photos/:photoId`
(two hops). These are the deepest checks in the system.

### 4.6 Soft-delete filtering — ✅ at DB level, ⚠️ at app level

**Guaranteed by the database** (portable, keep it):
- All 11 tables have `deleted_at`.
- All 8 partial unique indexes are scoped `WHERE deleted_at IS NULL`, so
  soft-deleted rows never block re-creating a natural key.
- Every FK is `ON DELETE RESTRICT`, so the database physically refuses hard
  deletes.

**Provided by TypeORM** (does *not* port to Java automatically):
- `BaseEntity.deletedAt` is a `@DeleteDateColumn`, which makes repository
  `find`/`findOne` exclude soft-deleted rows **automatically**, and makes
  `softDelete()`/`softRemove()` the deletion path.

A Java/JPA port gets **no such automatic filtering**. Every query must add
`WHERE deleted_at IS NULL` explicitly, or use Hibernate `@Where` /
`@SQLRestriction`. This is the single highest-risk item in the migration: the
current safety is implicit in the ORM, and silently disappears.

---

## 5. External integrations

**None are implemented.** No integration client code exists anywhere in the
repository. What exists is configuration scaffolding for two of them.

### 5.1 SMS / OTP delivery — ❌ absent, and not even configured

| Aspect | State |
| --- | --- |
| Provider chosen | **None.** No Twilio, MSG91, Gupshup, AWS SNS, or any other. |
| SDK installed | None. |
| Config keys | **None.** `.env.example` has no SMS variables at all — only OTP *policy* knobs (TTL, attempts, rate limit). |
| Code | None. |

This is a hard blocker for the auth flow: OTP codes can be generated and
hashed, but there is currently no way to deliver one to a phone. A provider
must be chosen, and env keys for it added.

### 5.2 S3-compatible object storage — ⚠️ configured, not implemented

| Aspect | State |
| --- | --- |
| SDK installed | **No.** `@aws-sdk/client-s3` and `multer` are absent from `package.json`. |
| Code | None. No upload service, no `FileInterceptor`. |
| Config location | `config/configuration.ts:36-43` → `s3.*`; validated (all optional, empty allowed) in `env.validation.ts:32-37`. |

Config keys, all currently **empty** in `.env`:

| Key | Value in `.env` |
| --- | --- |
| `S3_ENDPOINT` | *(empty)* |
| `S3_REGION` | `ap-south-1` |
| `S3_BUCKET` | `atrio-pg-media` |
| `S3_ACCESS_KEY_ID` | *(empty)* |
| `S3_SECRET_ACCESS_KEY` | *(empty)* |
| `S3_PUBLIC_BASE_URL` | *(empty)* |

Since the database is already Supabase, Supabase Storage is S3-compatible and
is the obvious candidate — its credentials come from
Dashboard → Project Settings → Storage → S3 connection. Not yet decided.

Schema readiness: `property_photos.url` is `varchar(1024)` and
`complaints.photos` is a JSONB array (with a check constraint enforcing
array-ness). Both store URLs, so storage choice is not schema-coupled.

### 5.3 PostgreSQL / Supabase — ✅ live and working

| Aspect | Value |
| --- | --- |
| Provider | Supabase, project ref `ljcwcjwiyeiyzgkmmbhn` |
| Host | `db.ljcwcjwiyeiyzgkmmbhn.supabase.co` (direct) |
| Note | Host resolves **AAAA-only (IPv6)**. Works from the current machine. Fallback if a network lacks IPv6: session pooler `aws-0-<region>.pooler.supabase.com` with username `postgres.<ref>`. |
| Port / DB / user | `5432` / `postgres` / `postgres` |
| SSL | `DB_SSL=true` → `{ rejectUnauthorized: false }` (`typeorm.config.ts:20-23`) |
| Config location | `backend/.env` (git-ignored), template in `.env.example` |

`docker-compose.yml` defines a local Postgres 16 alternative. It is **not in
use**.

### 5.4 Supabase client keys — present but unused

`backend/.env` also carries `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`.
These are the **JS/REST (PostgREST) client keys** and are *not* used by the
backend — TypeORM speaks the raw Postgres wire protocol. They are retained for
possible future client-side use. They are not in `.env.example` and not read by
`configuration.ts`.

### 5.5 Integrations that do not exist at all

No payment gateway (Razorpay is Phase 3), no push notifications, no email, no
maps/geocoding service, no analytics, no error tracking, no rate-limit store
(`@nestjs/throttler` is not installed despite `TOO_MANY_REQUESTS` being mapped
in the error filter).

---

## 6. Deviations from `CLAUDE.md`

Ordered by severity.

### 6.1 Blocking / structural

| # | Rule | Deviation |
| --- | --- | --- |
| 1 | §6 — the entire `/api/v1` surface | **~25 endpoints specified, 0 implemented.** No controllers, services, DTOs, or guards exist. |
| 2 | §2, §7 — Flutter app | **Does not exist.** No `app/` directory, no Dart, no Riverpod, no go_router. Phase 1 lists 12 screens; none exist. |
| 3 | §3.13 — auth guards, role guards, ownership checks on every non-public endpoint | Not implemented. No `JwtAuthGuard`, no `RolesGuard`, no ownership logic. Moot while there are no endpoints, but it is the largest single body of unwritten security work. |
| 4 | §3.16 — "No secrets in code… (+ committed `.env.example`)" | `.env.example` exists but **the project is not a git repository**. Nothing is committed; `.gitignore` protects nothing. A live Supabase password sits in `backend/.env` outside version control of any kind. |
| 5 | §3.4 — "Never edit an already-committed migration" | Unenforceable today for the same reason: no commits exist. The rule assumes git. |

### 6.2 Design gaps that will force a decision

| # | Rule | Deviation |
| --- | --- | --- |
| 6 | §2 — "PostGIS-style distance queries" | **No PostGIS**, no `cube`/`earthdistance`. Only `pgcrypto` is installed. Distance sorting has no implementation path chosen; Haversine-in-SQL over the existing btree bounding box is the implied fallback but was never decided. |
| 7 | §5 — `properties.min_rent_paise` / `max_rent_paise` "updated from rooms" | Columns exist and are nullable, but **nothing updates them**. No trigger, no service. They will remain `NULL`, breaking `sort=rent_asc`/`rent_desc` and rent-range filtering until something maintains them. |
| 8 | §6 — `GET /meta/amenities` returns "canonical amenity list (server-driven)" | **No canonical list exists** anywhere — not a table, not a constant, not a seed. `PropertyAmenities` is merely `Record<string, boolean>`. The endpoint has no data source to serve. |
| 9 | §6 — `PATCH /auth/profile`, "role (settable once)" | `users.role` is `NOT NULL DEFAULT 'student'`. Every user is *already* a student the instant they are created, so there is **no way to distinguish "role not yet chosen" from "deliberately chose student"**. Enforcing "settable once" needs either a nullable role, a `role_chosen_at` column, or a `profile_completed` flag. None exists. |
| 10 | §5 — `rooms.deposit_paise` "default = rent, editable" | Column is `NOT NULL` with **no database default**. The "default = rent" behaviour must live in application code; a bare insert without it fails. |

### 6.3 Minor / informational

| # | Item | Note |
| --- | --- | --- |
| 11 | §3.11 — pagination on every list endpoint | `PaginationQueryDto` + `paginated()` helper are correctly built to spec, but **unused** (no list endpoints exist). |
| 12 | §5 — `users.email` "unique when present" | Implemented **more strictly** than specified: unique on `lower(email)`, i.e. case-insensitive. A Java port must replicate the `lower()` or behaviour will differ. |
| 13 | §3.7 | The rule's own text visibly argues with itself (paise vs rupees) before landing on paise. The implementation correctly uses `BIGINT` paise throughout. Worth cleaning up the rule text so it can't be misread. |
| 14 | TypeORM `@Index` decorators on entities | Duplicate the indexes already created in migrations. Inert while `synchronize:false`, but a drift hazard if anyone ever runs `migration:generate`. Note that the entity decorators are an **incomplete** mirror — the partial/GIN indexes exist only in the migrations. |
| 15 | `uuid-ossp` extension | Auto-created by the TypeORM driver, not by any migration, so it is absent from the migration history but present in the database. Harmless. |
| 16 | `docker-compose.yml` | Dead weight — the project runs on Supabase. Retained in the README as an option. |
| 17 | §9 — Definition of Done | Migrations `up`/`down` ✅ verified; lint ✅ passes. But **no test framework is installed** (no jest, no `test` script), so nothing beyond lint and migration reversibility can be gated. |
| 18 | `occupancies` open-occupancy uniqueness | Keyed on `end_date IS NULL`, **not** on `status`. A row with `status='ended'` but `end_date` still `NULL` would occupy the unique slot. Application code must keep the two in sync; the DB does not. |
| 19 | `visit_requests` | Nothing prevents a student raising unlimited duplicate `pending` requests for the same property. No constraint, no rule in `CLAUDE.md` either. |

---

## 7. Ambiguities to resolve before the Java build

These have no answer in the codebase or in `CLAUDE.md`, and each changes the
implementation:

1. **Role assignment** (§6.2 #9) — how is "role settable once" enforced given
   the `'student'` default? Needs a schema decision.
2. **Distance search** (§6.2 #6) — PostGIS, `earthdistance`, or hand-written
   Haversine? Affects migrations and query shape.
3. **`min_rent`/`max_rent` maintenance** (§6.2 #7) — database trigger or
   service-layer recompute? Trigger is more robust and survives raw SQL;
   service is easier to test.
4. **Amenity canonical list** (§6.2 #8) — hardcoded constant, or a new table?
   A table means a migration; `CLAUDE.md` §3.6 says new amenities must need no
   migration, which argues for a table or a config-driven list.
5. **SMS provider** (§5.1) — completely undecided, and blocks all of auth.
6. **Object storage** (§5.2) — Supabase Storage vs AWS S3 vs other.
7. **Bed labelling** (§4.3) — the scheme (`A`/`B`… vs `1`/`2`…) is undefined,
   and `uq_beds_room_label` enforces uniqueness per room.
8. **Domain error codes** (§2.2) — the custom-`code` override mechanism exists,
   but not one domain code has been defined. The full catalogue
   (`OTP_EXPIRED`, `OTP_INVALID`, `PHONE_RATE_LIMITED`, `ROLE_ALREADY_SET`, …)
   must be designed, because the mobile app will branch on these strings.
9. **Soft-delete filtering in Java** (§4.6) — currently automatic via TypeORM's
   `@DeleteDateColumn`. The port must choose an explicit strategy
   (Hibernate `@SQLRestriction`, a base repository, or discipline) or
   soft-deleted rows will silently start appearing in results.
10. **Refresh rotation semantics** (§4.2) — on refresh, is the old row revoked
    and a new one inserted (auditable), or updated in place? `CLAUDE.md` says
    only "rotated on use". Reuse-detection behaviour is likewise undefined.
