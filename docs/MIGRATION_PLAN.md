# ATRIO-PG — NestJS → Java Spring Boot Migration Plan

**Status:** DRAFT — awaiting approval. No code written.
**Date:** 2026-07-24
**Companion documents:** `CLAUDE.md` (project constitution),
`docs/CURRENT_STATE.md` (audit of what exists today).

---

## 0. Premise correction — read before anything else

The brief describes this as a port that must preserve a running system. Three
of its constraints do not apply to the codebase as it actually stands. This
does not block the work — it makes it **substantially easier** — but the plan
below is built on the corrected premise, so the difference matters.

| Brief says | Reality (per `docs/CURRENT_STATE.md`) | Effect on plan |
| --- | --- | --- |
| "same API contract" | **There is no API.** 0 of ~25 endpoints exist. No controllers, services, DTOs, or guards. | Nothing to preserve. Java is the *first* implementation. The contract to hit is `CLAUDE.md` §6 + the envelope/error machinery in §2.2 of the audit. |
| "the Flutter app must not need a single change" | **There is no Flutter app.** No `app/`, no `pubspec.yaml`, no `.dart` file anywhere — re-verified just now. | No client to break. We get to *define* the wire format rather than reverse-engineer it. This is the single biggest risk reduction available, and we should spend it deliberately (see §5, §6). |
| "keep the same secret and claims so existing tokens stay valid" | **No JWT code exists** (`@nestjs/jwt` not installed) and **no token has ever been issued.** There is no claim structure to preserve. | Reinterpreted as: keep the same **env var names and secret values** so configuration and deployment don't change, and **define** the claim set now (§6.2). Token compatibility is vacuous — there is nothing in the wild. |

**What genuinely must be preserved** is much narrower, and the plan treats
these as hard constraints:

1. **The PostgreSQL schema** — 11 tables, live on Supabase, verified. No table
   may be recreated, altered, or dropped.
2. **The response envelope and error-code table** — these are built and
   working (`ResponseInterceptor`, `AllExceptionsFilter`) and are the one real
   piece of API contract in the repository.
3. **`CLAUDE.md` §3 architecture rules** — soft deletes, UUID PKs, paise as
   BIGINT, versioned migrations, `/api/v1`, pagination, DTO validation,
   guards + ownership checks.

**Ask before we start:** if a Flutter app exists in another repository or on
another machine, point me at it — its actual request/response expectations
would override several decisions below (notably §5 and the timestamp
serialization risk in §8).

---

## 1. Concept mapping

| NestJS / TypeORM | Spring Boot equivalent | Notes |
| --- | --- | --- |
| `@Module` (one per domain) | Java package under `com.atrio.pg.<domain>` | Spring has no module object; the package plus `@Configuration` is the boundary. Component scan replaces explicit imports/exports. |
| `@Controller` | `@RestController` | Routes under `/api/v1` via `server.servlet.context-path` or a global `@RequestMapping` prefix — see §2.1. |
| `@Injectable` service | `@Service` | Constructor injection via Lombok `@RequiredArgsConstructor`. |
| `Repository<T>` (TypeORM) | `interface XRepository extends JpaRepository<X, UUID>` | Spring Data derives queries from method names; complex search goes to `@Query` or a `JpaSpecificationExecutor`. |
| `@UseGuards(JwtAuthGuard)` | `SecurityFilterChain` — a `OncePerRequestFilter` that validates the JWT and populates `SecurityContext` | Applied globally by URL pattern, not per-handler. |
| `@UseGuards(RolesGuard)` + `@Roles('owner')` | `@PreAuthorize("hasRole('OWNER')")` on the controller method | Requires `@EnableMethodSecurity`. Authorities stored as `ROLE_OWNER`. |
| Ownership check inside a service | Same — a service-layer check throwing `ForbiddenException` | `CLAUDE.md` §3.13 explicitly forbids putting these in controllers. Preserve that. `@PreAuthorize` handles *role*; it must not handle *ownership*. |
| DTO class + `class-validator` decorators | Java `record` + Bean Validation (`@NotBlank`, `@Size`, `@Min`, `@Pattern`, `@Valid`) | Records give immutability for free. Validation triggered by `@Valid` on the handler parameter. |
| Global `ValidationPipe` (`whitelist`, `forbidNonWhitelisted`) | Jackson `FAIL_ON_UNKNOWN_PROPERTIES=true` + `@Validated` | **Not equivalent for query params** — see risk §8.7. |
| TypeORM `@Entity` | JPA `@Entity` (Hibernate 6) | Field-by-field mapping in §4. |
| `BaseEntity` (id/created/updated/deleted) | `@MappedSuperclass BaseEntity` + `AuditingEntityListener` | §4.2. |
| `@DeleteDateColumn` (auto soft-delete filtering) | `@SQLRestriction("deleted_at IS NULL")` + `@SQLDelete` | **Not fully equivalent** — the highest-risk item in this migration. See §8.1. |
| `ResponseInterceptor` (success envelope) | `ResponseBodyAdvice<Object>` in a `@RestControllerAdvice` | §5.1. |
| `AllExceptionsFilter` (error envelope) | `@RestControllerAdvice` + `@ExceptionHandler`, **plus** `AuthenticationEntryPoint` and `AccessDeniedHandler` | Security exceptions never reach the advice — see §5.3. |
| `bigintTransformer` (pg bigint → JS number) | Nothing needed — `Long` | Java has real 64-bit integers. Delete the concept. |
| `decimalTransformer` (pg numeric → JS float) | `BigDecimal` or `Double` | Affects JSON output format — see §8.4. |
| TypeORM migrations | Flyway | §3. |
| `class-transformer` entity→response shaping | MapStruct mappers | Compile-time, no reflection. |
| `.env` + `@nestjs/config` + Joi | `application.yml` + `@ConfigurationProperties` + Bean Validation on the properties class | Same env var names retained (§6.4). |
| Jest (absent) | JUnit 5 + Testcontainers + MockMvc/RestAssured | Currently zero tests exist; this is net-new. |

