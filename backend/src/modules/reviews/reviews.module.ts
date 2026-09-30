import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Review } from './entities/review.entity';

// Skeleton: entity registered now (table exists in Phase 1), UI + endpoints in
// Phase 2 per CLAUDE.md §8.
@Module({
  imports: [TypeOrmModule.forFeature([Review])],
  exports: [TypeOrmModule],
})
export class ReviewsModule {}
