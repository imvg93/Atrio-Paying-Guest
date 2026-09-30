-- =============================================================================
-- V1 - Baseline of the schema created by the original TypeORM migrations
--      (1784500000000-InitExtensions .. 1784500011000-CreateReviews).
--
-- IMPORTANT: this script NEVER runs against the existing Supabase database.
-- That database is baselined at version 1 (spring.flyway.baseline-on-migrate),
-- so Flyway records a BASELINE row and skips this file. It runs only on an
-- empty database - i.e. Testcontainers - where it must reproduce the live
-- schema exactly.
--
-- Frozen once baselined. Never edit (CLAUDE.md 3.4). All later changes are V2+.
-- =============================================================================

-- --------------------------------------------------------------------------
-- Extensions and shared functions
-- --------------------------------------------------------------------------

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- @UpdateDateColumn / @LastModifiedDate only fire for writes that go through
-- the ORM. This trigger guarantees updated_at is correct for raw SQL too,
-- which is what CLAUDE.md 3.3 ("auto-managed") requires.
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------------------------------------
-- Enum types (label order is significant - it drives ORDER BY on enum columns)
-- --------------------------------------------------------------------------

CREATE TYPE "users_role_enum"                    AS ENUM ('student', 'owner', 'admin');
CREATE TYPE "users_gender_enum"                  AS ENUM ('male', 'female', 'other');
CREATE TYPE "properties_gender_type_enum"        AS ENUM ('male', 'female', 'coliving');
CREATE TYPE "properties_status_enum"             AS ENUM ('draft', 'published', 'unlisted');
CREATE TYPE "rooms_sharing_type_enum"            AS ENUM ('single', 'double', 'triple', 'four_plus');
CREATE TYPE "beds_status_enum"                   AS ENUM ('available', 'occupied', 'maintenance');
CREATE TYPE "occupancies_status_enum"            AS ENUM ('active', 'notice_period', 'ended');
CREATE TYPE "visit_requests_preferred_slot_enum" AS ENUM ('morning', 'afternoon', 'evening');
CREATE TYPE "visit_requests_status_enum"         AS ENUM ('pending', 'accepted', 'declined', 'completed', 'cancelled');
CREATE TYPE "complaints_category_enum"           AS ENUM ('electrical', 'plumbing', 'cleaning', 'food', 'wifi', 'other');
CREATE TYPE "complaints_status_enum"             AS ENUM ('open', 'in_progress', 'resolved', 'closed');

-- --------------------------------------------------------------------------
-- users
-- --------------------------------------------------------------------------

CREATE TABLE "users" (
  "id"            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "phone"         varchar(15) NOT NULL,
  "name"          varchar(255),
  "email"         varchar(255),
  "role"          "users_role_enum" NOT NULL DEFAULT 'student',
  "gender"        "users_gender_enum",
  "avatar_url"    varchar(512),
  "is_active"     boolean NOT NULL DEFAULT true,
  "last_login_at" timestamptz,
  "created_at"    timestamptz NOT NULL DEFAULT now(),
  "updated_at"    timestamptz NOT NULL DEFAULT now(),
  "deleted_at"    timestamptz
);

-- Uniqueness is soft-delete aware: a deleted row must not block re-signup.
CREATE UNIQUE INDEX "uq_users_phone"
  ON "users" ("phone") WHERE "deleted_at" IS NULL;
CREATE UNIQUE INDEX "uq_users_email"
  ON "users" (lower("email"))
  WHERE "deleted_at" IS NULL AND "email" IS NOT NULL;
CREATE INDEX "idx_users_role" ON "users" ("role");