---

## 2. Package structure

```
backend-java/
  pom.xml
  src/main/java/com/atrio/pg/
    AtrioPgApplication.java

    common/
      envelope/        ApiResponse, ApiError, SuccessBodyAdvice
      exception/       ApiException, ErrorCode, GlobalExceptionHandler,
                       RestAuthenticationEntryPoint, RestAccessDeniedHandler
      pagination/      PageQuery (record), PagedResponse<T>
      persistence/     BaseEntity, AuditingConfig
      jackson/         JacksonConfig (timestamp + unknown-property policy)

    config/            SecurityConfig, WebConfig, OpenApiConfig,
                       AppProperties (@ConfigurationProperties)

    auth/
      web/             AuthController
      dto/             OtpRequestRequest, OtpVerifyRequest, RefreshRequest,
                       UpdateProfileRequest, AuthTokensResponse
      service/         AuthService, OtpService, TokenService, RefreshTokenService
      domain/          OtpCode, RefreshToken (entities)
      repository/      OtpCodeRepository, RefreshTokenRepository
      security/        JwtAuthenticationFilter, JwtProperties, AppUserPrincipal

    users/
      web/ dto/ service/ domain/ repository/ mapper/
    properties/        (Property, PropertyPhoto)
      web/ dto/ service/ domain/ repository/ mapper/
    rooms/
    beds/
    occupancies/       domain/ repository/ only — Phase 2, no endpoints
    complaints/        domain/ repository/ only — Phase 2, no endpoints
    reviews/           domain/ repository/ only — Phase 2, no endpoints
    visitrequests/
    meta/              MetaController (GET /meta/amenities), AmenityCatalog
    search/            PropertySearchController, PropertySearchService,
                       PropertySearchSpecification, SearchQuery (record)

  src/main/resources/
    application.yml
    application-local.yml
    db/migration/
      V1__baseline_existing_schema.sql     <- never runs on Supabase (§3)
      V2__*.sql                            <- all future changes

  src/test/java/com/atrio/pg/
    support/           AbstractIntegrationTest (Testcontainers), fixtures
    <domain>/          slice + integration tests
  src/test/resources/
    application-test.yml
```

**Notes**

- `search/` is its own package rather than living under `properties/` because
  its query is cross-domain (properties + rooms + beds) and will be the most
  complex code in the system.
- `occupancies`, `complaints`, `reviews` ship as **entities and repositories
  only**, exactly matching today's state — tables exist, no endpoints until
  Phase 2.
- Domain packages use `web/ dto/ service/ domain/ repository/ mapper/`
  consistently so the Controller → Service → Repository rule of `CLAUDE.md`
  §3.14 is visible in the directory layout.

### 2.1 The `/api/v1` prefix

Use `spring.mvc.servlet.path` **no** — use a `WebMvcConfigurer` with
`configurePathMatch(c -> c.addPathPrefix("/api/v1", HandlerTypePredicate.forBasePackage("com.atrio.pg")))`.

Rationale: `server.servlet.context-path` would also move actuator/health
endpoints and is awkward to exclude from; the path-prefix approach applies
only to our controllers and keeps `/actuator/health` at the root for
platform health checks.

---

## 3. Flyway strategy — baseline on the existing schema

**Confirmed approach: baseline at version 1, with a `V1` script that exists
for fresh databases only.**

### 3.1 The problem

The Supabase database already contains all 11 tables, 11 enum types, 8 partial
unique indexes, a GIN index, 11 triggers, and the `set_updated_at()` function
— created by TypeORM migrations. Flyway must:

- **never** re-run that DDL against Supabase, and
- **still** be able to build the identical schema from nothing, because
  Testcontainers starts every integration test from an empty database.

Those two requirements are what the baseline mechanism exists for.

### 3.2 The exact approach

**Step 1 — author `V1__baseline_existing_schema.sql`.**
Generate it with `pg_dump --schema-only --no-owner --no-privileges` against
the live Supabase database, then hand-edit to remove Supabase-internal noise
(other schemas, roles, `search_path` chatter) and the TypeORM `migrations`
table. It must reproduce, exactly: `pgcrypto`, `set_updated_at()`, all 11 enum
types **in declared label order**, all 11 tables with defaults and check
constraints, all indexes including the partial and GIN ones, and all 11
triggers.

