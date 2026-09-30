import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateReviews1784500011000 implements MigrationInterface {
  name = 'CreateReviews1784500011000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
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
          FOREIGN KEY ("property_id") REFERENCES "properties" ("id")
          ON DELETE RESTRICT,
        CONSTRAINT "fk_reviews_student"
          FOREIGN KEY ("student_id") REFERENCES "users" ("id")
          ON DELETE RESTRICT,
        CONSTRAINT "chk_reviews_rating_range"
          CHECK ("rating" BETWEEN 1 AND 5)
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "idx_reviews_property_id" ON "reviews" ("property_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "idx_reviews_student_id" ON "reviews" ("student_id")
    `);
    // One live review per student per property.
    await queryRunner.query(`
      CREATE UNIQUE INDEX "uq_reviews_property_student"
        ON "reviews" ("property_id", "student_id")
        WHERE "deleted_at" IS NULL
    `);

    await queryRunner.query(`
      CREATE TRIGGER "trg_reviews_updated_at"
        BEFORE UPDATE ON "reviews"
        FOR EACH ROW EXECUTE FUNCTION set_updated_at()
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP TRIGGER IF EXISTS "trg_reviews_updated_at" ON "reviews"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "reviews"`);
  }
}
