import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { OrganizationsModule } from './organizations/organizations.module';
import { UsersModule } from './users/users.module';
import { AlertsModule } from './alerts/alerts.module';
import { TrackingModule } from './tracking/tracking.module';

@Module({
  imports: [
    PrismaModule,
    AuthModule,
    OrganizationsModule,
    UsersModule,
    AlertsModule,
    TrackingModule,
  ],
})
export class AppModule {}
