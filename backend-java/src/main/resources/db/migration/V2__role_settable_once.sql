-- Makes "role is settable once" (CLAUDE.md 6) enforceable.
--
-- The problem (docs/CURRENT_STATE.md 6.2 #9): users.role was
-- NOT NULL DEFAULT 'student', so a row was already a student the instant it
-- was created. Nothing could distinguish "has not chosen yet" from
-- "deliberately chose student", and the rule was unenforceable.
--
-- Two changes, both additive and safe on a populated database:
--
--   1. Drop the DEFAULT. role stays NOT NULL, so every insert must now state a
--      role explicitly. No row's role is an accident of DDL any more.
--
--   2. Add role_chosen_at. NULL means the user has never picked a role;
--      PATCH /auth/profile stamps it on the first choice and rejects any later
--      change with ROLE_ALREADY_SET.
--
-- role deliberately stays NOT NULL rather than becoming nullable: the Flutter
-- client models User.role as non-nullable and its router switches on it
-- exhaustively, so a null role would ripple through the app for no gain. A new
-- account is created as a provisional 'student' with role_chosen_at NULL.

ALTER TABLE "users" ALTER COLUMN "role" DROP DEFAULT;

ALTER TABLE "users" ADD COLUMN "role_chosen_at" timestamptz;

-- Backfill: a user who already has a name went through the profile screen
-- under the old rules, so treat their role as chosen and lock it. The true
-- instant is unrecoverable, so created_at stands in for it.
UPDATE "users"
   SET "role_chosen_at" = "created_at"
 WHERE "deleted_at" IS NULL
   AND "name" IS NOT NULL
   AND btrim("name") <> '';

COMMENT ON COLUMN "users"."role_chosen_at" IS
  'When the user chose their role. NULL = never chosen, so PATCH /auth/profile may still set it.';
