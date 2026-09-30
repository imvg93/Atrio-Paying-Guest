import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import configuration from './config/configuration';
import { envValidationSchema } from './config/env.validation';
import { DatabaseModule } from './database/database.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { PropertiesModule } from './modules/properties/properties.module';
import { RoomsModule } from './modules/rooms/rooms.module';
import { BedsModule } from './modules/beds/beds.module';
import { OccupanciesModule } from './modules/occupancies/occupancies.module';
import { VisitRequestsModule } from './modules/visit-requests/visit-requests.module';
import { ComplaintsModule } from './modules/complaints/complaints.module';
import { ReviewsModule } from './modules/reviews/reviews.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
      validationSchema: envValidationSchema,
      validationOptions: { abortEarly: false },
    }),
    DatabaseModule,
    // One module per domain — CLAUDE.md §3.14.
    AuthModule,
    UsersModule,
    PropertiesModule,
    RoomsModule,
    BedsModule,
    OccupanciesModule,
    VisitRequestsModule,
    ComplaintsModule,
    ReviewsModule,
  ],
})
export class AppModule {}