**Step 2 — baseline the existing database once.**

```
flyway.baselineOnMigrate = true
flyway.baselineVersion   = 1
flyway.baselineDescription = "Existing schema created by TypeORM migrations"
```

Behaviour, which is precisely what we want:

| Target database | `flyway_schema_history` | What Flyway does |
| --- | --- | --- |
| **Supabase** (non-empty, no history table) | absent | `baselineOnMigrate` fires: inserts a `BASELINE` row at version 1 and **skips `V1`**. Only `V2+` ever run. **No table is recreated.** |
| **Testcontainers** (empty schema) | absent | Schema is empty, so baseline does not apply: Flyway runs `V1` normally, building the full schema, then `V2+`. |

The same migration folder therefore serves both, with no profile-specific
scripts and no manual steps in CI.

**Step 3 — verify the baseline is faithful.**
This is the gate, not an afterthought:

1. `pg_dump --schema-only` the Supabase `public` schema → `supabase.sql`.
2. Start a clean Postgres via Testcontainers, run Flyway `V1` → `fresh.sql`.
3. Normalize both (strip comments, sort statements) and `diff`.
4. **The diff must be empty.** Any difference means `V1` is wrong and would
   produce a test environment that silently disagrees with production.

Automate this as a test (`BaselineFidelityTest`) so it can never silently rot.

**Step 4 — `ddl-auto`.**
`spring.jpa.hibernate.ddl-auto: validate` in all environments. Never `update`,
never `create`. `validate` confirms entities match the tables at boot and
fails fast on drift. It does **not** check indexes or triggers — the diff test
in step 3 covers those.

### 3.3 Handling the leftover TypeORM `migrations` table

Leave it in place through cutover as a historical record. Once the Java
backend is verified in production, drop it in a normal Flyway migration
(`V2__drop_typeorm_migrations_table.sql`). Do not include it in the `V1`
baseline — a fresh Testcontainers database has no reason to carry it.

### 3.4 Rules going forward

- `V1` is frozen forever once baselined. Never edit it (`CLAUDE.md` §3.4).
- Every schema change is a new `V<n>__description.sql`.
- Flyway `validateOnMigrate` stays on (default) so a checksum change on an
  applied migration fails the boot.
- `cleanDisabled: true` in every environment. Flyway `clean` against Supabase
  would be catastrophic.

---

## 4. JPA entity definitions

All 11 entities map to existing tables. Column names, types, nullability, and
defaults are taken from the verified live schema in `docs/CURRENT_STATE.md` §3.

### 4.1 Type mapping rules applied throughout

| Postgres | Java | Annotation |
| --- | --- | --- |
| `uuid` PK | `UUID` | `@Id @GeneratedValue @UuidGenerator` (Hibernate generates client-side; the DB `gen_random_uuid()` default remains as a safety net for raw SQL) |
| `uuid` FK | `UUID` field **and** a lazy `@ManyToOne` | Keep both: the raw id for cheap reads/writes (`@Column(name="owner_id", insertable=false, updatable=false)` on one side), the association for joins |
| `varchar(n)` | `String` | `@Column(length = n)` |
| `text` | `String` | `@Column(columnDefinition = "text")` |
| `boolean` | `boolean` | primitive — all boolean columns are `NOT NULL` with defaults |
| `integer` | `Integer` / `int` | `Integer` where nullable (`rooms.floor`), primitive otherwise |
| `bigint` (money, paise) | **`Long`** | `Long` (not `long`) for `properties.min/max_rent_paise`, which are nullable; primitive `long` elsewhere |
| `numeric(9,6)` | `BigDecimal` | `@Column(precision = 9, scale = 6)` — see §8.4 for the JSON caveat |
| `date` | `LocalDate` | — |
| `timestamptz` | `Instant` | see §8.5 for the JSON caveat |
| `jsonb` | `Map<String,Boolean>` / `Map<String,Object>` / `List<String>` | `@JdbcTypeCode(SqlTypes.JSON)` — native in Hibernate 6, no `hypersistence-utils` needed |
| Postgres named enum | Java `enum` | `@Enumerated(EnumType.STRING) @JdbcTypeCode(SqlTypes.NAMED_ENUM)` — **see §4.5, this has a naming trap** |

### 4.2 `BaseEntity` — the shared superclass

```
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class BaseEntity {
    @Id @GeneratedValue @UuidGenerator
    private UUID id;

    @CreatedDate      @Column(name="created_at", nullable=false, updatable=false)
    private Instant createdAt;

    @LastModifiedDate @Column(name="updated_at", nullable=false)
    private Instant updatedAt;

    @Column(name="deleted_at")
    private Instant deletedAt;
}
```

Requires `@EnableJpaAuditing` on a `@Configuration` class.

