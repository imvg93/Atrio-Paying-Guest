import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateBeds1784500007000 implements MigrationInterface {
  name = 'CreateBeds1784500007000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TYPE "beds_status_enum"
        AS ENUM ('available', 'occupied', 'maintenance')
    `);

    await queryRunner.query(`
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
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "idx_beds_room_id" ON "beds" ("room_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "idx_beds_status" ON "beds" ("status")
    `);
    // "at least one available bed" is the core search filter.
    await queryRunner.query(`
      CREATE INDEX "idx_beds_available"
        ON "beds" ("room_id")
        WHERE "deleted_at" IS NULL AND "status" = 'available'
    `);
    await queryRunner.query(`
      CREATE UNIQUE INDEX "uq_beds_room_label"
        ON "beds" ("room_id", "label")
        WHERE "deleted_at" IS NULL
    `);

    await queryRunner.query(`
      CREATE TRIGGER "trg_beds_updated_at"
        BEFORE UPDATE ON "beds"
        FOR EACH ROW EXECUTE FUNCTION set_updated_at()
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP TRIGGER IF EXISTS "trg_beds_updated_at" ON "beds"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "beds"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "beds_status_enum"`);
  }
}
