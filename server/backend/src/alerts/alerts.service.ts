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
    return { incidentId: alert.id, status: alert.status };
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
          select: { id: true, name: true, currentLat: true, currentLng: true },
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
