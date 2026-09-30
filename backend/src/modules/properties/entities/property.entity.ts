import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
} from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import {
  bigintTransformer,
  decimalTransformer,
} from '../../../common/transformers/numeric.transformer';
import { User } from '../../users/entities/user.entity';
import { Room } from '../../rooms/entities/room.entity';
import { PropertyPhoto } from './property-photo.entity';
import { VisitRequest } from '../../visit-requests/entities/visit-request.entity';
import { Review } from '../../reviews/entities/review.entity';
import {
  PropertyAmenities,
  PropertyGenderType,
  PropertyRules,
  PropertyStatus,
} from '../enums/property.enums';

@Entity('properties')
@Index('idx_properties_owner_id', ['ownerId'])
@Index('idx_properties_city', ['city'])
@Index('idx_properties_locality', ['locality'])
@Index('idx_properties_status', ['status'])
@Index('idx_properties_lat_lng', ['latitude', 'longitude'])
export class Property extends BaseEntity {
  @Column({ name: 'owner_id', type: 'uuid' })
  ownerId!: string;

  @Column({ name: 'name', type: 'varchar', length: 255 })
  name!: string;

  @Column({ name: 'description', type: 'text', nullable: true })
  description!: string | null;

  @Column({
    name: 'gender_type',
    type: 'enum',
    enum: PropertyGenderType,
    enumName: 'properties_gender_type_enum',
  })
  genderType!: PropertyGenderType;

  @Column({ name: 'address_line', type: 'varchar', length: 512 })
  addressLine!: string;

  @Column({ name: 'locality', type: 'varchar', length: 255 })
  locality!: string;

  @Column({ name: 'city', type: 'varchar', length: 255 })
  city!: string;

  @Column({ name: 'state', type: 'varchar', length: 255 })
  state!: string;

  @Column({ name: 'pincode', type: 'varchar', length: 10 })
  pincode!: string;

  @Column({
    name: 'latitude',
    type: 'decimal',
    precision: 9,
    scale: 6,
    transformer: decimalTransformer,
  })
  latitude!: number;

  @Column({
    name: 'longitude',
    type: 'decimal',
    precision: 9,
    scale: 6,
    transformer: decimalTransformer,
  })
  longitude!: number;

  /** e.g. { "wifi": true, "food": true, "ac": false } */
  @Column({ name: 'amenities', type: 'jsonb', default: () => "'{}'::jsonb" })
  amenities!: PropertyAmenities;

  /** e.g. { "gateClosingTime": "22:30", "visitorsAllowed": false } */
  @Column({ name: 'rules', type: 'jsonb', nullable: true })
  rules!: PropertyRules | null;

  @Column({ name: 'food_included', type: 'boolean', default: false })
  foodIncluded!: boolean;

  @Column({ name: 'notice_period_days', type: 'int', default: 30 })
  noticePeriodDays!: number;

  @Column({
    name: 'status',
    type: 'enum',
    enum: PropertyStatus,
    enumName: 'properties_status_enum',
    default: PropertyStatus.DRAFT,
  })
  status!: PropertyStatus;

  /** Denormalized from rooms for search cards. Recomputed on room writes. */
  @Column({
    name: 'min_rent_paise',
    type: 'bigint',
    nullable: true,
    transformer: bigintTransformer,
  })
  minRentPaise!: number | null;

  @Column({
    name: 'max_rent_paise',
    type: 'bigint',
    nullable: true,
    transformer: bigintTransformer,
  })
  maxRentPaise!: number | null;

  // --- relations ---

  @ManyToOne(() => User, (user) => user.properties, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'owner_id' })
  owner!: User;

  @OneToMany(() => Room, (room) => room.property)
  rooms!: Room[];

  @OneToMany(() => PropertyPhoto, (photo) => photo.property)
  photos!: PropertyPhoto[];

  @OneToMany(() => VisitRequest, (visitRequest) => visitRequest.property)
  visitRequests!: VisitRequest[];

  @OneToMany(() => Review, (review) => review.property)
  reviews!: Review[];
}
