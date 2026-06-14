import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { getPacientes, getMedicos, getCitas, getCitasMedico, getCitasPaciente } from '../api/clinicaApi';

const badgeClass = e => ({ Pendiente: 'badge badge-pendiente', Confirmada: 'badge badge-confirmada', Cancelada: 'badge badge-cancelada', Completada: 'badge badge-completada', Anulada: 'badge badge-anulada' }[e] || 'badge');
const fmtFecha  = f => new Date(f).toLocaleString('es-PE', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
const calcEdad  = f => { const hoy = new Date(); const nac = new Date(f); let e = hoy.getFullYear() - nac.getFullYear(); if (hoy < new Date(hoy.getFullYear(), nac.getMonth(), nac.getDate())) e--; return e; };

/* ─── ADMIN ─── */
function AdminDash({ pacientes, medicos, citas }) {
  const navigate = useNavigate();
  const hoy = new Date().toDateString();
  const citasHoy      = citas.filter(c => new Date(c.fechaHora).toDateString() === hoy);
  const pendientes    = citas.filter(c => c.estado === 'Pendiente');
  const confirmadas   = citas.filter(c => c.estado === 'Confirmada');
  const completadas   = citas.filter(c => c.estado === 'Completada');
  const recientes     = [...citas].sort((a,b) => new Date(b.fechaHora)-new Date(a.fechaHora)).slice(0,8);

  return (
    <>
      <div className="welcome-banner">
        <div className="welcome-text">
          <h2>Panel de Administración</h2>
          <p>Gestione pacientes, médicos y citas desde un solo lugar</p>
        </div>
        <div className="welcome-icon">🏥</div>
      </div>

      <div className="stats-grid">
        <div className="stat-card" onClick={() => navigate('/pacientes')} style={{ cursor: 'pointer' }}>
          <div className="stat-icon" style={{ background: '#EDE9FE' }}>👥</div>
          <div className="stat-info">
            <div className="stat-value" style={{ color: '#6B21A8' }}>{pacientes.length}</div>
            <div className="stat-label">Pacientes registrados</div>
          </div>
        </div>
        <div className="stat-card" onClick={() => navigate('/medicos')} style={{ cursor: 'pointer' }}>
          <div className="stat-icon" style={{ background: '#DBEAFE' }}>🩺</div>
          <div className="stat-info">
            <div className="stat-value" style={{ color: '#1D4ED8' }}>{medicos.length}</div>
            <div className="stat-label">Médicos activos</div>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#FEF3C7' }}>📅</div>
          <div className="stat-info">
            <div className="stat-value" style={{ color: '#D97706' }}>{citasHoy.length}</div>
            <div className="stat-label">Citas para hoy</div>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#FEE2E2' }}>⏳</div>
          <div className="stat-info">
            <div className="stat-value" style={{ color: '#DC2626' }}>{pendientes.length}</div>
            <div className="stat-label">Pendientes de confirmar</div>
          </div>
        </div>
      </div>

      <div className="content-grid wide">
        {/* Últimas citas */}
        <div className="section-card">
          <div className="section-header">
            <span className="section-title">📅 Últimas Citas Registradas</span>
            <span className="section-link" onClick={() => navigate('/citas')}>Ver todas →</span>
          </div>
          {recientes.length === 0 ? (
            <div className="empty-wrap"><div className="empty-icon">📭</div><div className="empty-text">No hay citas aún</div></div>
          ) : (
            <table>
              <thead><tr><th>Paciente</th><th>Médico</th><th>Fecha</th><th>Estado</th></tr></thead>
              <tbody>
                {recientes.map(c => (
                  <tr key={c.id}>
                    <td><div className="td-name">{c.nombrePaciente}</div></td>
                    <td><div>{c.nombreMedico}</div><div className="td-sub">{c.especialidadMedico}</div></td>
                    <td style={{ fontSize: 12 }}>{fmtFecha(c.fechaHora)}</td>
                    <td><span className={badgeClass(c.estado)}>{c.estado}</span></td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>

        {/* Panel derecho */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          {/* Acciones rápidas */}
          <div className="section-card">
            <div className="section-header">
              <span className="section-title">⚡ Acciones Rápidas</span>
            </div>
            <div className="quick-actions">
              <div className="quick-btn" onClick={() => navigate('/pacientes')}>
                <span className="quick-btn-icon">👤</span>
                <span className="quick-btn-label">Nuevo Paciente</span>
              </div>
              <div className="quick-btn" onClick={() => navigate('/medicos')}>
                <span className="quick-btn-icon">🩺</span>
                <span className="quick-btn-label">Nuevo Médico</span>
              </div>
              <div className="quick-btn" onClick={() => navigate('/citas')}>
                <span className="quick-btn-icon">📋</span>
                <span className="quick-btn-label">Nueva Cita</span>
              </div>
            </div>
          </div>

          {/* Resumen de estados */}
          <div className="section-card">
            <div className="section-header">
              <span className="section-title">📊 Resumen de Citas</span>
            </div>
            <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 10 }}>
              {[
                { label: 'Total', val: citas.length, color: '#6B21A8', bg: '#EDE9FE' },
                { label: 'Pendientes', val: pendientes.length, color: '#D97706', bg: '#FEF3C7' },
                { label: 'Confirmadas', val: confirmadas.length, color: '#1D4ED8', bg: '#DBEAFE' },
                { label: 'Completadas', val: completadas.length, color: '#059669', bg: '#D1FAE5' },
              ].map(item => (
                <div key={item.label} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '8px 12px', borderRadius: 8, background: item.bg }}>
                  <span style={{ fontSize: 13, color: item.color, fontWeight: 600 }}>{item.label}</span>
                  <span style={{ fontSize: 20, fontWeight: 700, color: item.color }}>{item.val}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Médicos recientes */}
          {medicos.length > 0 && (
            <div className="section-card">
              <div className="section-header">
                <span className="section-title">🩺 Médicos del Sistema</span>
                <span className="section-link" onClick={() => navigate('/medicos')}>Ver todos →</span>
              </div>
              <div className="activity-list">
                {medicos.slice(0, 4).map(m => (
                  <div key={m.id} className="activity-item">
                    <div className="activity-dot" style={{ background: '#6B21A8' }} />
                    <div className="activity-content">
                      <div className="activity-title">Dr. {m.nombre} {m.apellido}</div>
                      <div className="activity-time">{m.especialidad} · CMP: {m.colegioMedico}</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </>
  );
}

/* ─── DOCTOR ─── */
function DoctorDash({ citas, user }) {
  const navigate = useNavigate();
  const hoy = new Date().toDateString();
  const misHoy     = citas.filter(c => new Date(c.fechaHora).toDateString() === hoy);
  const proximas   = citas.filter(c => new Date(c.fechaHora) > new Date() && c.estado !== 'Cancelada' && c.estado !== 'Anulada').slice(0, 6);
  const misPac     = [...new Set(citas.map(c => c.nombrePaciente))];

  return (
    <>
      <div className="welcome-banner" style={{ background: 'linear-gradient(135deg, #1e3a5f, #0284C7)' }}>
        <div className="welcome-text">
          <h2>Dr. {user.nombre} {user.apellido}</h2>
          <p>Bienvenido a su panel médico — {new Date().toLocaleDateString('es-PE', { weekday: 'long', day: 'numeric', month: 'long' })}</p>
        </div>
        <div className="welcome-icon">🩺</div>
      </div>

      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#DBEAFE' }}>📅</div>
          <div className="stat-info">
            <div className="stat-value" style={{ color: '#1D4ED8' }}>{misHoy.length}</div>
            <div className="stat-label">Citas hoy</div>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#FEF3C7' }}>⏳</div>
          <div className="stat-info">
            <div className="stat-value" style={{ color: '#D97706' }}>{citas.filter(c => c.estado === 'Pendiente').length}</div>
            <div className="stat-label">Pendientes</div>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#D1FAE5' }}>✅</div>
          <div className="stat-info">
            <div className="stat-value" style={{ color: '#059669' }}>{citas.filter(c => c.estado === 'Completada').length}</div>
            <div className="stat-label">Completadas</div>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#EDE9FE' }}>👥</div>
          <div className="stat-info">
            <div className="stat-value" style={{ color: '#6B21A8' }}>{misPac.length}</div>
            <div className="stat-label">Mis pacientes</div>
          </div>
        </div>
      </div>

      <div className="section-card">
        <div className="section-header">
          <span className="section-title">📋 Próximas Citas</span>
          <span className="section-link" onClick={() => navigate('/citas')}>Ver todas →</span>
        </div>
        {proximas.length === 0 ? (
          <div className="empty-wrap"><div className="empty-icon">📭</div><div className="empty-text">No tiene citas próximas</div></div>
        ) : (
          <table>
            <thead><tr><th>Paciente</th><th>Fecha y Hora</th><th>Motivo</th><th>Estado</th></tr></thead>
            <tbody>
              {proximas.map(c => (
                <tr key={c.id}>
                  <td><div className="td-name">{c.nombrePaciente}</div></td>
                  <td style={{ fontSize: 12 }}>{fmtFecha(c.fechaHora)}</td>
                  <td style={{ maxWidth: 180, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{c.motivo}</td>
                  <td><span className={badgeClass(c.estado)}>{c.estado}</span></td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </>
  );
}

/* ─── PACIENTE ─── */
function PacienteDash({ citas, user }) {
  const navigate = useNavigate();
  const proxima = citas.filter(c => new Date(c.fechaHora) > new Date() && c.estado !== 'Cancelada' && c.estado !== 'Anulada')
    .sort((a, b) => new Date(a.fechaHora) - new Date(b.fechaHora))[0];
  const historial = [...citas].sort((a,b) => new Date(b.fechaHora)-new Date(a.fechaHora));

  return (
    <>
      <div className="welcome-banner" style={{ background: 'linear-gradient(135deg, #064e3b, #059669)' }}>
        <div className="welcome-text">
          <h2>Hola, {user.nombre} {user.apellido}</h2>
          <p>Consulte sus citas médicas y solicite nuevas cuando lo necesite</p>
        </div>
        <div className="welcome-icon">🧑‍⚕️</div>
      </div>

      {proxima && (
        <div style={{ background: 'linear-gradient(135deg, #eff6ff, #dbeafe)', border: '1.5px solid #bfdbfe', borderRadius: 14, padding: 20, marginBottom: 20 }}>
          <div style={{ fontSize: 12, fontWeight: 600, color: '#1D4ED8', textTransform: 'uppercase', letterSpacing: 1, marginBottom: 8 }}>📅 Próxima Cita</div>
          <div style={{ fontSize: 18, fontWeight: 700, color: '#1e1b4b' }}>{proxima.nombreMedico}</div>
          <div style={{ fontSize: 13, color: '#64748b', marginTop: 4 }}>{proxima.especialidadMedico}</div>
          <div style={{ display: 'flex', gap: 20, marginTop: 12, fontSize: 13, color: '#334155' }}>
            <span>🗓️ {fmtFecha(proxima.fechaHora)}</span>
            <span>📋 {proxima.motivo}</span>
          </div>
          <div style={{ marginTop: 10 }}>
            <span className={badgeClass(proxima.estado)}>{proxima.estado}</span>
          </div>
        </div>
      )}

      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#EDE9FE' }}>📅</div>
          <div className="stat-info">
            <div className="stat-value" style={{ color: '#6B21A8' }}>{citas.length}</div>
            <div className="stat-label">Total de citas</div>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#D1FAE5' }}>✅</div>
          <div className="stat-info">
            <div className="stat-value" style={{ color: '#059669' }}>{citas.filter(c => c.estado === 'Completada').length}</div>
            <div className="stat-label">Consultas completadas</div>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#FEF3C7' }}>⏳</div>
          <div className="stat-info">
            <div className="stat-value" style={{ color: '#D97706' }}>{citas.filter(c => c.estado === 'Pendiente' || c.estado === 'Confirmada').length}</div>
            <div className="stat-label">Próximas pendientes</div>
          </div>
        </div>
      </div>

      <div className="content-grid">
        <div className="section-card">
          <div className="section-header">
            <span className="section-title">📋 Historial de Citas</span>
            <span className="section-link" onClick={() => navigate('/citas')}>Ver todas →</span>
          </div>
          {historial.length === 0 ? (
            <div className="empty-wrap"><div className="empty-icon">📭</div><div className="empty-text">No tiene citas registradas</div></div>
          ) : (
            <table>
              <thead><tr><th>Médico</th><th>Fecha</th><th>Motivo</th><th>Estado</th></tr></thead>
              <tbody>
                {historial.slice(0, 6).map(c => (
                  <tr key={c.id}>
                    <td><div className="td-name">{c.nombreMedico}</div><div className="td-sub">{c.especialidadMedico}</div></td>
                    <td style={{ fontSize: 12 }}>{fmtFecha(c.fechaHora)}</td>
                    <td style={{ maxWidth: 140, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', fontSize: 12 }}>{c.motivo}</td>
                    <td><span className={badgeClass(c.estado)}>{c.estado}</span></td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
        <div className="section-card">
          <div className="section-header"><span className="section-title">⚡ Acciones</span></div>
          <div className="quick-actions" style={{ gridTemplateColumns: '1fr' }}>
            <div className="quick-btn" onClick={() => navigate('/citas')}>
              <span className="quick-btn-icon">📅</span>
              <span className="quick-btn-label">Solicitar Nueva Cita</span>
            </div>
            <div className="quick-btn" onClick={() => navigate('/medicos')}>
              <span className="quick-btn-icon">🔍</span>
              <span className="quick-btn-label">Ver Médicos</span>
            </div>
            <div className="quick-btn" onClick={() => navigate('/citas')}>
              <span className="quick-btn-icon">📋</span>
              <span className="quick-btn-label">Mis Citas</span>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

/* ─── PRINCIPAL ─── */
export default function Dashboard() {
  const { user } = useAuth();
  const [data, setData] = useState({ pacientes: [], medicos: [], citas: [] });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchAll = async () => {
      try {
        if (user.role === 'admin') {
          const [pac, med, cit] = await Promise.all([getPacientes(), getMedicos(), getCitas()]);
          setData({ pacientes: pac, medicos: med, citas: cit });
        } else if (user.role === 'doctor' && user.medicoId) {
          const [med, cit] = await Promise.all([getMedicos(), getCitasMedico(user.medicoId)]);
          setData({ pacientes: [], medicos: med, citas: cit });
        } else if (user.role === 'paciente' && user.pacienteId) {
          const cit = await getCitasPaciente(user.pacienteId);
          setData({ pacientes: [], medicos: [], citas: cit });
        }
      } catch { /* API offline */ }
      setLoading(false);
    };
    fetchAll();
  }, [user]);

  if (loading) return (
    <div className="loading-wrap">
      <div className="spinner" />
      <div className="loading-text">Cargando información...</div>
    </div>
  );

  if (user.role === 'admin')    return <AdminDash {...data} />;
  if (user.role === 'doctor')   return <DoctorDash citas={data.citas} user={user} />;
  if (user.role === 'paciente') return <PacienteDash citas={data.citas} user={user} />;
  return null;
}
