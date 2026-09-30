import { Column, Entity, Index } from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';

@Entity('otp_codes')
@Index('idx_otp_codes_phone', ['phone'])
@Index('idx_otp_codes_expires_at', ['expiresAt'])
export class OtpCode extends BaseEntity {
  @Column({ name: 'phone', type: 'varchar', length: 15 })
  phone!: string;

  /** Hashed OTP. Plaintext codes are never persisted. */
  @Column({ name: 'code_hash', type: 'varchar', length: 255 })
  codeHash!: string;

  @Column({ name: 'expires_at', type: 'timestamptz' })
  expiresAt!: Date;

  @Column({ name: 'attempts', type: 'int', default: 0 })
  attempts!: number;

  @Column({ name: 'consumed_at', type: 'timestamptz', nullable: true })
  consumedAt!: Date | null;
}
