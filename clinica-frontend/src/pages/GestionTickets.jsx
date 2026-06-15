import { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';

const LS_KEY = 'clinica_tickets';
const ESTADOS = ['Abierto','En proceso','Resuelto','Cerrado'];
const BADGE_ESTADO = {
  'Abierto':    'badge badge-pendiente',
  'En proceso': 'badge badge-confirmada',
  'Resuelto':   'badge badge-completada',
  'Cerrado':    'badge badge-cancelada',
};
const PRIORIDAD_COLOR = { Baja: '#059669', Media: '#D97706', Alta: '#DC2626' };

function getTickets() {
  try { return JSON.parse(localStorage.getItem(LS_KEY) || '[]'); } catch { return []; }
}
function saveTickets(arr) { localStorage.setItem(LS_KEY, JSON.stringify(arr)); }

const fmtFecha = d => new Date(d).toLocaleString('es-PE', {
  day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit',
});

export default function GestionTickets() {
  const { user } = useAuth();
  const [tickets, setTickets]       = useState([]);
  const [filtroEstado, setFiltro]   = useState('Todos');
  const [filtroPrio, setFiltroPrio] = useState('Todos');
  const [selected, setSelected]     = useState(null);
  const [respuesta, setRespuesta]   = useState('');
  const [nuevoEstado, setNuevoEst]  = useState('');
  const [saving, setSaving]         = useState(false);

  const reload = () => setTickets(getTickets());
  useEffect(() => { reload(); }, []);

  const filtered = tickets.filter(t => {
    const matchEst  = filtroEstado === 'Todos' || t.estado === filtroEstado;
    const matchPrio = filtroPrio   === 'Todos' || t.prioridad === filtroPrio;
    return matchEst && matchPrio;
  }).sort((a, b) => {
    // Primero los abiertos, luego en proceso, luego resueltos, luego cerrados
    const order = { Abierto: 0, 'En proceso': 1, Resuelto: 2, Cerrado: 3 };
    if (order[a.estado] !== order[b.estado]) return order[a.estado] - order[b.estado];
    return new Date(b.fechaCreacion) - new Date(a.fechaCreacion);
  });

  const counts = ESTADOS.reduce((a, e) => ({ ...a, [e]: tickets.filter(t => t.estado === e).length }), {});
  const abiertos = tickets.filter(t => t.estado === 'Abierto').length;

  const abrirTicket = t => {
    setSelected(t);
    setRespuesta(t.respuesta || '');
    setNuevoEst(t.estado);
  };

  const guardar = () => {
    if (!nuevoEstado) return;
    setSaving(true);
    const all = getTickets();
    const idx = all.findIndex(t => t.id === selected.id);
    if (idx !== -1) {
      all[idx].estado = nuevoEstado;
      if (respuesta.trim()) {
        all[idx].respuesta = respuesta.trim();
        all[idx].fechaRespuesta = new Date().toISOString();
        all[idx].resueltoPor = `${user.nombre} ${user.apellido}`;
      }
      if (nuevoEstado === 'Resuelto' || nuevoEstado === 'Cerrado') {
        if (!all[idx].resueltoPor) {
          all[idx].resueltoPor = `${user.nombre} ${user.apellido}`;
          all[idx].fechaRespuesta = all[idx].fechaRespuesta || new Date().toISOString();
        }
      }
      saveTickets(all);
    }
    setSelected(null);
    setSaving(false);
    reload();
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">🎫 Gestión de Tickets</h1>
          <p className="page-subtitle">Administra y responde los reportes de usuarios</p>
        </div>
        <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
          {abiertos > 0 && (
            <span style={{ background: '#FEF3C7', color: '#D97706', padding: '6px 14px', borderRadius: 20, fontWeight: 700, fontSize: 14 }}>
              ⚠️ {abiertos} ticket{abiertos > 1 ? 's' : ''} abierto{abiertos > 1 ? 's' : ''}
            </span>
          )}
          <button className="btn btn-ghost btn-sm" onClick={reload}>↻ Actualizar</button>
        </div>
      </div>

      {/* Resumen */}
      <div className="stats-row" style={{ marginBottom: 20 }}>
        <div className="stat-card-mini">
          <div className="stat-mini-val">{tickets.length}</div>
          <div className="stat-mini-label">Total tickets</div>
        </div>
        {ESTADOS.map(e => (
          <div key={e} className="stat-card-mini"
            style={{ cursor: 'pointer', border: filtroEstado === e ? '2px solid #6B21A8' : '1px solid transparent' }}
            onClick={() => setFiltro(filtroEstado === e ? 'Todos' : e)}>
            <div className="stat-mini-val" style={{
              color: e === 'Abierto' ? '#D97706' : e === 'Resuelto' ? '#059669' : e === 'Cerrado' ? '#64748B' : '#1D4ED8'
            }}>
              {counts[e] || 0}
            </div>
            <div className="stat-mini-label">{e}</div>
          </div>
        ))}
      </div>

      {/* Filtros */}
      <div className="tab-bar">
        <button className={`tab ${filtroEstado === 'Todos' ? 'active' : ''}`} onClick={() => setFiltro('Todos')}>
          Todos <span className="tab-count">{tickets.length}</span>
        </button>
        {ESTADOS.map(e => (
          <button key={e} className={`tab ${filtroEstado === e ? 'active' : ''}`} onClick={() => setFiltro(e)}>
            {e} <span className="tab-count">{counts[e] || 0}</span>
          </button>
        ))}
      </div>

      <div style={{ display: 'flex', gap: 8, margin: '8px 0 12px' }}>
        <select className="filter-select" value={filtroPrio} onChange={e => setFiltroPrio(e.target.value)}>
          <option value="Todos">Todas las prioridades</option>
          <option>Alta</option>
          <option>Media</option>
          <option>Baja</option>
        </select>
      </div>

      <div className="table-card">
        {tickets.length === 0 ? (
          <div className="empty-wrap">
            <div className="empty-icon">🎫</div>
            <div className="empty-text">No hay tickets registrados aún</div>
          </div>
        ) : filtered.length === 0 ? (
          <div className="empty-wrap">
            <div className="empty-icon">🔍</div>
            <div className="empty-text">No hay tickets con ese filtro</div>
          </div>
        ) : (
          <div className="tickets-list">
            {filtered.map(t => (
              <div key={t.id}
                className="ticket-item"
                style={{ cursor: 'pointer', borderLeft: t.estado === 'Abierto' ? '4px solid #F59E0B' : t.estado === 'En proceso' ? '4px solid #3B82F6' : '4px solid #E2E8F0' }}
                onClick={() => abrirTicket(t)}>
                <div className="ticket-header">
                  <div className="ticket-id">#{t.id}</div>
                  <div className="ticket-cat">{t.categoria}</div>
                  <span style={{ fontSize: 12, background: '#F3F4F6', padding: '2px 8px', borderRadius: 20, color: '#374151' }}>
                    {t.usuarioRol === 'doctor' ? '🩺' : '👤'} {t.usuarioNombre}
                  </span>
                  <span className={BADGE_ESTADO[t.estado] || 'badge'}>{t.estado}</span>
                  <span style={{ fontSize: 12, fontWeight: 700, color: PRIORIDAD_COLOR[t.prioridad] }}>
                    ● {t.prioridad}
                  </span>
                  <div className="ticket-fecha text-muted text-sm">{fmtFecha(t.fechaCreacion)}</div>
                </div>
                <div className="ticket-desc">{t.descripcion}</div>
                {/* Quién respondió y cuándo */}
                {(t.resueltoPor || t.respuesta) && (
                  <div className="ticket-cierre">
                    {t.resueltoPor && (
                      <span className="cierre-por">
                        {t.estado === 'Cerrado' ? '🔒 Cerrado' : '✅ Atendido'} por <strong>{t.resueltoPor}</strong>
                        {t.fechaRespuesta ? ` · ${fmtFecha(t.fechaRespuesta)}` : ''}
                      </span>
                    )}
                    {t.respuesta && (
                      <div className="ticket-respuesta" style={{ marginTop: 6 }}>
                        <strong>Respuesta:</strong> {t.respuesta.slice(0, 100)}{t.respuesta.length > 100 ? '...' : ''}
                      </div>
                    )}
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Panel de gestión */}
      {selected && (
        <div className="modal-overlay" onClick={() => setSelected(null)}>
          <div className="modal-box" onClick={e => e.stopPropagation()} style={{ maxWidth: 600 }}>
            <div className="modal-header">
              <h2 className="modal-title">🎫 Ticket #{selected.id}</h2>
              <button className="modal-close" onClick={() => setSelected(null)}>✕</button>
            </div>
            <div className="modal-body">
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8, marginBottom: 12 }}>
                <div><span className="text-muted text-sm">Usuario:</span><br /><strong>{selected.usuarioNombre}</strong></div>
                <div><span className="text-muted text-sm">Rol:</span><br /><strong style={{ textTransform: 'capitalize' }}>{selected.usuarioRol}</strong></div>
                <div><span className="text-muted text-sm">Categoría:</span><br /><strong>{selected.categoria}</strong></div>
                <div><span className="text-muted text-sm">Prioridad:</span><br /><strong style={{ color: PRIORIDAD_COLOR[selected.prioridad] }}>{selected.prioridad}</strong></div>
                <div><span className="text-muted text-sm">Creado:</span><br /><strong>{fmtFecha(selected.fechaCreacion)}</strong></div>
                {selected.resueltoPor && (
                  <div><span className="text-muted text-sm">Atendido por:</span><br /><strong style={{ color: '#059669' }}>{selected.resueltoPor}</strong></div>
                )}
              </div>

              <div className="form-group">
                <label className="form-label">Descripción del problema:</label>
                <div style={{ background: '#F9FAFB', padding: 12, borderRadius: 8, fontSize: 14 }}>
                  {selected.descripcion}
                </div>
              </div>

              {selected.respuesta && (
                <div className="form-group">
                  <label className="form-label">Respuesta anterior:</label>
                  <div style={{ background: '#F0FDF4', border: '1px solid #86EFAC', padding: 12, borderRadius: 8, fontSize: 13, color: '#166534' }}>
                    {selected.respuesta}
                  </div>
                </div>
              )}

              <div className="form-group">
                <label className="form-label">Cambiar estado *</label>
                <div style={{ display: 'flex', gap: 8 }}>
                  {ESTADOS.map(e => (
                    <button key={e} className={`hora-btn ${nuevoEstado === e ? 'selected' : ''}`}
                      style={{ flex: 1, fontSize: 11 }}
                      onClick={() => setNuevoEst(e)}>{e}</button>
                  ))}
                </div>
              </div>

              <div className="form-group">
                <label className="form-label">Respuesta al usuario</label>
                <textarea className="form-control" rows={4}
                  placeholder="Escribe la respuesta que verá el usuario..."
                  value={respuesta}
                  onChange={e => setRespuesta(e.target.value)} />
                <small className="text-muted">Esta respuesta quedará registrada con tu nombre: <strong>{user.nombre} {user.apellido}</strong></small>
              </div>
            </div>
            <div className="modal-footer">
              <button className="btn btn-ghost" onClick={() => setSelected(null)}>Cancelar</button>
              <button className="btn btn-primary" disabled={saving} onClick={guardar}>
                {saving ? 'Guardando...' : '💾 Guardar Cambios'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
