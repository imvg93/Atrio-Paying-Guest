import { Column, Entity, Index, OneToMany } from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { Gender, UserRole } from '../enums/user.enums';
import { Property } from '../../properties/entities/property.entity';
import { Occupancy } from '../../occupancies/entities/occupancy.entity';
import { VisitRequest } from '../../visit-requests/entities/visit-request.entity';
import { Review } from '../../reviews/entities/review.entity';
import { RefreshToken } from '../../auth/entities/refresh-token.entity';

@Entity('users')
@Index('idx_users_role', ['role'])
export class User extends BaseEntity {
  /** E.164, e.g. +919876543210. Login identifier. */
  @Column({ name: 'phone', type: 'varchar', length: 15 })
  phone!: string;

  @Column({ name: 'name', type: 'varchar', length: 255, nullable: true })
  name!: string | null;

  @Column({ name: 'email', type: 'varchar', length: 255, nullable: true })
  email!: string | null;

  @Column({
    name: 'role',
    type: 'enum',
    enum: UserRole,
    enumName: 'users_role_enum',
    default: UserRole.STUDENT,
  })
  role!: UserRole;

  @Column({
    name: 'gender',
    type: 'enum',
    enum: Gender,
    enumName: 'users_gender_enum',
    nullable: true,
  })
  gender!: Gender | null;

  @Column({ name: 'avatar_url', type: 'varchar', length: 512, nullable: true })
  avatarUrl!: string | null;

  @Column({ name: 'is_active', type: 'boolean', default: true })
  isActive!: boolean;

  @Column({ name: 'last_login_at', type: 'timestamptz', nullable: true })
  lastLoginAt!: Date | null;

  // --- relations ---

  @OneToMany(() => Property, (property) => property.owner)
  properties!: Property[];

  @OneToMany(() => Occupancy, (occupancy) => occupancy.student)
  occupancies!: Occupancy[];

  @OneToMany(() => VisitRequest, (visitRequest) => visitRequest.student)
  visitRequests!: VisitRequest[];

  @OneToMany(() => Review, (review) => review.student)
  reviews!: Review[];

  @OneToMany(() => RefreshToken, (token) => token.user)
  refreshTokens!: RefreshToken[];
}
