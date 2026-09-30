import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Occupancy } from './entities/occupancy.entity';

// Skeleton: entity registered now (table exists in Phase 1), UI + endpoints in
// Phase 2 per CLAUDE.md §8.
@Module({
  imports: [TypeOrmModule.forFeature([Occupancy])],
  exports: [TypeOrmModule],
})
export class OccupanciesModule {}
