import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateOtpCodes1784500002000 implements MigrationInterface {
  name = 'CreateOtpCodes1784500002000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
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
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "idx_otp_codes_phone" ON "otp_codes" ("phone")
    `);
    await queryRunner.query(`
      CREATE INDEX "idx_otp_codes_expires_at" ON "otp_codes" ("expires_at")
    `);
    // Serves both the rate limiter (3 requests / phone / 10 min) and the
    // "latest live code for this phone" lookup during verify.
    await queryRunner.query(`
      CREATE INDEX "idx_otp_codes_phone_created_at"
        ON "otp_codes" ("phone", "created_at" DESC)
        WHERE "deleted_at" IS NULL
    `);

    await queryRunner.query(`
      CREATE TRIGGER "trg_otp_codes_updated_at"
        BEFORE UPDATE ON "otp_codes"
        FOR EACH ROW EXECUTE FUNCTION set_updated_at()
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP TRIGGER IF EXISTS "trg_otp_codes_updated_at" ON "otp_codes"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "otp_codes"`);
  }
}
