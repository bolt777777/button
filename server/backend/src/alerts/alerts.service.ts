import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateAlertDto, AssignGuardDto } from './alerts.dto';
import { TrackingGateway } from '../tracking/tracking.gateway';

@Injectable()
export class AlertsService {
  constructor(
    private prisma: PrismaService,
    private tracking: TrackingGateway,
  ) {}

  async createSos(dto: CreateAlertDto, userId: string, orgId: string) {
    const alert = await this.prisma.sosAlert.create({
      data: {
        userId,
        orgId,
        lat: dto.latitude,
        lng: dto.longitude,
        accuracy: dto.accuracyMeters,
        status: 'new_alert',
      },
      include: { user: { select: { name: true, phone: true } } },
    });

    this.tracking.emitToOrg(orgId, 'new-alert', alert);

    // Auto-assign nearest available guard
    const guards = await this.prisma.guard.findMany({
      where: { orgId, status: 'available' },
    });

    let assignedGuard: {
      id: string;
      name: string;
      lat: number | null;
      lng: number | null;
    } | null = null;

    if (guards.length > 0) {
      let nearest = guards[0];
      let minDist = Infinity;
      for (const g of guards) {
        const dlat = (g.currentLat ?? 0) - dto.latitude;
        const dlng = (g.currentLng ?? 0) - dto.longitude;
        const d = dlat * dlat + dlng * dlng;
        if (d < minDist) {
          minDist = d;
          nearest = g;
        }
      }

      const updated = await this.prisma.sosAlert.update({
        where: { id: alert.id },
        data: { assignedGuardId: nearest.id, status: 'assigned' },
        include: {
          user: { select: { id: true, name: true, phone: true } },
          guard: {
            select: {
              id: true,
              name: true,
              currentLat: true,
              currentLng: true,
            },
          },
        },
      });

      await this.prisma.guard.update({
        where: { id: nearest.id },
        data: { status: 'busy' },
      });

      // Place guard ~1km away — arrives in ~60s
      const angle = Math.random() * 2 * Math.PI;
      const offsetLat = Math.cos(angle) * 0.01;
      const offsetLng = Math.sin(angle) * 0.01;
      const startLat = dto.latitude + offsetLat;
      const startLng = dto.longitude + offsetLng;

      await this.prisma.guard.update({
        where: { id: nearest.id },
        data: { currentLat: startLat, currentLng: startLng },
      });

      assignedGuard = {
        id: nearest.id,
        name: nearest.name,
        lat: startLat,
        lng: startLng,
      };

      this.tracking.emitToOrg(orgId, 'alert-assigned', updated);
    }

    return {
      incidentId: alert.id,
      status: assignedGuard ? 'assigned' : 'new_alert',
      guard: assignedGuard,
    };
  }

  async list(orgId: string, status?: string) {
    const where: any = { orgId };
    if (status) where.status = status;
    return this.prisma.sosAlert.findMany({
      where,
      include: {
        user: { select: { id: true, name: true, phone: true } },
        guard: { select: { id: true, name: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
  }

  async assign(alertId: string, dto: AssignGuardDto, orgId: string) {
    const alert = await this.prisma.sosAlert.findFirst({
      where: { id: alertId, orgId },
    });
    if (!alert) throw new NotFoundException('Alert not found');

    const updated = await this.prisma.sosAlert.update({
      where: { id: alertId },
      data: { assignedGuardId: dto.guardId, status: 'assigned' },
      include: {
        user: { select: { id: true, name: true, phone: true } },
        guard: {
          select: {
            id: true,
            name: true,
            currentLat: true,
            currentLng: true,
          },
        },
      },
    });

    await this.prisma.guard.update({
      where: { id: dto.guardId },
      data: { status: 'busy' },
    });

    this.tracking.emitToOrg(orgId, 'alert-assigned', updated);
    return updated;
  }

  async resolve(alertId: string, orgId: string) {
    const alert = await this.prisma.sosAlert.findFirst({
      where: { id: alertId, orgId },
    });
    if (!alert) throw new NotFoundException('Alert not found');

    const updated = await this.prisma.sosAlert.update({
      where: { id: alertId },
      data: { status: 'resolved', resolvedAt: new Date() },
    });

    if (alert.assignedGuardId) {
      await this.prisma.guard.update({
        where: { id: alert.assignedGuardId },
        data: { status: 'available' },
      });
    }

    this.tracking.emitToOrg(orgId, 'alert-resolved', updated);
    return updated;
  }
}
