import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateOccupancies1784500008000 implements MigrationInterface {
  name = 'CreateOccupancies1784500008000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TYPE "occupancies_status_enum"
        AS ENUM ('active', 'notice_period', 'ended')
    `);

    await queryRunner.query(`
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
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "idx_occupancies_bed_id" ON "occupancies" ("bed_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "idx_occupancies_student_id" ON "occupancies" ("student_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "idx_occupancies_status" ON "occupancies" ("status")
    `);
    // A bed can have at most one open occupancy. Closed rows (end_date set) are
    // exempt, so history accumulates rather than being overwritten —
    // CLAUDE.md §3.5.
    await queryRunner.query(`
      CREATE UNIQUE INDEX "uq_occupancies_open_per_bed"
        ON "occupancies" ("bed_id")
        WHERE "deleted_at" IS NULL AND "end_date" IS NULL
    `);

    await queryRunner.query(`
      CREATE TRIGGER "trg_occupancies_updated_at"
        BEFORE UPDATE ON "occupancies"
        FOR EACH ROW EXECUTE FUNCTION set_updated_at()
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP TRIGGER IF EXISTS "trg_occupancies_updated_at" ON "occupancies"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "occupancies"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "occupancies_status_enum"`);
  }
}