**Interaction with the database triggers:** every table has a
`BEFORE UPDATE` trigger setting `updated_at = now()`. The trigger fires
*after* Hibernate's `@LastModifiedDate` has written its value, so **the
trigger always wins**. That is correct and desirable (it also covers raw SQL),
but it means the in-memory entity's `updatedAt` is stale immediately after a
flush. Any response that returns `updatedAt` must re-read the row, or the API
will report a timestamp a few milliseconds off from what is stored. Handle by
annotating the entities `@DynamicUpdate` and refreshing where it matters.

### 4.3 Soft deletes

On every entity:

```
@SQLRestriction("deleted_at IS NULL")
@SQLDelete(sql = "UPDATE <table> SET deleted_at = now() WHERE id = ?")
```

`@SQLRestriction` (Hibernate 6.4+, the replacement for the deprecated
`@Where`) appends the predicate to entity and collection loads, reproducing
what TypeORM's `@DeleteDateColumn` did automatically. `@SQLDelete` converts
`repository.delete(x)` into a soft delete so no code path can hard-delete.

**This is not a complete equivalence.** See §8.1 — it is the top risk.

### 4.4 Entity-by-entity field map

Abbreviated to the fields beyond `BaseEntity`. Every entity carries
`@SQLRestriction` + `@SQLDelete` and extends `BaseEntity`.

**`User` → `users`**

| Field | Column | Java type | Constraints |
| --- | --- | --- | --- |
| `phone` | `phone` | `String` | `@Column(length=15, nullable=false)`; unique via partial index |
| `name` | `name` | `String` | length 255, nullable |
| `email` | `email` | `String` | length 255, nullable; **must be lowercased in code** (§8.8) |
| `role` | `role` | `UserRole` | named enum, default `student` |
| `gender` | `gender` | `Gender` | named enum, nullable |
| `avatarUrl` | `avatar_url` | `String` | length 512, nullable |
| `isActive` | `is_active` | `boolean` | default true |
| `lastLoginAt` | `last_login_at` | `Instant` | nullable |

**`OtpCode` → `otp_codes`** — `phone` (15), `codeHash` (255), `expiresAt`,
`attempts` (int, default 0), `consumedAt` (nullable). No association to
`User` (deliberate: an OTP precedes the account).

**`RefreshToken` → `refresh_tokens`** — `userId` (UUID) + lazy
`@ManyToOne User`, `tokenHash` (255, unique partial), `expiresAt`,
`revokedAt` (nullable).

**`Property` → `properties`** — `ownerId` + `@ManyToOne User`, `name` (255),
`description` (text, nullable), `genderType` (named enum), `addressLine`
(512), `locality` (255), `city` (255), `state` (255), `pincode` (10),
`latitude`/`longitude` (`BigDecimal`, 9/6), `amenities`
(`Map<String,Boolean>`, JSONB, `NOT NULL` default `{}`), `rules`
(`Map<String,Object>`, JSONB, nullable), `foodIncluded` (boolean),
`noticePeriodDays` (int, default 30), `status` (named enum, default `draft`),
`minRentPaise`/`maxRentPaise` (**`Long`, nullable**).

**`PropertyPhoto` → `property_photos`** — `propertyId` + `@ManyToOne`,
`url` (1024), `sortOrder` (int, default 0), `caption` (255, nullable).

**`Room` → `rooms`** — `propertyId` + `@ManyToOne`, `roomNumber` (50),
`floor` (`Integer`, nullable), `sharingType` (named enum),
`rentPerBedPaise` (`long`), `depositPaise` (`long`),
`hasAttachedBathroom`, `hasAc` (booleans).

**`Bed` → `beds`** — `roomId` + `@ManyToOne`, `label` (20),
`status` (named enum, default `available`).

**`Occupancy` → `occupancies`** — `bedId` + `@ManyToOne`, `studentId` +
`@ManyToOne`, `startDate`/`endDate` (`LocalDate`, end nullable),
`rentPaise`/`depositPaise` (`long`), `status` (named enum, default `active`).

**`VisitRequest` → `visit_requests`** — `propertyId` + `@ManyToOne`,
`studentId` + `@ManyToOne`, `preferredDate` (`LocalDate`), `preferredSlot`
(named enum), `message` (text, nullable), `status` (named enum, default
`pending`), `respondedAt` (nullable).

**`Complaint` → `complaints`** — `occupancyId` + `@ManyToOne`, `category`
(named enum), `title` (255), `description` (text, `NOT NULL`), `photos`
(`List<String>`, JSONB, nullable — DB check enforces array), `status`
(named enum, default `open`), `resolvedAt` (nullable).

**`Review` → `reviews`** — `propertyId` + `@ManyToOne`, `studentId` +
`@ManyToOne`, `rating` (int, DB check 1–5), `comment` (text, nullable).

### 4.5 The enum naming trap — needs a decision

Postgres labels are **lowercase** (`student`, `four_plus`, `in_progress`).
`SqlTypes.NAMED_ENUM` binds the Java constant's `name()` directly to the
Postgres enum type, so `UserRole.STUDENT` would send `'STUDENT'` and the
insert would fail — the label does not exist.

Three options:

