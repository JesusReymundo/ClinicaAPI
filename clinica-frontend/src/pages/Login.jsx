import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const DEMOS = [
  { role: 'admin',    icon: '👨‍💼', label: 'Administrador', desc: 'Acceso total al sistema', user: 'admin',    pass: 'admin123',  className: 'admin' },
  { role: 'doctor',   icon: '🩺',  label: 'Médico',         desc: 'Gestión de sus citas',   user: 'doctor',   pass: 'medico123', className: 'doctor' },
  { role: 'paciente', icon: '🧑',  label: 'Paciente',       desc: 'Ver y solicitar citas',   user: 'paciente', pass: 'cita123',   className: 'paciente' },
];

export default function Login() {
  const [form, setForm] = useState({ username: '', password: '' });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPass, setShowPass] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.username || !form.password) { setError('Complete todos los campos'); return; }
    setLoading(true); setError('');
    await new Promise(r => setTimeout(r, 500));
    const ok = login(form.username, form.password);
    if (ok) navigate('/');
    else { setError('Usuario o contraseña incorrectos'); setLoading(false); }
  };

  const useDemo = (u, p) => setForm({ username: u, password: p });

  return (
    <div className="login-page">
      {/* Panel izquierdo - Branding */}
      <div className="login-left">
        <div className="login-branding">
          <div className="login-logo">🏥</div>
          <h1>ClinicaSalud</h1>
          <p>Sistema Integral de Gestión Médica</p>

          <div className="login-features">
            <div className="login-feature">✅ Registro y gestión de pacientes</div>
            <div className="login-feature">✅ Administración de médicos</div>
            <div className="login-feature">✅ Agendamiento de citas médicas</div>
            <div className="login-feature">✅ Control de historial clínico</div>
            <div className="login-feature">✅ Recetas y facturación</div>
          </div>

          <div className="login-stats">
            <div className="login-stat">
              <div className="login-stat-num">23+</div>
              <div className="login-stat-label">Tablas DB</div>
            </div>
            <div className="login-stat">
              <div className="login-stat-num">3</div>
              <div className="login-stat-label">Roles</div>
            </div>
            <div className="login-stat">
              <div className="login-stat-num">REST</div>
              <div className="login-stat-label">API .NET 8</div>
            </div>
          </div>
        </div>
      </div>

      {/* Panel derecho - Formulario */}
      <div className="login-right">
        <div className="login-box">
          <h2>Bienvenido</h2>
          <p className="login-subtitle">Ingrese sus credenciales para acceder al sistema</p>

          {error && <div className="alert alert-error">⚠️ {error}</div>}

          <form onSubmit={handleSubmit} className="login-form">
            <div className="form-group">
              <label>Usuario</label>
              <input
                value={form.username}
                onChange={e => { setForm({ ...form, username: e.target.value }); setError(''); }}
                placeholder="Ingrese su usuario"
                autoComplete="username"
                autoFocus
              />
            </div>
            <div className="form-group">
              <label>Contraseña</label>
              <div style={{ position: 'relative' }}>
                <input
                  type={showPass ? 'text' : 'password'}
                  value={form.password}
                  onChange={e => { setForm({ ...form, password: e.target.value }); setError(''); }}
                  placeholder="••••••••"
                  autoComplete="current-password"
                  style={{ paddingRight: 40 }}
                />
                <button type="button" onClick={() => setShowPass(p => !p)}
                  style={{ position: 'absolute', right: 10, top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', cursor: 'pointer', fontSize: 16, color: '#94A3B8' }}>
                  {showPass ? '🙈' : '👁️'}
                </button>
              </div>
            </div>
            <button type="submit" className="btn btn-primary btn-full login-submit" disabled={loading}>
              {loading ? '⏳ Verificando...' : '🔐 Ingresar al Sistema'}
            </button>
          </form>

          <div className="login-divider"><span>accesos de demostración</span></div>

          <div className="demo-section">
            <p>Haga clic para cargar credenciales:</p>
            <div className="demo-cards">
              {DEMOS.map(d => (
                <div key={d.role} className={`demo-card ${d.className}`} onClick={() => useDemo(d.user, d.pass)}>
                  <span className="demo-card-icon">{d.icon}</span>
                  <div className="demo-card-info">
                    <strong>{d.label}</strong>
                    <small>{d.user} / {d.pass}</small>
                  </div>
                  <span className="demo-card-arrow">→</span>
                </div>
              ))}
            </div>
          </div>

          <div className="login-footer">
            IDAT · 5to Ciclo · Desarrollo de Servicios Web · 2024
          </div>
        </div>
      </div>
    </div>
  );
}
