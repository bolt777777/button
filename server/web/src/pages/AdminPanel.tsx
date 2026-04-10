import { useState, useEffect, FormEvent } from 'react';
import { get, post } from '../api/http';

interface UserItem {
  id: string;
  name: string;
  email: string;
  phone: string;
  isOnline?: boolean;
  status?: string;
}

export default function AdminPanel({ onBack }: { onBack: () => void }) {
  const [users, setUsers] = useState<UserItem[]>([]);
  const [guards, setGuards] = useState<UserItem[]>([]);
  const [tab, setTab] = useState<'users' | 'guards' | 'create'>('users');
  const [form, setForm] = useState({ name: '', email: '', password: '', phone: '', type: 'user' });
  const [msg, setMsg] = useState('');

  const load = () => {
    get<{ users: UserItem[]; guards: UserItem[] }>('/users').then((d) => {
      setUsers(d.users);
      setGuards(d.guards);
    });
  };

  useEffect(load, []);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setMsg('');
    try {
      await post('/users', form);
      setMsg(`${form.type === 'guard' ? 'Охранник' : 'Клиент'} создан`);
      setForm({ name: '', email: '', password: '', phone: '', type: 'user' });
      load();
    } catch {
      setMsg('Ошибка создания');
    }
  };

  return (
    <div style={styles.root}>
      <header style={styles.header}>
        <button onClick={onBack} style={styles.backBtn}>← Карта</button>
        <h1 style={styles.title}>Управление</h1>
      </header>
      <nav style={styles.tabs}>
        {(['users', 'guards', 'create'] as const).map((t) => (
          <button
            key={t}
            onClick={() => setTab(t)}
            style={{ ...styles.tab, background: tab === t ? '#3b82f6' : '#334155' }}
          >
            {t === 'users' ? 'Клиенты' : t === 'guards' ? 'Охранники' : '+ Создать'}
          </button>
        ))}
      </nav>

      <div style={styles.content}>
        {tab === 'create' && (
          <form onSubmit={submit} style={styles.form}>
            <select
              value={form.type}
              onChange={(e) => setForm({ ...form, type: e.target.value })}
              style={styles.input}
            >
              <option value="user">Клиент</option>
              <option value="guard">Охранник</option>
            </select>
            <input placeholder="Имя" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} style={styles.input} required />
            <input placeholder="Email" type="email" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} style={styles.input} required />
            <input placeholder="Пароль" type="password" value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} style={styles.input} required minLength={4} />
            <input placeholder="Телефон" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} style={styles.input} />
            <button type="submit" style={styles.submitBtn}>Создать</button>
            {msg && <p style={{ color: msg.includes('Ошибка') ? '#ef4444' : '#22c55e', margin: 0 }}>{msg}</p>}
          </form>
        )}

        {tab === 'users' && (
          <table style={styles.table}>
            <thead>
              <tr>
                <th style={styles.th}>Имя</th>
                <th style={styles.th}>Email</th>
                <th style={styles.th}>Телефон</th>
                <th style={styles.th}>Статус</th>
              </tr>
            </thead>
            <tbody>
              {users.map((u) => (
                <tr key={u.id}>
                  <td style={styles.td}>{u.name}</td>
                  <td style={styles.td}>{u.email}</td>
                  <td style={styles.td}>{u.phone}</td>
                  <td style={styles.td}>{u.isOnline ? '🟢 Online' : '⚪ Offline'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}

        {tab === 'guards' && (
          <table style={styles.table}>
            <thead>
              <tr>
                <th style={styles.th}>Имя</th>
                <th style={styles.th}>Email</th>
                <th style={styles.th}>Телефон</th>
                <th style={styles.th}>Статус</th>
              </tr>
            </thead>
            <tbody>
              {guards.map((g) => (
                <tr key={g.id}>
                  <td style={styles.td}>{g.name}</td>
                  <td style={styles.td}>{g.email}</td>
                  <td style={styles.td}>{g.phone}</td>
                  <td style={styles.td}>
                    {g.status === 'available' ? '🟢 Свободен' : g.status === 'busy' ? '🟡 Занят' : '⚪ Оффлайн'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  root: { height: '100vh', display: 'flex', flexDirection: 'column', background: '#0f172a', color: '#f1f5f9' },
  header: { display: 'flex', alignItems: 'center', gap: 16, padding: '16px 24px', borderBottom: '1px solid #1e293b' },
  backBtn: { padding: '6px 14px', border: '1px solid #475569', borderRadius: 6, background: 'transparent', color: '#f1f5f9', cursor: 'pointer', fontSize: 14 },
  title: { fontSize: 22, fontWeight: 700, margin: 0 },
  tabs: { display: 'flex', gap: 8, padding: '12px 24px' },
  tab: { padding: '8px 18px', border: 'none', borderRadius: 6, color: '#fff', cursor: 'pointer', fontWeight: 600, fontSize: 14 },
  content: { flex: 1, padding: '0 24px 24px', overflowY: 'auto' },
  form: { display: 'flex', flexDirection: 'column', gap: 12, maxWidth: 400 },
  input: { padding: '10px 14px', border: '1px solid #334155', borderRadius: 6, background: '#1e293b', color: '#f1f5f9', fontSize: 14 },
  submitBtn: { padding: '10px', border: 'none', borderRadius: 6, background: '#3b82f6', color: '#fff', fontWeight: 600, cursor: 'pointer' },
  table: { width: '100%', borderCollapse: 'collapse' },
  th: { textAlign: 'left', padding: '10px 12px', borderBottom: '1px solid #334155', color: '#94a3b8', fontSize: 13, fontWeight: 600 },
  td: { padding: '10px 12px', borderBottom: '1px solid #1e293b', fontSize: 14 },
};
