import { useState, useEffect } from 'react';
import { get } from '../api/http';
import { Socket } from 'socket.io-client';

export interface Guard {
  id: string;
  name: string;
  email: string;
  status: string;
  currentLat: number | null;
  currentLng: number | null;
}

export function useGuards(socket: Socket | null) {
  const [guards, setGuards] = useState<Guard[]>([]);

  useEffect(() => {
    get<Guard[]>('/users/guards').then(setGuards).catch(() => {});
  }, []);

  useEffect(() => {
    if (!socket) return;
    const onLocation = (data: {
      guardId: string;
      name: string;
      lat: number;
      lng: number;
      status: string;
    }) => {
      setGuards((prev) =>
        prev.map((g) =>
          g.id === data.guardId
            ? { ...g, currentLat: data.lat, currentLng: data.lng, status: data.status }
            : g,
        ),
      );
    };
    socket.on('guard-location', onLocation);
    return () => {
      socket.off('guard-location', onLocation);
    };
  }, [socket]);

  return guards;
}
