import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Property } from './entities/property.entity';
import { PropertyPhoto } from './entities/property-photo.entity';

// Skeleton: entities registered, controller/service land in the next step.
@Module({
  imports: [TypeOrmModule.forFeature([Property, PropertyPhoto])],
  exports: [TypeOrmModule],
})
export class PropertiesModule {}
