import { useState, FormEvent } from 'react';
import { post } from '../api/http';

interface Props {
  onLogin: () => void;
}

export default function Login({ onLogin }: Props) {
  const [email, setEmail] = useState('operator@bodyguard.dev');
  const [password, setPassword] = useState('operator123');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const data = await post<{ accessToken: string; user: any }>('/auth/login', {
        email,
        password,
      });
      localStorage.setItem('token', data.accessToken);
      localStorage.setItem('user', JSON.stringify(data.user));
      onLogin();
    } catch {
      setError('Неверные учётные данные');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={styles.container}>
      <form onSubmit={submit} style={styles.form}>
        <h1 style={styles.title}>Терминал оператора</h1>
        <p style={styles.subtitle}>Bodyguard Security System</p>
        <input
          type="email"
          placeholder="Email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          style={styles.input}
          required
        />
        <input
          type="password"
          placeholder="Пароль"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          style={styles.input}
          required
        />
        {error && <p style={styles.error}>{error}</p>}
        <button type="submit" style={styles.button} disabled={loading}>
          {loading ? 'Вход...' : 'Войти'}
        </button>
      </form>
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  container: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    height: '100vh',
    background: '#0f172a',
  },
  form: {
    background: '#1e293b',
    padding: '48px 40px',
    borderRadius: 16,
    width: 380,
    display: 'flex',
    flexDirection: 'column',
    gap: 16,
    boxShadow: '0 25px 50px rgba(0,0,0,0.5)',
  },
  title: {
    color: '#f1f5f9',
    fontSize: 24,
    fontWeight: 700,
    margin: 0,
    textAlign: 'center',
  },
  subtitle: {
    color: '#64748b',
    fontSize: 14,
    margin: '0 0 8px',
    textAlign: 'center',
  },
  input: {
    padding: '12px 16px',
    border: '1px solid #334155',
    borderRadius: 8,
    background: '#0f172a',
    color: '#f1f5f9',
    fontSize: 15,
    outline: 'none',
  },
  button: {
    padding: '12px',
    border: 'none',
    borderRadius: 8,
    background: '#3b82f6',
    color: '#fff',
    fontSize: 16,
    fontWeight: 600,
    cursor: 'pointer',
    marginTop: 8,
  },
  error: {
    color: '#ef4444',
    fontSize: 14,
    margin: 0,
    textAlign: 'center',
  },
};
