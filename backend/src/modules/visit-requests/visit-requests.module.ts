import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VisitRequest } from './entities/visit-request.entity';

// Skeleton: entity registered, controller/service land in the next step.
@Module({
  imports: [TypeOrmModule.forFeature([VisitRequest])],
  exports: [TypeOrmModule],
})
export class VisitRequestsModule {}
