import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { TrackingGateway } from './tracking.gateway';

@Injectable()
export class SimulatorService implements OnModuleInit, OnModuleDestroy {
  private interval: ReturnType<typeof setInterval> | null = null;

  constructor(
    private prisma: PrismaService,
    private tracking: TrackingGateway,
  ) {}

  onModuleInit() {
    this.interval = setInterval(() => this.tick(), 3000);
    console.log('Guard GPS simulator started (3s interval)');
  }

  onModuleDestroy() {
    if (this.interval) clearInterval(this.interval);
  }

  private async tick() {
    const guards = await this.prisma.guard.findMany({
      where: { status: 'available' },
    });

    for (const guard of guards) {
      const lat = (guard.currentLat ?? 55.751) + (Math.random() - 0.5) * 0.002;
      const lng = (guard.currentLng ?? 37.618) + (Math.random() - 0.5) * 0.002;

      await this.prisma.guard.update({
        where: { id: guard.id },
        data: { currentLat: lat, currentLng: lng, lastLocationAt: new Date() },
      });

      this.tracking.emitToOrg(guard.orgId, 'guard-location', {
        guardId: guard.id,
        name: guard.name,
        lat,
        lng,
        status: guard.status,
        ts: Date.now(),
      });
    }
  }
}
