import type { Alert } from '../hooks/useAlerts';

interface Props {
  alerts: Alert[];
  selectedId: string | null;
  onSelect: (a: Alert) => void;
  onResolve: (id: string) => void;
}

const statusLabel: Record<string, string> = {
  new_alert: 'НОВЫЙ',
  assigned: 'НАЗНАЧЕН',
  resolved: 'ЗАКРЫТ',
  cancelled: 'ОТМЕНЁН',
};

const statusColor: Record<string, string> = {
  new_alert: '#ef4444',
  assigned: '#f59e0b',
  resolved: '#22c55e',
  cancelled: '#64748b',
};

export default function AlertFeed({ alerts, selectedId, onSelect, onResolve }: Props) {
  return (
    <div style={styles.container}>
      <h2 style={styles.header}>SOS Алерты</h2>
      <div style={styles.list}>
        {alerts.length === 0 && (
          <p style={styles.empty}>Нет активных алертов</p>
        )}
        {alerts.map((a) => (
          <div
            key={a.id}
            onClick={() => onSelect(a)}
            style={{
              ...styles.card,
              borderLeft: `4px solid ${statusColor[a.status] || '#64748b'}`,
              background: selectedId === a.id ? '#1e3a5f' : '#1e293b',
            }}
          >
            <div style={styles.cardTop}>
              <span style={{ ...styles.badge, background: statusColor[a.status] }}>
                {statusLabel[a.status] || a.status}
              </span>
              <span style={styles.time}>
                {new Date(a.createdAt).toLocaleTimeString('ru-RU')}
              </span>
            </div>
            <p style={styles.name}>{a.user.name}</p>
            <p style={styles.phone}>{a.user.phone}</p>
            {a.guard && (
              <p style={styles.guard}>Охранник: {a.guard.name}</p>
            )}
            {(a.status === 'assigned' || a.status === 'new_alert') && (
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  onResolve(a.id);
                }}
                style={styles.resolveBtn}
              >
                Закрыть
              </button>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  container: { height: '100%', display: 'flex', flexDirection: 'column' },
  header: {
    color: '#f1f5f9',
    fontSize: 18,
    fontWeight: 700,
    padding: '16px 16px 8px',
    margin: 0,
  },
  list: {
    flex: 1,
    overflowY: 'auto',
    padding: '0 12px 12px',
    display: 'flex',
    flexDirection: 'column',
    gap: 8,
  },
  empty: { color: '#64748b', textAlign: 'center', marginTop: 40 },
  card: {
    padding: '12px 14px',
    borderRadius: 8,
    cursor: 'pointer',
    transition: 'background 0.15s',
  },
  cardTop: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 6,
  },
  badge: {
    color: '#fff',
    fontSize: 11,
    fontWeight: 700,
    padding: '2px 8px',
    borderRadius: 4,
    textTransform: 'uppercase' as const,
  },
  time: { color: '#94a3b8', fontSize: 12 },
  name: { color: '#f1f5f9', fontSize: 15, fontWeight: 600, margin: '0 0 2px' },
  phone: { color: '#94a3b8', fontSize: 13, margin: 0 },
  guard: { color: '#38bdf8', fontSize: 13, margin: '4px 0 0' },
  resolveBtn: {
    marginTop: 8,
    padding: '6px 12px',
    border: 'none',
    borderRadius: 6,
    background: '#22c55e',
    color: '#fff',
    fontSize: 13,
    fontWeight: 600,
    cursor: 'pointer',
  },
};
