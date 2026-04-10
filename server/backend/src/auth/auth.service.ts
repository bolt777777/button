import {
  Injectable,
  UnauthorizedException,
  ForbiddenException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto, RegisterAdminDto } from './auth.dto';
import { JwtPayload } from '../common/current-user.decorator';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwt: JwtService,
  ) {}

  async login(dto: LoginDto) {
    // Try admin accounts first
    const admin = await this.prisma.adminAccount.findUnique({
      where: { email: dto.email },
    });
    if (admin) {
      const valid = await bcrypt.compare(dto.password, admin.passwordHash);
      if (!valid) throw new UnauthorizedException('Invalid credentials');
      return this.signToken({
        sub: admin.id,
        email: admin.email,
        role: admin.role,
        orgId: admin.orgId,
        userType: 'admin',
      });
    }

    // Try user accounts
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });
    if (user) {
      const valid = await bcrypt.compare(dto.password, user.passwordHash);
      if (!valid) throw new UnauthorizedException('Invalid credentials');
      return this.signToken({
        sub: user.id,
        email: user.email,
        role: 'user',
        orgId: user.orgId,
        userType: 'user',
      });
    }

    // Try guard accounts
    const guard = await this.prisma.guard.findUnique({
      where: { email: dto.email },
    });
    if (guard) {
      const valid = await bcrypt.compare(dto.password, guard.passwordHash);
      if (!valid) throw new UnauthorizedException('Invalid credentials');
      return this.signToken({
        sub: guard.id,
        email: guard.email,
        role: 'guard',
        orgId: guard.orgId,
        userType: 'guard',
      });
    }

    throw new UnauthorizedException('Invalid credentials');
  }

  async registerAdmin(dto: RegisterAdminDto, caller: JwtPayload) {
    if (caller.role !== 'superadmin') {
      throw new ForbiddenException('Only superadmin can create admins');
    }

    const hash = await bcrypt.hash(dto.password, 10);
    const org = await this.prisma.organization.create({
      data: { name: dto.orgName },
    });
    const admin = await this.prisma.adminAccount.create({
      data: {
        email: dto.email,
        passwordHash: hash,
        role: dto.role || 'admin',
        orgId: org.id,
      },
    });
    return { id: admin.id, email: admin.email, orgId: org.id };
  }

  private signToken(payload: JwtPayload) {
    return {
      accessToken: this.jwt.sign(payload, { expiresIn: '24h' }),
      user: {
        id: payload.sub,
        email: payload.email,
        role: payload.role,
        orgId: payload.orgId,
        userType: payload.userType,
      },
    };
  }
}
