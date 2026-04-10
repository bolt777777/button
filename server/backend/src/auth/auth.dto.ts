import { IsEmail, IsString, MinLength, IsOptional, IsIn } from 'class-validator';

export class LoginDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(4)
  password: string;
}

export class RegisterAdminDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(6)
  password: string;

  @IsString()
  orgName: string;

  @IsOptional()
  @IsIn(['admin', 'operator'])
  role?: 'admin' | 'operator';
}
