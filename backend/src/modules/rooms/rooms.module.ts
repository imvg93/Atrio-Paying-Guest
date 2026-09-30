import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Room } from './entities/room.entity';

// Skeleton: entity registered, controller/service land in the next step.
@Module({
  imports: [TypeOrmModule.forFeature([Room])],
  exports: [TypeOrmModule],
})
export class RoomsModule {}
