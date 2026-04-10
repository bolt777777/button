import { useState } from 'react';
import { useSocket } from '../hooks/useSocket';
import { useAlerts, Alert } from '../hooks/useAlerts';
import { useGuards } from '../hooks/useGuards';
import AlertFeed from '../components/AlertFeed';
import LiveMap from '../components/LiveMap';
import AdminPanel from './AdminPanel';

interface Props {
  onLogout: () => void;
}

export default function Dashboard({ onLogout }: Props) {
  const { socket, connected } = useSocket();
  const { alerts, assign, resolve } = useAlerts(socket);
  const guards = useGuards(socket);
  const [selectedAlert, setSelectedAlert] = useState<Alert | null>(null);
  const [showAdmin, setShowAdmin] = useState(false);

  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const isAdmin = user.role === 'admin' || user.role === 'superadmin';

  if (showAdmin) return <AdminPanel onBack={() => setShowAdmin(false)} />;

  return (
    <div style={styles.root}>
      <header style={styles.header}>
        <div style={styles.headerLeft}>
          <h1 style={styles.logo}>Bodyguard</h1>
          <span style={styles.role}>{user.role}</span>
          <span style={{ ...styles.dot, background: connected ? '#22c55e' : '#ef4444' }} />
          <span style={styles.connLabel}>{connected ? 'Online' : 'Offline'}</span>
        </div>
        <div style={styles.headerRight}>
          {isAdmin && (
            <button onClick={() => setShowAdmin(true)} style={styles.adminBtn}>Управление</button>
          )}
          <span style={styles.email}>{user.email}</span>
          <button onClick={onLogout} style={styles.logoutBtn}>Выход</button>
        </div>
      </header>

      <div style={styles.body}>
        <aside style={styles.sidebar}>
          <AlertFeed
            alerts={alerts}
            selectedId={selectedAlert?.id || null}
            onSelect={setSelectedAlert}
            onResolve={resolve}
          />
        </aside>
        <main style={styles.map}>
          <LiveMap
            alerts={alerts}
            guards={guards}
            selectedAlert={selectedAlert}
            onAssign={assign}
          />
        </main>
      </div>
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  root: {
    height: '100vh',
    display: 'flex',
    flexDirection: 'column',
    background: '#0f172a',
  },
  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: '0 20px',
    height: 56,
    background: '#1e293b',
    borderBottom: '1px solid #334155',
    flexShrink: 0,
  },
  headerLeft: { display: 'flex', alignItems: 'center', gap: 12 },
  headerRight: { display: 'flex', alignItems: 'center', gap: 12 },
  logo: { color: '#f1f5f9', fontSize: 20, fontWeight: 800, margin: 0 },
  role: {
    color: '#3b82f6',
    fontSize: 12,
    fontWeight: 700,
    background: '#1e3a5f',
    padding: '2px 8px',
    borderRadius: 4,
    textTransform: 'uppercase' as const,
  },
  dot: { width: 8, height: 8, borderRadius: '50%', flexShrink: 0 },
  connLabel: { color: '#94a3b8', fontSize: 13 },
  email: { color: '#94a3b8', fontSize: 13 },
  adminBtn: {
    padding: '6px 14px',
    border: 'none',
    borderRadius: 6,
    background: '#3b82f6',
    color: '#fff',
    fontSize: 13,
    fontWeight: 600,
    cursor: 'pointer',
  },
  logoutBtn: {
    padding: '6px 14px',
    border: '1px solid #475569',
    borderRadius: 6,
    background: 'transparent',
    color: '#f1f5f9',
    fontSize: 13,
    cursor: 'pointer',
  },
  body: { flex: 1, display: 'flex', overflow: 'hidden' },
  sidebar: {
    width: 340,
    flexShrink: 0,
    background: '#0f172a',
    borderRight: '1px solid #1e293b',
    overflowY: 'auto',
  },
  map: { flex: 1 },
};
