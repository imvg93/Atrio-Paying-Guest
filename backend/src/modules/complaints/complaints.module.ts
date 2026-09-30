import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Complaint } from './entities/complaint.entity';

// Skeleton: entity registered now (table exists in Phase 1), UI + endpoints in
// Phase 2 per CLAUDE.md §8.
@Module({
  imports: [TypeOrmModule.forFeature([Complaint])],
  exports: [TypeOrmModule],
})
export class ComplaintsModule {}