| Option | Mechanism | Trade-off |
| --- | --- | --- |
| **A (recommended)** | Name the Java constants exactly as the DB labels: `enum UserRole { student, owner, admin }` | Violates Java naming convention. But it is zero-magic, works with `NAMED_ENUM` directly, and **serializes to the correct lowercase JSON automatically** — which the API needs anyway. |
| B | Keep `STUDENT` and add `?stringtype=unspecified` to the JDBC URL so Postgres infers the cast from `text` | Conventional Java, but the JDBC flag is global and changes binding behaviour for *every* string parameter in the app. Action at a distance. |
| C | Keep `STUDENT`, add an `AttributeConverter` per enum plus `@JdbcTypeCode` juggling | Conventional and local, but 11 converters of boilerplate and easy to get subtly wrong. |

I recommend **A**, with `@JsonValue`/`@JsonCreator` not even needed. Flagging
it because it is visually unusual and a reviewer will question it.

---

## 5. Response envelope via `@RestControllerAdvice`

The envelope is one of only two things in the current codebase that is real
API contract. It must be reproduced exactly (`docs/CURRENT_STATE.md` §2.2).

### 5.1 Success — `{ "success": true, "data": ... }`

A `ResponseBodyAdvice<Object>` inside a `@RestControllerAdvice` wraps every
controller return value:

```
record ApiResponse<T>(boolean success, T data) { }
```

Rules it must implement:
- Wrap everything from `com.atrio.pg` controllers.
- **Do not double-wrap** if the body is already an `ApiResponse` or `ApiError`.
- **Skip** `/actuator/**` and any OpenAPI/springdoc paths.
- Lists return the paginated object as `data`, producing
  `{"success":true,"data":{"items":[...],"page":1,"limit":20,"total":0}}`
  — identical to the Nest shape.

**Known trap:** a controller returning a bare `String` is serialized by
`StringHttpMessageConverter`, and returning an `ApiResponse` from the advice
in that path throws `ClassCastException`. Mitigation: forbid raw `String`
returns by convention, and defensively special-case `String` in the advice.
Listed in §8.6.

### 5.2 Errors — `{ "success": false, "error": { code, message, details? } }`

A `@RestControllerAdvice` extending `ResponseEntityExceptionHandler`,
reproducing the exact code table:

| Exception | Status | `code` |
| --- | --- | --- |
| `MethodArgumentNotValidException`, `ConstraintViolationException` | 400 | `VALIDATION_ERROR` + `details[]` |
| `HttpMessageNotReadableException` (incl. unknown property) | 400 | `BAD_REQUEST` |
| `ApiException` (our base, carries a code) | as thrown | **custom** — reproduces Nest's `payload.code` override |
| `AuthenticationException` | 401 | `UNAUTHORIZED` |
| `AccessDeniedException` | 403 | `FORBIDDEN` |
| `EntityNotFoundException`, `NoResourceFoundException` | 404 | `NOT_FOUND` |
| `DataIntegrityViolationException` | 409 | `CONFLICT` |
| — | 422 | `UNPROCESSABLE_ENTITY` |
| rate limiter (when added) | 429 | `TOO_MANY_REQUESTS` |
| any other `ErrorResponseException` | as thrown | `HTTP_ERROR` |
| everything else | 500 | `INTERNAL_ERROR`, message `"Something went wrong. Please try again."`, logged with stack |

`ErrorCode` becomes a Java enum so codes cannot be typo'd, and every domain
error is thrown as `new ApiException(ErrorCode.OTP_EXPIRED, "…")`.

### 5.3 The Spring Security gap

Authentication and authorization failures are thrown **inside the filter
chain, before `DispatcherServlet`**, so `@RestControllerAdvice` never sees
them. Left alone, Spring emits its own default JSON and the envelope is
broken for exactly the two statuses a mobile client cares most about.

Fix: register a custom `AuthenticationEntryPoint` (401) and
`AccessDeniedHandler` (403) that serialize the *same* `ApiError` envelope via
the shared `ObjectMapper`. This is easy to forget and produces an
inconsistency that only shows up under real auth failures — it gets an
explicit test.

### 5.4 Domain error codes must be designed

`docs/CURRENT_STATE.md` §2.2 notes the override mechanism exists but **not
one domain code is defined**. Since there is no client yet, we define the
catalogue now and it becomes contract: e.g. `OTP_INVALID`, `OTP_EXPIRED`,
`OTP_MAX_ATTEMPTS`, `PHONE_RATE_LIMITED`, `REFRESH_TOKEN_INVALID`,
`REFRESH_TOKEN_REUSED`, `ROLE_ALREADY_SET`, `PROPERTY_NOT_OWNED`,
`ROOM_NUMBER_TAKEN`, `BED_OCCUPIED`, `VISIT_ALREADY_CANCELLED`. Final list to
be agreed as part of §7 step 1.

---

## 6. Auth port

Nothing to port — there is no auth code. This is a greenfield build against an
existing schema, which the plan states plainly rather than pretending
otherwise.

### 6.1 OTP

- **Generation:** 6-digit numeric via `SecureRandom`.
- **Hashing:** BCrypt through Spring Security's `PasswordEncoder`. Lookup is
  by `phone` (index `idx_otp_codes_phone_created_at`), never by hash, so a
  salted non-deterministic hash is fine. BCrypt output is 60 chars; the column
  is `varchar(255)`. ✓
