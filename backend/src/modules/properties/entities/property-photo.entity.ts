import { Column, Entity, Index, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { Property } from './property.entity';

@Entity('property_photos')
@Index('idx_property_photos_property_id', ['propertyId'])
export class PropertyPhoto extends BaseEntity {
  @Column({ name: 'property_id', type: 'uuid' })
  propertyId!: string;

  @Column({ name: 'url', type: 'varchar', length: 1024 })
  url!: string;

  @Column({ name: 'sort_order', type: 'int', default: 0 })
  sortOrder!: number;

  @Column({ name: 'caption', type: 'varchar', length: 255, nullable: true })
  caption!: string | null;

  @ManyToOne(() => Property, (property) => property.photos, {
    onDelete: 'RESTRICT',
  })
  @JoinColumn({ name: 'property_id' })
  property!: Property;
}
