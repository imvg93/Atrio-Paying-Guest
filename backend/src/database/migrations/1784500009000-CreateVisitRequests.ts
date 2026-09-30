import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateVisitRequests1784500009000 implements MigrationInterface {
  name = 'CreateVisitRequests1784500009000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TYPE "visit_requests_preferred_slot_enum"
        AS ENUM ('morning', 'afternoon', 'evening')
    `);
    await queryRunner.query(`
      CREATE TYPE "visit_requests_status_enum"
        AS ENUM ('pending', 'accepted', 'declined', 'completed', 'cancelled')
    `);

    await queryRunner.query(`
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
          FOREIGN KEY ("property_id") REFERENCES "properties" ("id")
          ON DELETE RESTRICT,
        CONSTRAINT "fk_visit_requests_student"
          FOREIGN KEY ("student_id") REFERENCES "users" ("id")
          ON DELETE RESTRICT
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "idx_visit_requests_property_id"
        ON "visit_requests" ("property_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "idx_visit_requests_student_id"
        ON "visit_requests" ("student_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "idx_visit_requests_status" ON "visit_requests" ("status")
    `);
    // Owner inbox: /owner/visit-requests?status=
    await queryRunner.query(`
      CREATE INDEX "idx_visit_requests_property_status"
        ON "visit_requests" ("property_id", "status", "preferred_date")
        WHERE "deleted_at" IS NULL
    `);

    await queryRunner.query(`
      CREATE TRIGGER "trg_visit_requests_updated_at"
        BEFORE UPDATE ON "visit_requests"
        FOR EACH ROW EXECUTE FUNCTION set_updated_at()
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP TRIGGER IF EXISTS "trg_visit_requests_updated_at" ON "visit_requests"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "visit_requests"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "visit_requests_status_enum"`);
    await queryRunner.query(
      `DROP TYPE IF EXISTS "visit_requests_preferred_slot_enum"`,
    );
  }
}