- **Expiry:** `expires_at = now() + OTP_TTL_SECONDS` (300).
- **Attempts:** increment `attempts` per failed verify; reject at
  `OTP_MAX_ATTEMPTS` (5). No DB constraint enforces this — service-layer only.
- **Consumption:** set `consumed_at` on success; a consumed code never
  verifies again.
- **Rate limit:** count rows for the phone within
  `OTP_REQUEST_WINDOW_SECONDS` (600); reject above `OTP_REQUEST_LIMIT` (3)
  with 429 / `PHONE_RATE_LIMITED`. Served by the existing partial index.
- **Delivery:** ⚠️ **no SMS provider is chosen or configured** — a hard
  blocker (§8.10). Until one exists, a `NoopSmsSender` that logs the code in
  non-production profiles keeps development unblocked. It must be impossible
  to enable in production.

### 6.2 JWT

There are no tokens in the wild, so the claim set is being **defined**, not
preserved.

- **Algorithm:** HS256.
- **Key derivation:** treat `JWT_ACCESS_SECRET` as **raw UTF-8 bytes**
  (`Keys.hmacShaKeyFor(secret.getBytes(UTF_8))`), matching what `@nestjs/jwt`
  would have done. Do **not** base64-decode it. The configured secrets are 48
  random bytes base64-encoded (64 chars) — comfortably above the 256-bit HS256
  minimum.
- **Access token claims:** `sub` (user UUID), `role`, `phone`, `iat`, `exp`,
  `jti`. TTL from `JWT_ACCESS_TTL` (15m).
- **Refresh token:** opaque random 256-bit value, **not** a JWT. Rationale in
  §6.3.
- **Filter:** a `OncePerRequestFilter` before
  `UsernamePasswordAuthenticationFilter`, populating an `AppUserPrincipal`
  with authority `ROLE_<role uppercased>` so `@PreAuthorize("hasRole('OWNER')")`
  works.
- Stateless session; CSRF disabled; public matchers for
  `/api/v1/auth/**`, `GET /api/v1/properties/**`, `/api/v1/meta/**`,
  `/actuator/health`.

### 6.3 Refresh token rotation

**Critical constraint discovered in the schema:** `refresh_tokens` has a
partial **UNIQUE** index on `token_hash`, and the refresh flow looks a token
up *by its hash*. That forces a **deterministic** hash — SHA-256 (or HMAC-
SHA256 with a server pepper). **BCrypt cannot be used here**, because it is
salted: every hash of the same token differs, so lookup-by-hash is impossible
and the unique index is meaningless.

This is the one place where the two hashed columns in the schema demand
*different* algorithms, and getting it wrong produces a system that appears to
work until the first refresh:

| Column | Lookup by | Algorithm |
| --- | --- | --- |
| `otp_codes.code_hash` | `phone` | **BCrypt** (salted, slow — correct for a guessable 6-digit secret) |
| `refresh_tokens.token_hash` | **the hash itself** | **SHA-256** (deterministic, indexable; safe because the token is 256 bits of entropy, not guessable) |

Rotation semantics (undefined in `CLAUDE.md`, being decided here):

1. Client presents refresh token → SHA-256 → look up the row.
2. Reject if not found, `revoked_at` set, `expires_at` passed, or soft-deleted.
3. On success: set `revoked_at = now()` on the old row, **insert a new row**,
   return the new pair. Append-only, consistent with `CLAUDE.md` §3.5.
4. **Reuse detection:** presenting an already-revoked token means the token
   leaked. Revoke every live token for that user and return
   `REFRESH_TOKEN_REUSED`.
5. `POST /auth/logout` sets `revoked_at` on the presented token only.

### 6.4 Configuration

Keep every existing env var name (`DB_*`, `JWT_*`, `OTP_*`, `S3_*`) so
deployment config is unchanged, bound via `@ConfigurationProperties` classes
with Bean Validation replacing the Joi schema — same fail-fast-at-boot
behaviour. `application.yml` reads them with `${DB_HOST}` style placeholders.

---

## 7. Migration order and verification

Because nothing exists above the schema, "migration order" is build order.
Sequenced so every step is independently verifiable and nothing is blocked
waiting on the undecided items in §8.10.

**Step 0 — Foundation.** Maven project, `AtrioPgApplication`, Flyway baseline
(§3) including the `BaselineFidelityTest`, all 11 JPA entities + repositories,
`BaseEntity` + auditing, envelope + error handling (§5), Testcontainers
harness, `ddl-auto: validate`.
*Verify:* app boots against Supabase; `validate` passes for all 11 entities;
baseline diff is empty; a trivial `/api/v1/meta/ping` returns a correctly
enveloped body; a deliberate throw returns a correctly enveloped error.

