import { Check, Column, Entity, Index, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { Property } from '../../properties/entities/property.entity';
import { User } from '../../users/entities/user.entity';

@Entity('reviews')
@Index('idx_reviews_property_id', ['propertyId'])
@Index('idx_reviews_student_id', ['studentId'])
@Check('chk_reviews_rating_range', '"rating" BETWEEN 1 AND 5')
export class Review extends BaseEntity {
  @Column({ name: 'property_id', type: 'uuid' })
  propertyId!: string;

  /** One live review per student per property (partial unique index). */
  @Column({ name: 'student_id', type: 'uuid' })
  studentId!: string;

  @Column({ name: 'rating', type: 'int' })
  rating!: number;

  @Column({ name: 'comment', type: 'text', nullable: true })
  comment!: string | null;

  // --- relations ---

  @ManyToOne(() => Property, (property) => property.reviews, {
    onDelete: 'RESTRICT',
  })
  @JoinColumn({ name: 'property_id' })
  property!: Property;

  @ManyToOne(() => User, (user) => user.reviews, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'student_id' })
  student!: User;
}
