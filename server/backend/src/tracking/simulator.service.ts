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
      where: { status: { in: ['available', 'busy'] } },
      include: {
        alerts: {
          where: { status: 'assigned' },
          take: 1,
          select: { lat: true, lng: true },
        },
      },
    });

    for (const guard of guards) {
      let lat: number;
      let lng: number;

      if (guard.status === 'busy' && guard.alerts.length > 0) {
        const alert = guard.alerts[0];
        const curLat = guard.currentLat ?? 55.751;
        const curLng = guard.currentLng ?? 37.618;
        lat = curLat + (alert.lat - curLat) * 0.12;
        lng = curLng + (alert.lng - curLng) * 0.12;
      } else {
        lat =
          (guard.currentLat ?? 55.751) + (Math.random() - 0.5) * 0.002;
        lng =
          (guard.currentLng ?? 37.618) + (Math.random() - 0.5) * 0.002;
      }

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
