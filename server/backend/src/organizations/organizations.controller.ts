import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { PrismaService } from '../prisma/prisma.service';
import { CurrentUser, JwtPayload } from '../common/current-user.decorator';

@Controller('organizations')
@UseGuards(AuthGuard('jwt'))
export class OrganizationsController {
  constructor(private prisma: PrismaService) {}

  @Get('mine')
  async getMine(@CurrentUser() user: JwtPayload) {
    return this.prisma.organization.findUnique({
      where: { id: user.orgId },
    });
  }

  @Get(':id')
  async getById(@Param('id') id: string, @CurrentUser() user: JwtPayload) {
    if (user.role !== 'superadmin' && user.orgId !== id) {
      return null;
    }
    return this.prisma.organization.findUnique({ where: { id } });
  }
}
