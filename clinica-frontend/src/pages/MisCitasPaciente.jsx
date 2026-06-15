import { useEffect, useState, useCallback } from 'react';
import { useAuth } from '../context/AuthContext';
import { getCitasPaciente, anularCita } from '../api/clinicaApi';

const BADGE = {
  Pendiente:  'badge badge-pendiente',
  Confirmada: 'badge badge-confirmada',
  Cancelada:  'badge badge-cancelada',
  Completada: 'badge badge-completada',
  Anulada:    'badge badge-anulada',
};

const fmtFecha = f => new Date(f).toLocaleString('es-PE', {
  weekday: 'short', day: '2-digit', month: 'short', year: 'numeric',
  hour: '2-digit', minute: '2-digit',
});

export default function MisCitasPaciente() {
  const { user } = useAuth();
  const [citas, setCitas]     = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError]     = useState('');
  const [tab, setTab]         = useState('Todas');
  const [busy, setBusy]       = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const data = await getCitasPaciente(user.pacienteId);
      setCitas(data);
      setError('');
    } catch {
      setError('No se pudo cargar tus citas. Verifica que la API esté activa.');
    } finally { setLoading(false); }
  }, [user.pacienteId]);

  useEffect(() => { load(); }, [load]);

  const anular = async id => {
    if (!confirm('¿Deseas anular esta cita?')) return;
    setBusy(id);
    try { await anularCita(id); await load(); }
    catch (e) { alert(e.response?.data?.message || 'No se pudo anular la cita'); }
    finally { setBusy(null); }
  };

  const ESTADOS = ['Pendiente','Confirmada','Completada','Cancelada','Anulada'];
  const filtered = tab === 'Todas' ? citas : citas.filter(c => c.estado === tab);
  const counts   = ESTADOS.reduce((a, e) => ({ ...a, [e]: citas.filter(c => c.estado === e).length }), {});

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">🏥 Mis Citas como Paciente</h1>
          <p className="page-subtitle">Citas médicas agendadas a tu nombre</p>
        </div>
        <button className="btn btn-ghost btn-sm" onClick={load}>↻ Actualizar</button>
      </div>

      {error && <div className="alert alert-error">⚠️ {error}</div>}

      <div className="tab-bar">
        <button className={`tab ${tab === 'Todas' ? 'active' : ''}`} onClick={() => setTab('Todas')}>
          Todas <span className="tab-count">{citas.length}</span>
        </button>
        {ESTADOS.map(e => (
          <button key={e} className={`tab ${tab === e ? 'active' : ''}`} onClick={() => setTab(e)}>
            {e} <span className="tab-count">{counts[e] || 0}</span>
          </button>
        ))}
      </div>

      <div className="table-card">
        {loading ? (
          <div className="loading-wrap"><div className="spinner" /><div className="loading-text">Cargando citas...</div></div>
        ) : filtered.length === 0 ? (
          <div className="empty-wrap">
            <div className="empty-icon">🏥</div>
            <div className="empty-text">
              {tab === 'Todas' ? 'No tienes citas registradas aún' : `No tienes citas en estado "${tab}"`}
            </div>
            {tab === 'Todas' && (
              <a href="/solicitar-cita" className="btn btn-primary btn-sm" style={{ textDecoration:'none', display:'inline-block', marginTop:8 }}>
                Solicitar mi primera cita
              </a>
            )}
          </div>
        ) : (
          <table>
            <thead>
              <tr>
                <th>#</th>
                <th>Fecha y Hora</th>
                <th>Médico</th>
                <th>Especialidad</th>
                <th>Motivo</th>
                <th>Estado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map(c => {
                const esFinal = ['Cancelada','Completada','Anulada'].includes(c.estado);
                return (
                  <tr key={c.id}>
                    <td className="text-muted text-sm">#{c.id}</td>
                    <td style={{ whiteSpace: 'nowrap' }}>{fmtFecha(c.fechaHora)}</td>
                    <td>
                      <div className="td-name">{c.nombreMedico || '—'}</div>
                    </td>
                    <td style={{ fontSize: 12 }}>{c.especialidadMedico || '—'}</td>
                    <td style={{ maxWidth: 180, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', fontSize: 13 }}>
                      {c.motivo}
                    </td>
                    <td><span className={BADGE[c.estado] || 'badge'}>{c.estado}</span></td>
                    <td>
                      <div className="actions">
                        {!esFinal && (
                          <button className="btn btn-cancel btn-xs"
                            disabled={busy === c.id}
                            onClick={() => anular(c.id)}>
                            {busy === c.id ? '...' : '⊘ Anular'}
                          </button>
                        )}
                        {esFinal && <span className="text-muted text-sm">—</span>}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>

      {!loading && citas.length > 0 && (
        <div className="info-box" style={{ marginTop: 16 }}>
          <strong>ℹ️ Recuerda:</strong> Puedes anular una cita pendiente o confirmada desde aquí.
          Para solicitar nuevas citas ve a <a href="/solicitar-cita">Solicitar Cita</a>.
        </div>
      )}
    </div>
  );
}
