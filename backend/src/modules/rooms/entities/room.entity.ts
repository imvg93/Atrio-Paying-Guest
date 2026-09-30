import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
} from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { bigintTransformer } from '../../../common/transformers/numeric.transformer';
import { Property } from '../../properties/entities/property.entity';
import { Bed } from '../../beds/entities/bed.entity';
import { SharingType } from '../enums/room.enums';

@Entity('rooms')
@Index('idx_rooms_property_id', ['propertyId'])
@Index('idx_rooms_sharing_type', ['sharingType'])
export class Room extends BaseEntity {
  @Column({ name: 'property_id', type: 'uuid' })
  propertyId!: string;

  /** Unique per property among non-deleted rooms. */
  @Column({ name: 'room_number', type: 'varchar', length: 50 })
  roomNumber!: string;

  @Column({ name: 'floor', type: 'int', nullable: true })
  floor!: number | null;

  @Column({
    name: 'sharing_type',
    type: 'enum',
    enum: SharingType,
    enumName: 'rooms_sharing_type_enum',
  })
  sharingType!: SharingType;

  @Column({
    name: 'rent_per_bed_paise',
    type: 'bigint',
    transformer: bigintTransformer,
  })
  rentPerBedPaise!: number;

  @Column({
    name: 'deposit_paise',
    type: 'bigint',
    transformer: bigintTransformer,
  })
  depositPaise!: number;

  @Column({ name: 'has_attached_bathroom', type: 'boolean', default: false })
  hasAttachedBathroom!: boolean;

  @Column({ name: 'has_ac', type: 'boolean', default: false })
  hasAc!: boolean;

  // --- relations ---

  @ManyToOne(() => Property, (property) => property.rooms, {
    onDelete: 'RESTRICT',
  })
  @JoinColumn({ name: 'property_id' })
  property!: Property;

  @OneToMany(() => Bed, (bed) => bed.room)
  beds!: Bed[];
}
