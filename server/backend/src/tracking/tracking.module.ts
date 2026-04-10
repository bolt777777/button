import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { TrackingGateway } from './tracking.gateway';
import { SimulatorService } from './simulator.service';

@Module({
  imports: [
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'dev-jwt-secret-change-in-prod',
    }),
  ],
  providers: [TrackingGateway, SimulatorService],
  exports: [TrackingGateway],
})
export class TrackingModule {}
