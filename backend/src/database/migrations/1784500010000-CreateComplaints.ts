import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateComplaints1784500010000 implements MigrationInterface {
  name = 'CreateComplaints1784500010000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TYPE "complaints_category_enum"
        AS ENUM ('electrical', 'plumbing', 'cleaning', 'food', 'wifi', 'other')
    `);
    await queryRunner.query(`
      CREATE TYPE "complaints_status_enum"
        AS ENUM ('open', 'in_progress', 'resolved', 'closed')
    `);

    await queryRunner.query(`
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
          FOREIGN KEY ("occupancy_id") REFERENCES "occupancies" ("id")
          ON DELETE RESTRICT,
        CONSTRAINT "chk_complaints_photos_is_array"
          CHECK ("photos" IS NULL OR jsonb_typeof("photos") = 'array')
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "idx_complaints_occupancy_id"
        ON "complaints" ("occupancy_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "idx_complaints_status" ON "complaints" ("status")
    `);
    // Owner/student complaint lists are newest-first within an occupancy.
    await queryRunner.query(`
      CREATE INDEX "idx_complaints_occupancy_created_at"
        ON "complaints" ("occupancy_id", "created_at" DESC)
        WHERE "deleted_at" IS NULL
    `);

    await queryRunner.query(`
      CREATE TRIGGER "trg_complaints_updated_at"
        BEFORE UPDATE ON "complaints"
        FOR EACH ROW EXECUTE FUNCTION set_updated_at()
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP TRIGGER IF EXISTS "trg_complaints_updated_at" ON "complaints"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "complaints"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "complaints_status_enum"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "complaints_category_enum"`);
  }
}
