import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Bed } from './entities/bed.entity';

// Skeleton: entity registered, controller/service land in the next step.
@Module({
  imports: [TypeOrmModule.forFeature([Bed])],
  exports: [TypeOrmModule],
})
export class BedsModule {}
