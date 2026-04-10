import { IsEmail, IsString, MinLength, IsOptional, IsIn } from 'class-validator';

export class CreateUserDto {
  @IsString()
  name: string;

  @IsEmail()
  email: string;

  @IsString()
  @MinLength(4)
  password: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsIn(['user', 'guard'])
  type: 'user' | 'guard';
}
