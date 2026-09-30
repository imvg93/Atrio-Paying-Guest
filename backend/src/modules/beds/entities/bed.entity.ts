import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
} from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { Room } from '../../rooms/entities/room.entity';
import { Occupancy } from '../../occupancies/entities/occupancy.entity';
import { BedStatus } from '../enums/bed.enums';

/**
 * The unit that actually gets rented (CLAUDE.md §4). Beds are auto-created from
 * a room's sharing_type.
 */
@Entity('beds')
@Index('idx_beds_room_id', ['roomId'])
@Index('idx_beds_status', ['status'])
export class Bed extends BaseEntity {
  @Column({ name: 'room_id', type: 'uuid' })
  roomId!: string;

  /** e.g. "A", "B". Unique per room among non-deleted beds. */
  @Column({ name: 'label', type: 'varchar', length: 20 })
  label!: string;

  @Column({
    name: 'status',
    type: 'enum',
    enum: BedStatus,
    enumName: 'beds_status_enum',
    default: BedStatus.AVAILABLE,
  })
  status!: BedStatus;

  // --- relations ---

  @ManyToOne(() => Room, (room) => room.beds, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'room_id' })
  room!: Room;

  @OneToMany(() => Occupancy, (occupancy) => occupancy.bed)
  occupancies!: Occupancy[];
}
