import { MapContainer, TileLayer, Marker, Popup, Polyline, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import type { Alert } from '../hooks/useAlerts';
import type { Guard } from '../hooks/useGuards';
import { useEffect } from 'react';

const sosIcon = L.divIcon({
  html: '<div style="width:18px;height:18px;background:#ef4444;border-radius:50%;border:3px solid #fff;box-shadow:0 0 12px #ef4444;animation:pulse 1s infinite"></div>',
  iconSize: [24, 24],
  iconAnchor: [12, 12],
  className: '',
});

const guardIcon = L.divIcon({
  html: '<div style="width:14px;height:14px;background:#22c55e;border-radius:50%;border:2px solid #fff;box-shadow:0 0 6px #22c55e"></div>',
  iconSize: [18, 18],
  iconAnchor: [9, 9],
  className: '',
});

const guardBusyIcon = L.divIcon({
  html: '<div style="width:14px;height:14px;background:#f59e0b;border-radius:50%;border:2px solid #fff;box-shadow:0 0 6px #f59e0b"></div>',
  iconSize: [18, 18],
  iconAnchor: [9, 9],
  className: '',
});

interface Props {
  alerts: Alert[];
  guards: Guard[];
  selectedAlert: Alert | null;
  onAssign: (alertId: string, guardId: string) => void;
}

function FitBounds({ alerts, guards }: { alerts: Alert[]; guards: Guard[] }) {
  const map = useMap();
  useEffect(() => {
    const pts: [number, number][] = [];
    alerts.forEach((a) => pts.push([a.lat, a.lng]));
    guards.forEach((g) => {
      if (g.currentLat && g.currentLng) pts.push([g.currentLat, g.currentLng]);
    });
    if (pts.length > 0) map.fitBounds(pts, { padding: [40, 40], maxZoom: 15 });
  }, []);
  return null;
}

export default function LiveMap({ alerts, guards, selectedAlert, onAssign }: Props) {
  const activeAlerts = alerts.filter(
    (a) => a.status === 'new_alert' || a.status === 'assigned',
  );

  const assignedGuard =
    selectedAlert?.assignedGuardId
      ? guards.find((g) => g.id === selectedAlert.assignedGuardId)
      : null;

  const routePoints: [number, number][] = [];
  if (selectedAlert && assignedGuard?.currentLat && assignedGuard?.currentLng) {
    routePoints.push(
      [assignedGuard.currentLat, assignedGuard.currentLng],
      [selectedAlert.lat, selectedAlert.lng],
    );
  }

  return (
    <MapContainer
      center={[55.751, 37.618]}
      zoom={13}
      style={{ width: '100%', height: '100%' }}
      attributionControl={false}
    >
      <TileLayer
        attribution=""
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
      <FitBounds alerts={activeAlerts} guards={guards} />

      {activeAlerts.map((a) => (
        <Marker key={a.id} position={[a.lat, a.lng]} icon={sosIcon}>
          <Popup>
            <strong>SOS: {a.user.name}</strong>
            <br />
            {a.user.phone}
            <br />
            Статус: {a.status}
          </Popup>
        </Marker>
      ))}

      {guards
        .filter((g) => g.currentLat && g.currentLng && g.status !== 'offline')
        .map((g) => (
          <Marker
            key={g.id}
            position={[g.currentLat!, g.currentLng!]}
            icon={g.status === 'busy' ? guardBusyIcon : guardIcon}
          >
            <Popup>
              <strong>{g.name}</strong>
              <br />
              Статус: {g.status === 'available' ? 'Свободен' : 'Занят'}
              {selectedAlert && selectedAlert.status === 'new_alert' && g.status === 'available' && (
                <>
                  <br />
                  <button
                    onClick={() => onAssign(selectedAlert.id, g.id)}
                    style={{
                      marginTop: 6,
                      padding: '4px 12px',
                      border: 'none',
                      borderRadius: 4,
                      background: '#3b82f6',
                      color: '#fff',
                      cursor: 'pointer',
                      fontWeight: 600,
                    }}
                  >
                    Назначить
                  </button>
                </>
              )}
            </Popup>
          </Marker>
        ))}

      {routePoints.length === 2 && (
        <Polyline
          positions={routePoints}
          pathOptions={{ color: '#3b82f6', weight: 3, dashArray: '8 6' }}
        />
      )}
    </MapContainer>
  );
}