**Step 1 — Auth.** OTP request/verify, JWT issuance, refresh rotation, logout,
`PATCH /auth/profile`, `GET /me`, `SecurityConfig`, entry point + access
denied handler. Also finalize the domain error-code catalogue (§5.4).
*Verify:* Testcontainers integration tests covering happy path, expired OTP,
wrong code, attempt cap, rate limit, refresh rotation, **refresh reuse
detection**, and 401/403 envelope shape. Round-trip: request → verify →
authenticated call → refresh → logout → refreshing with the revoked token
fails.

**Step 2 — Users + ownership plumbing.** `AppUserPrincipal`, `@PreAuthorize`
role checks, the service-layer ownership helper (`CLAUDE.md` §3.13 — services,
never controllers).
*Verify:* a student's token cannot reach any `/owner/**` route (403 with
correct envelope); an owner cannot touch another owner's resource.

**Step 3 — Properties + photos.** Owner CRUD, status transitions, photo
upload. Photo upload depends on the undecided storage choice (§8.10) — if it
is still open, build everything except the upload endpoint.
*Verify:* ownership enforced on every mutation; soft delete leaves the row and
excludes it from reads; `deleted_at`-scoped unique indexes allow re-creating a
deleted natural key.

**Step 4 — Rooms + beds.** Room CRUD with **bed auto-creation** from
`sharing_type` using the existing `BEDS_PER_SHARING_TYPE` mapping
(single 1, double 2, triple 3, four_plus 4 — a floor, not a cap). Bed status
updates. Decide the bed labelling scheme (§8.10).
*Verify:* creating a triple room creates exactly 3 beds with unique labels;
`uq_beds_room_label` is respected; room delete is soft and beds behave
correspondingly.

