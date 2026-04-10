import { useState, useEffect, useCallback } from 'react';
import { get, patch } from '../api/http';
import { Socket } from 'socket.io-client';

export interface Alert {
  id: string;
  userId: string;
  orgId: string;
  assignedGuardId: string | null;
  status: string;
  lat: number;
  lng: number;
  accuracy: number | null;
  createdAt: string;
  resolvedAt: string | null;
  user: { id: string; name: string; phone: string };
  guard: { id: string; name: string } | null;
}

export function useAlerts(socket: Socket | null) {
  const [alerts, setAlerts] = useState<Alert[]>([]);

  const refresh = useCallback(async () => {
    try {
      const data = await get<Alert[]>('/alerts');
      setAlerts(data);
    } catch {}
  }, []);

  useEffect(() => {
    refresh();
  }, [refresh]);

  useEffect(() => {
    if (!socket) return;
    const onNew = (a: Alert) =>
      setAlerts((prev) => [a, ...prev.filter((x) => x.id !== a.id)]);
    const onAssigned = (a: Alert) =>
      setAlerts((prev) => prev.map((x) => (x.id === a.id ? a : x)));
    const onResolved = (a: Alert) =>
      setAlerts((prev) => prev.map((x) => (x.id === a.id ? a : x)));

    socket.on('new-alert', onNew);
    socket.on('alert-assigned', onAssigned);
    socket.on('alert-resolved', onResolved);
    return () => {
      socket.off('new-alert', onNew);
      socket.off('alert-assigned', onAssigned);
      socket.off('alert-resolved', onResolved);
    };
  }, [socket]);

  const assign = async (alertId: string, guardId: string) => {
    await patch(`/alerts/${alertId}/assign`, { guardId });
    refresh();
  };

  const resolve = async (alertId: string) => {
    await patch(`/alerts/${alertId}/resolve`);
    refresh();
  };

  return { alerts, assign, resolve, refresh };
}
