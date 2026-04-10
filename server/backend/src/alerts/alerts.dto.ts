import { IsNumber, IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateAlertDto {
  @IsNumber()
  latitude: number;

  @IsNumber()
  longitude: number;

  @IsOptional()
  @IsNumber()
  accuracyMeters?: number;

  @IsOptional()
  @IsString()
  clientRequestId?: string;
}

export class AssignGuardDto {
  @IsUUID()
  guardId: string;
}
