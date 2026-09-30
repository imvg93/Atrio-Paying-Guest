import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateUsers1784500001000 implements MigrationInterface {
  name = 'CreateUsers1784500001000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TYPE "users_role_enum" AS ENUM ('student', 'owner', 'admin')
    `);
    await queryRunner.query(`
      CREATE TYPE "users_gender_enum" AS ENUM ('male', 'female', 'other')
    `);

    await queryRunner.query(`
      CREATE TABLE "users" (
        "id"            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        "phone"         varchar(15) NOT NULL,
        "name"          varchar(255),
        "email"         varchar(255),
        "role"          "users_role_enum" NOT NULL DEFAULT 'student',
        "gender"        "users_gender_enum",
        "avatar_url"    varchar(512),
        "is_active"     boolean NOT NULL DEFAULT true,
        "last_login_at" timestamptz,
        "created_at"    timestamptz NOT NULL DEFAULT now(),
        "updated_at"    timestamptz NOT NULL DEFAULT now(),
        "deleted_at"    timestamptz
      )
    `);

    // Uniqueness is soft-delete aware: a deleted row must not block re-signup.
    await queryRunner.query(`
      CREATE UNIQUE INDEX "uq_users_phone"
        ON "users" ("phone") WHERE "deleted_at" IS NULL
    `);
    await queryRunner.query(`
      CREATE UNIQUE INDEX "uq_users_email"
        ON "users" (lower("email"))
        WHERE "deleted_at" IS NULL AND "email" IS NOT NULL
    `);
    await queryRunner.query(`
      CREATE INDEX "idx_users_role" ON "users" ("role")
    `);

    await queryRunner.query(`
      CREATE TRIGGER "trg_users_updated_at"
        BEFORE UPDATE ON "users"
        FOR EACH ROW EXECUTE FUNCTION set_updated_at()
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DROP TRIGGER IF EXISTS "trg_users_updated_at" ON "users"`,
    );
    await queryRunner.query(`DROP TABLE IF EXISTS "users"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "users_gender_enum"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "users_role_enum"`);
  }
}
