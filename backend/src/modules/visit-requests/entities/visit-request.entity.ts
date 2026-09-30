import { Column, Entity, Index, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { Property } from '../../properties/entities/property.entity';
import { User } from '../../users/entities/user.entity';
import { VisitRequestStatus, VisitSlot } from '../enums/visit-request.enums';

@Entity('visit_requests')
@Index('idx_visit_requests_property_id', ['propertyId'])
@Index('idx_visit_requests_student_id', ['studentId'])
@Index('idx_visit_requests_status', ['status'])
export class VisitRequest extends BaseEntity {
  @Column({ name: 'property_id', type: 'uuid' })
  propertyId!: string;

  @Column({ name: 'student_id', type: 'uuid' })
  studentId!: string;

  @Column({ name: 'preferred_date', type: 'date' })
  preferredDate!: string;

  @Column({
    name: 'preferred_slot',
    type: 'enum',
    enum: VisitSlot,
    enumName: 'visit_requests_preferred_slot_enum',
  })
  preferredSlot!: VisitSlot;

  @Column({ name: 'message', type: 'text', nullable: true })
  message!: string | null;

  @Column({
    name: 'status',
    type: 'enum',
    enum: VisitRequestStatus,
    enumName: 'visit_requests_status_enum',
    default: VisitRequestStatus.PENDING,
  })
  status!: VisitRequestStatus;

  @Column({ name: 'responded_at', type: 'timestamptz', nullable: true })
  respondedAt!: Date | null;

  // --- relations ---

  @ManyToOne(() => Property, (property) => property.visitRequests, {
    onDelete: 'RESTRICT',
  })
  @JoinColumn({ name: 'property_id' })
  property!: Property;

  @ManyToOne(() => User, (user) => user.visitRequests, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'student_id' })
  student!: User;
}
