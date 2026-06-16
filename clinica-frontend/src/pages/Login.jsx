import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const DEMOS = [
  { role: 'admin',    icon: '👨‍💼', label: 'Administrador', desc: 'Acceso total al sistema',  user: 'jesus_admin',   pass: 'Admin@2024',  color: '#6B21A8' },
  { role: 'doctor',   icon: '🩺',  label: 'Médico',         desc: 'Gestión de sus citas',    user: 'aldair_santos', pass: 'Doctor@2024', color: '#0284C7' },
  { role: 'paciente', icon: '🧑',  label: 'Paciente',       desc: 'Ver y solicitar citas',   user: 'paola_medina',  pass: 'Paciente123', color: '#059669' },
];

const MARKETING = [
  { icon: '❤️', title: 'Atención con Calidez', desc: 'Médicos especializados comprometidos con tu bienestar' },
  { icon: '🔬', title: 'Tecnología Avanzada',   desc: 'Equipos de última generación para diagnósticos precisos' },
  { icon: '📅', title: 'Citas Fáciles',         desc: 'Agenda, cancela o reprograma desde cualquier lugar' },
];

export default function Login() {
  const [form, setForm]       = useState({ username: '', password: '' });
  const [error, setError]     = useState('');
  const [loading, setLoading] = useState(false);
  const [showPass, setShowPass] = useState(false);
  const [openDemo, setOpenDemo] = useState(null); // índice del acordeón abierto
  const { login } = useAuth();
  const navigate  = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.username || !form.password) { setError('Complete todos los campos'); return; }
    setLoading(true); setError('');
    const ok = await login(form.username, form.password);
    if (ok) navigate('/');
    else { setError('Usuario o contraseña incorrectos'); setLoading(false); }
  };

  const selectDemo = (d, idx) => {
    setForm({ username: d.user, password: d.pass });
    setOpenDemo(openDemo === idx ? null : idx);
  };

  return (
    <div className="login-page">

      {/* ── PANEL IZQUIERDO — Branding ── */}
      <div className="login-left">
        <div className="login-branding">

          {/* Logo + nombre */}
          <div className="login-logo-wrap">
            <div className="login-logo-icon">🏥</div>
          </div>
          <h1 className="login-clinic-name">Clínica IDAT</h1>
          <p className="login-tagline">"Tu salud, nuestra misión"</p>

          {/* Cards de marketing */}
          <div className="login-mkt-cards">
            {MARKETING.map((m, i) => (
              <div key={i} className="login-mkt-card">
                <span className="login-mkt-icon">{m.icon}</span>
                <div>
                  <div className="login-mkt-title">{m.title}</div>
                  <div className="login-mkt-desc">{m.desc}</div>
                </div>
              </div>
            ))}
          </div>

          {/* Decoración */}
          <div className="login-deco-bar" />
          <p className="login-deco-text">IDAT · 5to Ciclo · Desarrollo de Servicios Web · 2024</p>
        </div>
      </div>

      {/* ── PANEL DERECHO — Formulario ── */}
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
                  style={{ position:'absolute', right:10, top:'50%', transform:'translateY(-50%)', background:'none', border:'none', cursor:'pointer', fontSize:16, color:'#94A3B8' }}>
                  {showPass ? '🙈' : '👁️'}
                </button>
              </div>
            </div>
            <button type="submit" className="btn btn-primary btn-full login-submit" disabled={loading}>
              {loading ? '⏳ Verificando...' : '🔐 Ingresar al Sistema'}
            </button>
          </form>

          {/* ── Acordeón de accesos demo ── */}
          <div className="login-divider"><span>accesos de demostración</span></div>

          <div className="demo-accordion">
            {DEMOS.map((d, idx) => {
              const isOpen = openDemo === idx;
              return (
                <div key={d.role} className={`demo-acc-item ${isOpen ? 'open' : ''}`}
                  style={{ '--acc-color': d.color }}>
                  <button className="demo-acc-header" onClick={() => selectDemo(d, idx)}>
                    <span className="demo-acc-icon" style={{ background: d.color + '20', color: d.color }}>
                      {d.icon}
                    </span>
                    <div className="demo-acc-info">
                      <span className="demo-acc-label">{d.label}</span>
                      <span className="demo-acc-subdesc">{d.desc}</span>
                    </div>
                    <span className="demo-acc-chevron" style={{ color: d.color }}>
                      {isOpen ? '▲' : '▼'}
                    </span>
                  </button>
                  {isOpen && (
                    <div className="demo-acc-body">
                      <div className="demo-cred-row">
                        <span className="demo-cred-label">Usuario:</span>
                        <code className="demo-cred-val">{d.user}</code>
                      </div>
                      <div className="demo-cred-row">
                        <span className="demo-cred-label">Contraseña:</span>
                        <code className="demo-cred-val">{d.pass}</code>
                      </div>
                      <p className="demo-acc-hint">✅ Credenciales cargadas — presione <strong>Ingresar</strong></p>
                    </div>
                  )}
                </div>
              );
            })}
          </div>

          <div className="login-footer">
            IDAT · 5to Ciclo · Desarrollo de Servicios Web · 2024
          </div>
        </div>
      </div>
    </div>
  );
}
