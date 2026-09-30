import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateRefreshTokens1784500003000 implements MigrationInterface {
  name = 'CreateRefreshTokens1784500003000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
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
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "idx_refresh_tokens_user_id" ON "refresh_tokens" ("user_id")
    `);
    await queryRunner.query(`
      CREATE INDEX "idx_refresh_tokens_expires_at"
        ON "refresh_tokens" ("expires_at")
    `);
    // Token lookup on refresh is by hash.
    await queryRunner.query(`
      CREATE UNIQUE INDEX "uq_refresh_tokens_token_hash"
        ON "refresh_tokens" ("token_hash") WHERE "deleted_at" IS NULL
    `);

    await queryRunner.query(`
      CREATE TRIGGER "trg_refresh_tokens_updated_at"
        BEFORE UPDATE ON "refresh_tokens"
        FOR EACH ROW EXECUTE FUNCTION set_updated_at()
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP TRIGGER IF EXISTS "trg_refresh_tokens_updated_at" ON "refresh_tokens"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "refresh_tokens"`);
  }
}
