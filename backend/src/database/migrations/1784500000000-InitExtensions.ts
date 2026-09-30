import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Bootstrap migration: extensions + the shared updated_at trigger function.
 *
 * TypeORM's @UpdateDateColumn only fires for writes that go through the ORM.
 * This trigger guarantees updated_at is correct for raw SQL and manual DB
 * edits too, which is what CLAUDE.md §3.3 ("auto-managed") requires.
 */
export class InitExtensions1784500000000 implements MigrationInterface {
  name = 'InitExtensions1784500000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS "pgcrypto"`);

    await queryRunner.query(`
      CREATE OR REPLACE FUNCTION set_updated_at()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.updated_at = now();
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP FUNCTION IF EXISTS set_updated_at()`);
    // pgcrypto is intentionally left installed — other schemas may rely on it.
  }
}
