import { Column, Entity, Index, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { Occupancy } from '../../occupancies/entities/occupancy.entity';
import { ComplaintCategory, ComplaintStatus } from '../enums/complaint.enums';

@Entity('complaints')
@Index('idx_complaints_occupancy_id', ['occupancyId'])
@Index('idx_complaints_status', ['status'])
export class Complaint extends BaseEntity {
  /** Scoped to an occupancy — that's what ties a complaint to bed + property. */
  @Column({ name: 'occupancy_id', type: 'uuid' })
  occupancyId!: string;

  @Column({
    name: 'category',
    type: 'enum',
    enum: ComplaintCategory,
    enumName: 'complaints_category_enum',
  })
  category!: ComplaintCategory;

  @Column({ name: 'title', type: 'varchar', length: 255 })
  title!: string;

  @Column({ name: 'description', type: 'text' })
  description!: string;

  /** Array of URLs. */
  @Column({ name: 'photos', type: 'jsonb', nullable: true })
  photos!: string[] | null;

  @Column({
    name: 'status',
    type: 'enum',
    enum: ComplaintStatus,
    enumName: 'complaints_status_enum',
    default: ComplaintStatus.OPEN,
  })
  status!: ComplaintStatus;

  @Column({ name: 'resolved_at', type: 'timestamptz', nullable: true })
  resolvedAt!: Date | null;

  // --- relations ---

  @ManyToOne(() => Occupancy, (occupancy) => occupancy.complaints, {
    onDelete: 'RESTRICT',
  })
  @JoinColumn({ name: 'occupancy_id' })
  occupancy!: Occupancy;
}
