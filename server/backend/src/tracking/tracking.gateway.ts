import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { JwtService } from '@nestjs/jwt';
import { Injectable } from '@nestjs/common';

@Injectable()
@WebSocketGateway({ cors: { origin: '*' } })
export class TrackingGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  private connectedClients = new Map<string, { orgId: string; role: string }>();

  constructor(private jwt: JwtService) {}

  async handleConnection(client: Socket) {
    try {
      const token =
        (client.handshake.auth?.token as string) ||
        client.handshake.headers.authorization?.replace('Bearer ', '');
      if (!token) {
        client.disconnect();
        return;
      }
      const payload = this.jwt.verify(token);
      this.connectedClients.set(client.id, {
        orgId: payload.orgId,
        role: payload.role,
      });
      await client.join(`org:${payload.orgId}`);
      console.log(
        `WS connected: ${client.id} (${payload.role}, org=${payload.orgId})`,
      );
    } catch {
      client.disconnect();
    }
  }

  handleDisconnect(client: Socket) {
    this.connectedClients.delete(client.id);
  }

  @SubscribeMessage('ping')
  handlePing() {
    return { event: 'pong', data: { ts: Date.now() } };
  }

  emitToOrg(orgId: string, event: string, data: any) {
    this.server?.to(`org:${orgId}`).emit(event, data);
  }
}
