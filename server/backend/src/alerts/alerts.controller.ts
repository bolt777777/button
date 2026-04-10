import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AlertsService } from './alerts.service';
import { CreateAlertDto, AssignGuardDto } from './alerts.dto';
import { CurrentUser, JwtPayload } from '../common/current-user.decorator';
import { Roles } from '../common/roles.decorator';
import { RolesGuard } from '../common/roles.guard';

@Controller('alerts')
@UseGuards(AuthGuard('jwt'), RolesGuard)
export class AlertsController {
  constructor(private alertsService: AlertsService) {}

  @Post('sos')
  @Roles('user')
  createSos(@Body() dto: CreateAlertDto, @CurrentUser() user: JwtPayload) {
    return this.alertsService.createSos(dto, user.sub, user.orgId);
  }

  @Get()
  @Roles('admin', 'superadmin', 'operator')
  list(@CurrentUser() user: JwtPayload, @Query('status') status?: string) {
    return this.alertsService.list(user.orgId, status);
  }

  @Patch(':id/assign')
  @Roles('admin', 'superadmin', 'operator')
  assign(
    @Param('id') id: string,
    @Body() dto: AssignGuardDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.alertsService.assign(id, dto, user.orgId);
  }

  @Patch(':id/resolve')
  @Roles('admin', 'superadmin', 'operator')
  resolve(@Param('id') id: string, @CurrentUser() user: JwtPayload) {
    return this.alertsService.resolve(id, user.orgId);
  }
}
