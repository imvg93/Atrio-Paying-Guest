import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateProperties1784500004000 implements MigrationInterface {
  name = 'CreateProperties1784500004000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TYPE "properties_gender_type_enum"
        AS ENUM ('male', 'female', 'coliving')
    `);
    await queryRunner.query(`
      CREATE TYPE "properties_status_enum"
        AS ENUM ('draft', 'published', 'unlisted')
    `);

    await queryRunner.query(`
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
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "idx_properties_owner_id" ON "properties" ("owner_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "idx_properties_city" ON "properties" ("city")
    `);
    await queryRunner.query(`
      CREATE INDEX "idx_properties_locality" ON "properties" ("locality")
    `);
    await queryRunner.query(`
      CREATE INDEX "idx_properties_status" ON "properties" ("status")
    `);
    // Bounding-box prefilter for radius search before the distance calculation.
    await queryRunner.query(`
      CREATE INDEX "idx_properties_lat_lng"
        ON "properties" ("latitude", "longitude")
    `);
    // The hot path for /properties/search: published, not deleted, by city.
    await queryRunner.query(`
      CREATE INDEX "idx_properties_search"
        ON "properties" ("city", "gender_type", "min_rent_paise")
        WHERE "deleted_at" IS NULL AND "status" = 'published'
    `);
    // Amenity filtering uses JSONB containment (@>), which needs GIN.
    await queryRunner.query(`
      CREATE INDEX "idx_properties_amenities"
        ON "properties" USING GIN ("amenities")
    `);

    await queryRunner.query(`
      CREATE TRIGGER "trg_properties_updated_at"
        BEFORE UPDATE ON "properties"
        FOR EACH ROW EXECUTE FUNCTION set_updated_at()
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP TRIGGER IF EXISTS "trg_properties_updated_at" ON "properties"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "properties"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "properties_status_enum"`);
    await queryRunner.query(
      `DROP TYPE IF EXISTS "properties_gender_type_enum"`,
    );
  }
}
