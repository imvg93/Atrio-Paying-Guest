import 'reflect-metadata';
import * as dotenv from 'dotenv';
import { DataSource } from 'typeorm';
import { buildDataSourceOptions } from './typeorm.config';

// The TypeORM CLI runs outside the Nest DI container, so load .env manually.
dotenv.config();

export default new DataSource(buildDataSourceOptions());