CREATE TRIGGER "trg_users_updated_at"
  BEFORE UPDATE ON "users"
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- --------------------------------------------------------------------------
-- otp_codes  (deliberately not FK'd to users - an OTP precedes the account)
-- --------------------------------------------------------------------------

CREATE TABLE "otp_codes" (
  "id"          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "phone"       varchar(15) NOT NULL,
  "code_hash"   varchar(255) NOT NULL,
  "expires_at"  timestamptz NOT NULL,
  "attempts"    integer NOT NULL DEFAULT 0,
  "consumed_at" timestamptz,
  "created_at"  timestamptz NOT NULL DEFAULT now(),
  "updated_at"  timestamptz NOT NULL DEFAULT now(),
  "deleted_at"  timestamptz
);

CREATE INDEX "idx_otp_codes_phone" ON "otp_codes" ("phone");
CREATE INDEX "idx_otp_codes_expires_at" ON "otp_codes" ("expires_at");
-- Serves both the rate limiter (3 requests / phone / 10 min) and the
-- "latest live code for this phone" lookup during verify.
CREATE INDEX "idx_otp_codes_phone_created_at"
  ON "otp_codes" ("phone", "created_at" DESC)
  WHERE "deleted_at" IS NULL;

CREATE TRIGGER "trg_otp_codes_updated_at"
  BEFORE UPDATE ON "otp_codes"
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- --------------------------------------------------------------------------
-- refresh_tokens
-- --------------------------------------------------------------------------

CREATE TABLE "refresh_tokens" (
  "id"         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id"    uuid NOT NULL,
  "token_hash" varchar(255) NOT NULL,
  "expires_at" timestamptz NOT NULL,
  "revoked_at" timestamptz,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "deleted_at" timestamptz,
  CONSTRAINT "fk_refresh_tokens_user"
    FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE RESTRICT
);

CREATE INDEX "idx_refresh_tokens_user_id" ON "refresh_tokens" ("user_id");
CREATE INDEX "idx_refresh_tokens_expires_at" ON "refresh_tokens" ("expires_at");
-- Token lookup on refresh is by hash, so the hash must be deterministic.
CREATE UNIQUE INDEX "uq_refresh_tokens_token_hash"
  ON "refresh_tokens" ("token_hash") WHERE "deleted_at" IS NULL;

CREATE TRIGGER "trg_refresh_tokens_updated_at"
  BEFORE UPDATE ON "refresh_tokens"
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- --------------------------------------------------------------------------
-- properties
-- --------------------------------------------------------------------------

CREATE TABLE "properties" (
  "id"                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "owner_id"           uuid NOT NULL,
  "name"               varchar(255) NOT NULL,
  "description"        text,
  "gender_type"        "properties_gender_type_enum" NOT NULL,
  "address_line"       varchar(512) NOT NULL,
  "locality"           varchar(255) NOT NULL,
  "city"               varchar(255) NOT NULL,
  "state"              varchar(255) NOT NULL,
  "pincode"            varchar(10) NOT NULL,
  "latitude"           numeric(9,6) NOT NULL,
  "longitude"          numeric(9,6) NOT NULL,
  "amenities"          jsonb NOT NULL DEFAULT '{}'::jsonb,
  "rules"              jsonb,
  "food_included"      boolean NOT NULL DEFAULT false,
  "notice_period_days" integer NOT NULL DEFAULT 30,
  "status"             "properties_status_enum" NOT NULL DEFAULT 'draft',
  "min_rent_paise"     bigint,
  "max_rent_paise"     bigint,
  "created_at"         timestamptz NOT NULL DEFAULT now(),
  "updated_at"         timestamptz NOT NULL DEFAULT now(),
  "deleted_at"         timestamptz,
  CONSTRAINT "fk_properties_owner"
    FOREIGN KEY ("owner_id") REFERENCES "users" ("id") ON DELETE RESTRICT,
  CONSTRAINT "chk_properties_latitude"
    CHECK ("latitude" BETWEEN -90 AND 90),
  CONSTRAINT "chk_properties_longitude"
    CHECK ("longitude" BETWEEN -180 AND 180),
  CONSTRAINT "chk_properties_notice_period_days"
    CHECK ("notice_period_days" >= 0),
  CONSTRAINT "chk_properties_rent_range"
    CHECK (
      "min_rent_paise" IS NULL
      OR "max_rent_paise" IS NULL
      OR "min_rent_paise" <= "max_rent_paise"
    )
);

CREATE INDEX "idx_properties_owner_id" ON "properties" ("owner_id");
CREATE INDEX "idx_properties_city" ON "properties" ("city");
CREATE INDEX "idx_properties_locality" ON "properties" ("locality");
CREATE INDEX "idx_properties_status" ON "properties" ("status");
-- Bounding-box prefilter for radius search before the distance calculation.
CREATE INDEX "idx_properties_lat_lng" ON "properties" ("latitude", "longitude");
-- The hot path for /properties/search: published, not deleted, by city.
CREATE INDEX "idx_properties_search"
  ON "properties" ("city", "gender_type", "min_rent_paise")
  WHERE "deleted_at" IS NULL AND "status" = 'published';
-- Amenity filtering uses JSONB containment (@>), which needs GIN.
CREATE INDEX "idx_properties_amenities" ON "properties" USING GIN ("amenities");

CREATE TRIGGER "trg_properties_updated_at"
  BEFORE UPDATE ON "properties"
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- --------------------------------------------------------------------------
-- property_photos
-- --------------------------------------------------------------------------

CREATE TABLE "property_photos" (
  "id"          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "property_id" uuid NOT NULL,
  "url"         varchar(1024) NOT NULL,
  "sort_order"  integer NOT NULL DEFAULT 0,
  "caption"     varchar(255),
  "created_at"  timestamptz NOT NULL DEFAULT now(),
  "updated_at"  timestamptz NOT NULL DEFAULT now(),
  "deleted_at"  timestamptz,
  CONSTRAINT "fk_property_photos_property"
    FOREIGN KEY ("property_id") REFERENCES "properties" ("id") ON DELETE RESTRICT
);

CREATE INDEX "idx_property_photos_property_id"
  ON "property_photos" ("property_id", "sort_order")
  WHERE "deleted_at" IS NULL;

CREATE TRIGGER "trg_property_photos_updated_at"
  BEFORE UPDATE ON "property_photos"
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- --------------------------------------------------------------------------
-- rooms
-- --------------------------------------------------------------------------

CREATE TABLE "rooms" (
  "id"                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "property_id"           uuid NOT NULL,
  "room_number"           varchar(50) NOT NULL,
  "floor"                 integer,
  "sharing_type"          "rooms_sharing_type_enum" NOT NULL,
  "rent_per_bed_paise"    bigint NOT NULL,
  "deposit_paise"         bigint NOT NULL,
  "has_attached_bathroom" boolean NOT NULL DEFAULT false,
  "has_ac"                boolean NOT NULL DEFAULT false,
  "created_at"            timestamptz NOT NULL DEFAULT now(),
  "updated_at"            timestamptz NOT NULL DEFAULT now(),
  "deleted_at"            timestamptz,
  CONSTRAINT "fk_rooms_property"
    FOREIGN KEY ("property_id") REFERENCES "properties" ("id") ON DELETE RESTRICT,
  CONSTRAINT "chk_rooms_rent_non_negative"
    CHECK ("rent_per_bed_paise" >= 0),
  CONSTRAINT "chk_rooms_deposit_non_negative"
    CHECK ("deposit_paise" >= 0)
);

CREATE INDEX "idx_rooms_property_id" ON "rooms" ("property_id");
CREATE INDEX "idx_rooms_sharing_type" ON "rooms" ("sharing_type");
-- Room numbers are unique within a property, ignoring soft-deleted rooms.
CREATE UNIQUE INDEX "uq_rooms_property_room_number"
  ON "rooms" ("property_id", "room_number")
  WHERE "deleted_at" IS NULL;

CREATE TRIGGER "trg_rooms_updated_at"
  BEFORE UPDATE ON "rooms"
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- --------------------------------------------------------------------------
-- beds
-- --------------------------------------------------------------------------

CREATE TABLE "beds" (
  "id"         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "room_id"    uuid NOT NULL,
  "label"      varchar(20) NOT NULL,
  "status"     "beds_status_enum" NOT NULL DEFAULT 'available',
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "deleted_at" timestamptz,
  CONSTRAINT "fk_beds_room"
    FOREIGN KEY ("room_id") REFERENCES "rooms" ("id") ON DELETE RESTRICT
);

CREATE INDEX "idx_beds_room_id" ON "beds" ("room_id");
CREATE INDEX "idx_beds_status" ON "beds" ("status");
-- "at least one available bed" is the core search filter.
CREATE INDEX "idx_beds_available"
  ON "beds" ("room_id")
  WHERE "deleted_at" IS NULL AND "status" = 'available';
CREATE UNIQUE INDEX "uq_beds_room_label"
  ON "beds" ("room_id", "label")
  WHERE "deleted_at" IS NULL;

CREATE TRIGGER "trg_beds_updated_at"
  BEFORE UPDATE ON "beds"
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- --------------------------------------------------------------------------
-- occupancies  (history is sacred - CLAUDE.md 3.5 / 4)
-- --------------------------------------------------------------------------

CREATE TABLE "occupancies" (
  "id"            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "bed_id"        uuid NOT NULL,
  "student_id"    uuid NOT NULL,
  "start_date"    date NOT NULL,
  "end_date"      date,
  "rent_paise"    bigint NOT NULL,
  "deposit_paise" bigint NOT NULL,
  "status"        "occupancies_status_enum" NOT NULL DEFAULT 'active',
  "created_at"    timestamptz NOT NULL DEFAULT now(),
  "updated_at"    timestamptz NOT NULL DEFAULT now(),
  "deleted_at"    timestamptz,
  CONSTRAINT "fk_occupancies_bed"
    FOREIGN KEY ("bed_id") REFERENCES "beds" ("id") ON DELETE RESTRICT,
  CONSTRAINT "fk_occupancies_student"
    FOREIGN KEY ("student_id") REFERENCES "users" ("id") ON DELETE RESTRICT,
  CONSTRAINT "chk_occupancies_date_order"
    CHECK ("end_date" IS NULL OR "end_date" >= "start_date"),
  CONSTRAINT "chk_occupancies_rent_non_negative"
    CHECK ("rent_paise" >= 0),
  CONSTRAINT "chk_occupancies_deposit_non_negative"
    CHECK ("deposit_paise" >= 0)
);

CREATE INDEX "idx_occupancies_bed_id" ON "occupancies" ("bed_id");
CREATE INDEX "idx_occupancies_student_id" ON "occupancies" ("student_id");
CREATE INDEX "idx_occupancies_status" ON "occupancies" ("status");
-- A bed can have at most one open occupancy. Closed rows (end_date set) are
-- exempt, so history accumulates rather than being overwritten.
CREATE UNIQUE INDEX "uq_occupancies_open_per_bed"
  ON "occupancies" ("bed_id")
  WHERE "deleted_at" IS NULL AND "end_date" IS NULL;

CREATE TRIGGER "trg_occupancies_updated_at"
  BEFORE UPDATE ON "occupancies"
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- --------------------------------------------------------------------------
-- visit_requests
-- --------------------------------------------------------------------------

CREATE TABLE "visit_requests" (
  "id"             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "property_id"    uuid NOT NULL,
  "student_id"     uuid NOT NULL,
  "preferred_date" date NOT NULL,
  "preferred_slot" "visit_requests_preferred_slot_enum" NOT NULL,
  "message"        text,
  "status"         "visit_requests_status_enum" NOT NULL DEFAULT 'pending',
  "responded_at"   timestamptz,
  "created_at"     timestamptz NOT NULL DEFAULT now(),
  "updated_at"     timestamptz NOT NULL DEFAULT now(),
  "deleted_at"     timestamptz,
  CONSTRAINT "fk_visit_requests_property"
    FOREIGN KEY ("property_id") REFERENCES "properties" ("id") ON DELETE RESTRICT,
  CONSTRAINT "fk_visit_requests_student"
    FOREIGN KEY ("student_id") REFERENCES "users" ("id") ON DELETE RESTRICT
);

CREATE INDEX "idx_visit_requests_property_id" ON "visit_requests" ("property_id");
CREATE INDEX "idx_visit_requests_student_id" ON "visit_requests" ("student_id");
CREATE INDEX "idx_visit_requests_status" ON "visit_requests" ("status");
-- Owner inbox: /owner/visit-requests?status=
CREATE INDEX "idx_visit_requests_property_status"
  ON "visit_requests" ("property_id", "status", "preferred_date")
  WHERE "deleted_at" IS NULL;

CREATE TRIGGER "trg_visit_requests_updated_at"
  BEFORE UPDATE ON "visit_requests"
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- --------------------------------------------------------------------------
-- complaints
-- --------------------------------------------------------------------------

CREATE TABLE "complaints" (
  "id"           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "occupancy_id" uuid NOT NULL,
  "category"     "complaints_category_enum" NOT NULL,
  "title"        varchar(255) NOT NULL,
  "description"  text NOT NULL,
  "photos"       jsonb,
  "status"       "complaints_status_enum" NOT NULL DEFAULT 'open',
  "resolved_at"  timestamptz,
  "created_at"   timestamptz NOT NULL DEFAULT now(),
  "updated_at"   timestamptz NOT NULL DEFAULT now(),
  "deleted_at"   timestamptz,
  CONSTRAINT "fk_complaints_occupancy"
    FOREIGN KEY ("occupancy_id") REFERENCES "occupancies" ("id") ON DELETE RESTRICT,
  CONSTRAINT "chk_complaints_photos_is_array"
    CHECK ("photos" IS NULL OR jsonb_typeof("photos") = 'array')
);

CREATE INDEX "idx_complaints_occupancy_id" ON "complaints" ("occupancy_id");
CREATE INDEX "idx_complaints_status" ON "complaints" ("status");
-- Owner/student complaint lists are newest-first within an occupancy.
CREATE INDEX "idx_complaints_occupancy_created_at"
  ON "complaints" ("occupancy_id", "created_at" DESC)
  WHERE "deleted_at" IS NULL;

CREATE TRIGGER "trg_complaints_updated_at"
  BEFORE UPDATE ON "complaints"
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- --------------------------------------------------------------------------
-- reviews
-- --------------------------------------------------------------------------

CREATE TABLE "reviews" (
  "id"          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "property_id" uuid NOT NULL,
  "student_id"  uuid NOT NULL,
  "rating"      integer NOT NULL,
  "comment"     text,
  "created_at"  timestamptz NOT NULL DEFAULT now(),
  "updated_at"  timestamptz NOT NULL DEFAULT now(),
  "deleted_at"  timestamptz,
  CONSTRAINT "fk_reviews_property"
    FOREIGN KEY ("property_id") REFERENCES "properties" ("id") ON DELETE RESTRICT,
  CONSTRAINT "fk_reviews_student"
    FOREIGN KEY ("student_id") REFERENCES "users" ("id") ON DELETE RESTRICT,
  CONSTRAINT "chk_reviews_rating_range"
    CHECK ("rating" BETWEEN 1 AND 5)
);

CREATE INDEX "idx_reviews_property_id" ON "reviews" ("property_id");
CREATE INDEX "idx_reviews_student_id" ON "reviews" ("student_id");
-- One live review per student per property.
CREATE UNIQUE INDEX "uq_reviews_property_student"
  ON "reviews" ("property_id", "student_id")
  WHERE "deleted_at" IS NULL;

CREATE TRIGGER "trg_reviews_updated_at"
  BEFORE UPDATE ON "reviews"
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
