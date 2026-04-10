import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AuthService } from './auth.service';
import { LoginDto, RegisterAdminDto } from './auth.dto';
import { CurrentUser, JwtPayload } from '../common/current-user.decorator';
import { Roles } from '../common/roles.decorator';
import { RolesGuard } from '../common/roles.guard';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('register')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles('superadmin')
  register(@Body() dto: RegisterAdminDto, @CurrentUser() user: JwtPayload) {
    return this.authService.registerAdmin(dto, user);
  }
}
