import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateRooms1784500006000 implements MigrationInterface {
  name = 'CreateRooms1784500006000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TYPE "rooms_sharing_type_enum"
        AS ENUM ('single', 'double', 'triple', 'four_plus')
    `);

    await queryRunner.query(`
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
          FOREIGN KEY ("property_id") REFERENCES "properties" ("id")
          ON DELETE RESTRICT,
        CONSTRAINT "chk_rooms_rent_non_negative"
          CHECK ("rent_per_bed_paise" >= 0),
        CONSTRAINT "chk_rooms_deposit_non_negative"
          CHECK ("deposit_paise" >= 0)
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "idx_rooms_property_id" ON "rooms" ("property_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "idx_rooms_sharing_type" ON "rooms" ("sharing_type")
    `);
    // Room numbers are unique within a property, ignoring soft-deleted rooms.
    await queryRunner.query(`
      CREATE UNIQUE INDEX "uq_rooms_property_room_number"
        ON "rooms" ("property_id", "room_number")
        WHERE "deleted_at" IS NULL
    `);

    await queryRunner.query(`
      CREATE TRIGGER "trg_rooms_updated_at"
        BEFORE UPDATE ON "rooms"
        FOR EACH ROW EXECUTE FUNCTION set_updated_at()
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP TRIGGER IF EXISTS "trg_rooms_updated_at" ON "rooms"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "rooms"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "rooms_sharing_type_enum"`);
  }
}
