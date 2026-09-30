import { DataSourceOptions } from 'typeorm';

/**
 * Single source of truth for TypeORM connection options.
 * Consumed by both the Nest runtime (DatabaseModule) and the TypeORM CLI
 * (data-source.ts), so migrations always run against the same shape.
 *
 * `synchronize` is hardcoded false — see CLAUDE.md §3.4. Schema changes are
 * versioned migrations only.
 */
export const buildDataSourceOptions = (
  env: NodeJS.ProcessEnv = process.env,
): DataSourceOptions => ({
  type: 'postgres',
  host: env.DB_HOST ?? 'localhost',
  port: parseInt(env.DB_PORT ?? '5432', 10),
  username: env.DB_USERNAME ?? 'postgres',
  password: env.DB_PASSWORD ?? 'postgres',
  database: env.DB_NAME ?? 'atrio_pg',
  ssl:
    (env.DB_SSL ?? 'false').toLowerCase() === 'true'
      ? { rejectUnauthorized: false }
      : false,
  synchronize: false,
  migrationsRun: false,
  logging: (env.DB_LOGGING ?? 'false').toLowerCase() === 'true',
  entities: [__dirname + '/../modules/**/*.entity{.ts,.js}'],
  migrations: [__dirname + '/migrations/*{.ts,.js}'],
  migrationsTableName: 'migrations',
});
