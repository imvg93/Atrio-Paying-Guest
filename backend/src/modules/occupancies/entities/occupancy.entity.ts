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
import { Bed } from '../../beds/entities/bed.entity';
import { User } from '../../users/entities/user.entity';
import { Complaint } from '../../complaints/entities/complaint.entity';
import { OccupancyStatus } from '../enums/occupancy.enums';

/**
 * The contract record: a student occupying a bed for a period.
 *
 * History is sacred (CLAUDE.md §3.5 and §4). An occupancy is opened with a
 * start_date and closed with an end_date — it is never rewritten to represent a
 * different tenancy, and never hard-deleted. Phase 3 `payments` will FK here.
 */
@Entity('occupancies')
@Index('idx_occupancies_bed_id', ['bedId'])
@Index('idx_occupancies_student_id', ['studentId'])
@Index('idx_occupancies_status', ['status'])
export class Occupancy extends BaseEntity {
  @Column({ name: 'bed_id', type: 'uuid' })
  bedId!: string;

  @Column({ name: 'student_id', type: 'uuid' })
  studentId!: string;

  @Column({ name: 'start_date', type: 'date' })
  startDate!: string;

  /** null = ongoing. */
  @Column({ name: 'end_date', type: 'date', nullable: true })
  endDate!: string | null;

  /** Locked at move-in; the room's rent may change later. */
  @Column({
    name: 'rent_paise',
    type: 'bigint',
    transformer: bigintTransformer,
  })
  rentPaise!: number;

  @Column({
    name: 'deposit_paise',
    type: 'bigint',
    transformer: bigintTransformer,
  })
  depositPaise!: number;

  @Column({
    name: 'status',
    type: 'enum',
    enum: OccupancyStatus,
    enumName: 'occupancies_status_enum',
    default: OccupancyStatus.ACTIVE,
  })
  status!: OccupancyStatus;

  // --- relations ---

  @ManyToOne(() => Bed, (bed) => bed.occupancies, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'bed_id' })
  bed!: Bed;

  @ManyToOne(() => User, (user) => user.occupancies, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'student_id' })
  student!: User;

  @OneToMany(() => Complaint, (complaint) => complaint.occupancy)
  complaints!: Complaint[];
}
