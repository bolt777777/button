import {
  Controller,
  Get,
  Post,
  Body,
  UseGuards,
  Param,
  Patch,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { CurrentUser, JwtPayload } from '../common/current-user.decorator';
import { Roles } from '../common/roles.decorator';
import { RolesGuard } from '../common/roles.guard';
import { CreateUserDto } from './users.dto';

@Controller('users')
@UseGuards(AuthGuard('jwt'), RolesGuard)
export class UsersController {
  constructor(private prisma: PrismaService) {}

  @Post()
  @Roles('admin', 'superadmin')
  async create(@Body() dto: CreateUserDto, @CurrentUser() me: JwtPayload) {
    const hash = await bcrypt.hash(dto.password, 10);
    if (dto.type === 'guard') {
      const g = await this.prisma.guard.create({
        data: {
          name: dto.name,
          email: dto.email,
          passwordHash: hash,
          phone: dto.phone || '',
          orgId: me.orgId,
        },
      });
      return { id: g.id, type: 'guard', email: g.email };
    }
    const u = await this.prisma.user.create({
      data: {
        name: dto.name,
        email: dto.email,
        passwordHash: hash,
        phone: dto.phone || '',
        orgId: me.orgId,
      },
    });
    return { id: u.id, type: 'user', email: u.email };
  }

  @Get()
  @Roles('admin', 'superadmin', 'operator')
  async list(@CurrentUser() me: JwtPayload) {
    const [users, guards] = await Promise.all([
      this.prisma.user.findMany({
        where: { orgId: me.orgId },
        select: {
          id: true,
          name: true,
          email: true,
          phone: true,
          isOnline: true,
          lastLat: true,
          lastLng: true,
        },
      }),
      this.prisma.guard.findMany({
        where: { orgId: me.orgId },
        select: {
          id: true,
          name: true,
          email: true,
          phone: true,
          status: true,
          currentLat: true,
          currentLng: true,
        },
      }),
    ]);
    return { users, guards };
  }

  @Get('guards')
  @Roles('admin', 'superadmin', 'operator')
  async listGuards(@CurrentUser() me: JwtPayload) {
    return this.prisma.guard.findMany({
      where: { orgId: me.orgId },
      select: {
        id: true,
        name: true,
        email: true,
        status: true,
        currentLat: true,
        currentLng: true,
      },
    });
  }

  @Patch('guards/:id/status')
  @Roles('admin', 'superadmin', 'operator')
  async updateGuardStatus(
    @Param('id') id: string,
    @Body('status') status: 'available' | 'busy' | 'offline',
    @CurrentUser() me: JwtPayload,
  ) {
    return this.prisma.guard.updateMany({
      where: { id, orgId: me.orgId },
      data: { status },
    });
  }
}
