import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OtpCode } from './entities/otp-code.entity';
import { RefreshToken } from './entities/refresh-token.entity';
import { UsersModule } from '../users/users.module';

// Skeleton: entities registered, OTP/JWT flow lands in the next step.
@Module({
  imports: [TypeOrmModule.forFeature([OtpCode, RefreshToken]), UsersModule],
  exports: [TypeOrmModule],
})
export class AuthModule {}