**Step 5 — `min_rent_paise` / `max_rent_paise` maintenance.** Nothing
currently maintains these (`docs/CURRENT_STATE.md` §6.2 #7) and search depends
on them. Recommend a **database trigger** on `rooms` rather than service code:
it survives raw SQL and cannot be bypassed, matching the existing
`set_updated_at()` precedent. Ships as `V3__maintain_property_rent_range.sql`.
*Verify:* insert/update/soft-delete a room and assert the parent property's
range recomputes, including back to `NULL` when the last room goes.

**Step 6 — Search.** `GET /properties/search` with all filters, the
"≥1 available bed" join, amenity JSONB containment (`@>`, GIN-backed), the
bounding-box prefilter, distance sorting (§8.9 — approach must be decided),
and all four sorts. Then `GET /properties/:id`.
*Verify:* a seeded fixture set with known distances; assert ordering for each
`sort` value, that unpublished and fully-occupied properties are excluded, and
that pagination totals are correct.

**Step 7 — Visit requests.** Student create/list/cancel, owner inbox and
accept/decline/complete.
*Verify:* status transition rules; a student cannot cancel someone else's
request; an owner only sees requests for their own properties.

**Step 8 — `GET /meta/amenities`.** Requires deciding where the canonical list
lives (§8.10).

**Step 9 — Cutover.** Run both backends against the same database in staging,
compare responses endpoint by endpoint, then switch. Drop the TypeORM
`migrations` table (§3.3) and archive `backend/`.

**Standing verification for every step:** Testcontainers integration test on a
real Postgres (never H2 — JSONB, named enums, partial indexes, and triggers
all behave differently); `ddl-auto: validate` green; envelope asserted on both
success and failure; soft-delete filtering asserted explicitly.

---

## 8. Risk list

Ordered by expected pain.

### 8.1 Soft-delete filtering is losing its automatic safety net — **highest risk**

Today TypeORM's `@DeleteDateColumn` excludes soft-deleted rows from *every*
repository read, everywhere, for free. `@SQLRestriction` covers most of that
but not all:

- **Native queries ignore it entirely.** The search query is the most likely
  place to need native SQL (distance maths), and it is exactly where a missing
  `deleted_at IS NULL` silently leaks deleted properties into results.
- **No per-query opt-out.** Admin or audit views that legitimately need
  deleted rows require a second entity mapped to the same table or native SQL.
- **`@ManyToOne` to a soft-deleted parent** throws `EntityNotFoundException`
  rather than returning `null`, turning a data condition into a 500.
- The failure mode is silent and directional: you don't get an error, you get
  wrong data.

*Mitigation:* an `ArchUnit` (or equivalent) test asserting every `@Entity` has
`@SQLRestriction`; a review rule that every `nativeQuery = true` includes the
predicate; explicit tests that soft-deleted rows are absent from every list
endpoint.

### 8.2 Postgres named enums ↔ Java enums

Covered in §4.5. Whichever option is chosen, it is unconventional in some
direction, and a wrong choice fails at runtime on first insert rather than at
compile time.

### 8.3 `@SQLRestriction` + partial unique indexes interact subtly

`uq_users_phone` is `UNIQUE(phone) WHERE deleted_at IS NULL`. A soft-deleted
user's phone is free for re-signup — correct and intended. But Hibernate has
no knowledge of the partial predicate, so a "does this phone exist?" check
written naively against the entity (which is already `deleted_at IS NULL`
filtered) happens to be right, while the same check via native SQL is wrong
unless it repeats the predicate. Easy to get inconsistent.

### 8.4 `numeric(9,6)` JSON serialization differs

Nest's `decimalTransformer` did `parseFloat`, so latitude serialized as
`12.9716`. Jackson serializing `BigDecimal(9,6)` emits `12.971600` — trailing
zeros preserved. Both parse to the same double in Dart, so no functional
break, but the wire bytes differ. If exact JSON fidelity matters, either map
to `Double` or set `WRITE_BIGDECIMAL_AS_PLAIN` plus a custom serializer.
**Decide deliberately rather than discovering it in a diff.**

### 8.5 `timestamptz` JSON precision differs

JS `Date.toISOString()` yields millisecond precision (`...T18:15:16.123Z`).
Java `Instant` from a Postgres `timestamptz` carries **microseconds**
(`...T18:15:16.123456Z`). Again parseable by Dart, but not byte-identical.
Standardize by configuring Jackson to truncate to milliseconds and always emit
`Z`.

### 8.6 `ResponseBodyAdvice` and `String` return types

§5.1. A controller returning a bare `String` will `ClassCastException` at
runtime, not compile time.

### 8.7 `forbidNonWhitelisted` has no true Spring equivalent for query params

Nest rejects **any** undeclared property on body *or* query with a 400. In
Spring:
- **Body:** reproducible — enable
  `spring.jackson.deserialization.fail-on-unknown-properties: true` (Spring
  Boot **disables** it by default, so this must be set explicitly).
- **Query params:** **not reproducible.** Spring silently ignores unknown
  query parameters. Matching Nest exactly would need a custom
  `HandlerInterceptor` comparing incoming parameter names against the
  handler's bound parameters. Recommend accepting the difference and
  documenting it, unless strict parity is required.

### 8.8 `lower(email)` uniqueness is enforced only by the index

`uq_users_email` is on `lower(email)`. Java must lowercase on write *and* on
lookup, or you get a `DataIntegrityViolationException` where you expected a
clean "email taken" check. Not hard — just invisible until it bites.

### 8.9 Distance search has no chosen implementation

`CLAUDE.md` §2 says "PostGIS-style distance queries" but **PostGIS is not
installed**, nor `cube`/`earthdistance` — only `pgcrypto`. Options: install
PostGIS on Supabase (supported, but a new migration and a heavier dependency),
install `earthdistance`, or hand-write Haversine SQL over the existing
`idx_properties_lat_lng` bounding box. The last needs no extension and is
adequate at Indian-city scale, but it cannot use a spatial index, so it scans
the bounding-box result set. Must be decided before Step 6.

### 8.10 Decisions still open that block specific steps

Carried forward from `docs/CURRENT_STATE.md` §7 — none has an answer in code:

| Blocked step | Decision needed |
| --- | --- |
| Step 1 | **SMS provider** — none chosen or configured. Blocks real OTP delivery. |
| Step 1 | `users.role` defaults to `'student'`, so "role settable once" is unenforceable — needs a nullable role, `role_chosen_at`, or `profile_completed` column (a new Flyway migration). |
| Step 3 | **Object storage** — Supabase Storage vs S3. No SDK installed; config keys are empty. |
| Step 4 | **Bed labelling scheme** (`A`/`B` vs `1`/`2`), constrained by `uq_beds_room_label`. |
| Step 6 | **Distance strategy** (§8.9). |
| Step 8 | **Amenity canonical list** location — `CLAUDE.md` §3.6 says new amenities must need no migration, which argues against a table. |

### 8.11 Lombok + MapStruct annotation-processor ordering

A classic Maven trap: without `lombok-mapstruct-binding` on the annotation
processor path, MapStruct runs before Lombok generates getters and emits
mappers with missing properties. Pin the processor order in
`maven-compiler-plugin` from the start.

### 8.12 No test baseline exists

The current project has **zero tests and no test framework**
(`docs/CURRENT_STATE.md` §6.3 #17). There is no characterization suite to
migrate against and nothing to diff behaviour with. Every test in the Java
project is net-new, and the correctness bar is `CLAUDE.md` §6 plus judgement —
not an existing passing suite. This raises the value of Step 9's
side-by-side comparison, but note that the Nest side has nothing to compare
*with*, so cutover verification is really "does it match the spec", not "does
it match the old system".

### 8.13 `Instant` + `@LastModifiedDate` vs the DB trigger

§4.2. The trigger overwrites Hibernate's value, so a returned entity may
report a slightly stale `updatedAt` unless refreshed. Harmless until an
endpoint's response is asserted against the stored value in a test, at which
point it produces a confusing flake.

---

## 9. What I need from you before starting

1. **Approval of this plan**, or edits to it.
2. **Confirmation of the premise correction in §0** — specifically, that no
   Flutter app exists elsewhere that I should be matching.
3. **Decisions on §4.5** (enum naming) and **§8.4 / §8.5** (JSON number and
   timestamp formats) — these three shape the entity layer and the wire
   format, and are expensive to change later.
4. **A call on the §8.10 blockers**, or agreement to proceed and stub around
   them (SMS and storage can be stubbed; the `role` and distance decisions
   cannot be deferred past Steps 1 and 6 respectively).
