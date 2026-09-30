# ATRIO-PG — Backend

NestJS + PostgreSQL + TypeORM API for the PG Finder & Hostel Management app.
See `../CLAUDE.md` for the architecture rules this codebase must follow.

**Status:** Phase 1 skeleton — config, database wiring, entities, and migrations.
No endpoints yet.

## Prerequisites

- Node 20+
- PostgreSQL 14+ (16 recommended)

## Setup

```bash
cp .env.example .env      # then fill in DB creds + JWT secrets
npm install
```

This project's database is a hosted **Supabase** Postgres, so `.env` points at
it directly — set `DB_SSL=true` and use the Postgres password from
Dashboard → Project Settings → Database. (The Supabase *anon/publishable* key is
for the JS/REST client and is useless to TypeORM, which speaks the raw Postgres
wire protocol.)

The direct host `db.<ref>.supabase.co` resolves **AAAA-only**; if your network
has no IPv6, use the Session pooler host instead:

```
DB_HOST=aws-0-<region>.pooler.supabase.com
DB_USERNAME=postgres.<ref>
```

`docker-compose.yml` remains for anyone who prefers a local Postgres:

```bash
docker compose up -d postgres
```

Run the migrations:

```bash
npm run migration:run
```

Start the API:

```bash
npm run start:dev         # http://localhost:3000/api/v1
```

## Migrations

`synchronize` is hardcoded `false` (CLAUDE.md §3.4). Schema changes are new
migration files only — never edit a committed one.

| Command                                          | What it does                        |
| ------------------------------------------------ | ----------------------------------- |
| `npm run migration:run`                          | Apply pending migrations            |
| `npm run migration:revert`                       | Roll back the most recent migration |
| `npm run migration:show`                         | List applied / pending              |
| `npm run migration:create src/database/migrations/Name` | New empty migration          |
| `npm run migration:generate src/database/migrations/Name` | Diff entities → migration   |

## Conventions

- **Money** is `BIGINT` paise everywhere. Never floats. A `bigintTransformer`
  converts to `number` on read (paise fits comfortably in a JS safe integer).
- **Soft deletes only.** Every table has `deleted_at`; entities extend
  `BaseEntity` with a `@DeleteDateColumn`, so repository reads exclude deleted
  rows automatically. Use `softDelete()` / `softRemove()` — never `delete()`.
- **Unique constraints are partial**, scoped `WHERE deleted_at IS NULL`, so a
  soft-deleted row never blocks re-creating the same natural key.
- **`updated_at`** is maintained by both TypeORM and a per-table Postgres
  trigger (`set_updated_at()`), so raw SQL writes stay correct too.
- **FKs are `ON DELETE RESTRICT`** — the database refuses hard deletes,
  enforcing the soft-delete rule instead of relying on discipline.

## Layout

```
src/
  config/                 env schema (Joi) + typed config
  database/
    typeorm.config.ts     connection options shared by app + CLI
    data-source.ts        TypeORM CLI entrypoint
    migrations/           versioned migrations
  common/
    entities/             BaseEntity (id, created_at, updated_at, deleted_at)
    dto/                  pagination
    interceptors/         success response envelope
    filters/              error response envelope
    transformers/         bigint / decimal
  modules/<domain>/       entities, enums, module (controllers/services next)
```
