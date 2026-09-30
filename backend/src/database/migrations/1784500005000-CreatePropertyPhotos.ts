import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreatePropertyPhotos1784500005000 implements MigrationInterface {
  name = 'CreatePropertyPhotos1784500005000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
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
          FOREIGN KEY ("property_id") REFERENCES "properties" ("id")
          ON DELETE RESTRICT
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "idx_property_photos_property_id"
        ON "property_photos" ("property_id", "sort_order")
        WHERE "deleted_at" IS NULL
    `);

    await queryRunner.query(`
      CREATE TRIGGER "trg_property_photos_updated_at"
        BEFORE UPDATE ON "property_photos"
        FOR EACH ROW EXECUTE FUNCTION set_updated_at()
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP TRIGGER IF EXISTS "trg_property_photos_updated_at" ON "property_photos"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "property_photos"`);
  }
}
