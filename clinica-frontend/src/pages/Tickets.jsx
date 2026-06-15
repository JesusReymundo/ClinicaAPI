import { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';

const LS_KEY = 'clinica_tickets';
const CATEGORIAS = [
  'Problema con mi cita',
  'Datos incorrectos en mi perfil',
  'Error en el sistema',
  'Médico no disponible',
  'Problema con mi boleta',
  'Solicitud de información',
  'Otro',
];
const PRIORIDADES = ['Baja','Media','Alta'];
const BADGE_ESTADO = {
  'Abierto':     'badge badge-pendiente',
  'En proceso':  'badge badge-confirmada',
  'Resuelto':    'badge badge-completada',
  'Cerrado':     'badge badge-cancelada',
};

function getTickets() {
  try { return JSON.parse(localStorage.getItem(LS_KEY) || '[]'); } catch { return []; }
}
function saveTickets(arr) {
  localStorage.setItem(LS_KEY, JSON.stringify(arr));
}

const fmtFecha = d => new Date(d).toLocaleString('es-PE', {
  day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit',
});

export default function Tickets() {
  const { user } = useAuth();
  const [tickets, setTickets]       = useState([]);
  const [modal, setModal]           = useState(false);
  const [form, setForm]             = useState({ categoria: '', descripcion: '', prioridad: 'Media' });
  const [formError, setFormError]   = useState('');
  const [saving, setSaving]         = useState(false);
  const [success, setSuccess]       = useState('');
  const [filtro, setFiltro]         = useState('Todos');

  useEffect(() => {
    const all = getTickets();
    setTickets(all.filter(t => t.usuarioId === user.id));
  }, [user.id]);

  const reload = () => {
    const all = getTickets();
    setTickets(all.filter(t => t.usuarioId === user.id));
  };

  const crear = () => {
    if (!form.categoria) { setFormError('Selecciona una categoría'); return; }
    if (!form.descripcion.trim() || form.descripcion.trim().length < 10) {
      setFormError('La descripción debe tener al menos 10 caracteres'); return;
    }
    setSaving(true);
    const all = getTickets();
    const nuevo = {
      id: Date.now(),
      usuarioId: user.id,
      usuarioNombre: `${user.nombre} ${user.apellido}`,
      usuarioRol: user.role,
      categoria: form.categoria,
      descripcion: form.descripcion.trim(),
      prioridad: form.prioridad,
      estado: 'Abierto',
      fechaCreacion: new Date().toISOString(),
      respuesta: null,
      fechaRespuesta: null,
    };
    all.push(nuevo);
    saveTickets(all);
    setModal(false);
    setForm({ categoria: '', descripcion: '', prioridad: 'Media' });
    setFormError('');
    setSaving(false);
    setSuccess('Ticket enviado correctamente. El equipo lo atenderá a la brevedad.');
    setTimeout(() => setSuccess(''), 5000);
    reload();
  };

  const filtered = filtro === 'Todos' ? tickets : tickets.filter(t => t.estado === filtro);

  const PRIORIDAD_COLOR = { Baja: '#059669', Media: '#D97706', Alta: '#DC2626' };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">🎫 Reportar Problema</h1>
          <p className="page-subtitle">Crea un ticket de soporte y recibe atención del equipo administrativo</p>
        </div>
        <button className="btn btn-primary" onClick={() => { setModal(true); setFormError(''); }}>
          + Nuevo Ticket
        </button>
      </div>

      {success && <div className="alert alert-success">✅ {success}</div>}

      <div className="tab-bar">
        {['Todos','Abierto','En proceso','Resuelto','Cerrado'].map(f => (
          <button key={f} className={`tab ${filtro === f ? 'active' : ''}`} onClick={() => setFiltro(f)}>
            {f} <span className="tab-count">{(f === 'Todos' ? tickets : tickets.filter(t => t.estado === f)).length}</span>
          </button>
        ))}
      </div>

      <div className="table-card">
        {filtered.length === 0 ? (
          <div className="empty-wrap">
            <div className="empty-icon">🎫</div>
            <div className="empty-text">
              {tickets.length === 0
                ? 'No tienes tickets abiertos. Si tienes algún problema, crea uno arriba.'
                : 'No hay tickets con ese filtro.'}
            </div>
          </div>
        ) : (
          <div className="tickets-list">
            {filtered.map(t => (
              <div key={t.id} className="ticket-item">
                <div className="ticket-header">
                  <div className="ticket-id">#{t.id}</div>
                  <div className="ticket-cat">{t.categoria}</div>
                  <span className={BADGE_ESTADO[t.estado] || 'badge'}>{t.estado}</span>
                  <span style={{ fontSize: 12, fontWeight: 700, color: PRIORIDAD_COLOR[t.prioridad] }}>
                    ● {t.prioridad}
                  </span>
                  <div className="ticket-fecha text-muted text-sm">{fmtFecha(t.fechaCreacion)}</div>
                </div>
                <div className="ticket-desc">{t.descripcion}</div>
                {t.respuesta && (
                  <div className="ticket-respuesta">
                    <strong>Respuesta del equipo:</strong>
                    <p>{t.respuesta}</p>
                    <small className="text-muted">{fmtFecha(t.fechaRespuesta)}</small>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Modal crear ticket */}
      {modal && (
        <div className="modal-overlay" onClick={() => setModal(false)}>
          <div className="modal-box" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h2 className="modal-title">🎫 Crear Ticket de Soporte</h2>
              <button className="modal-close" onClick={() => setModal(false)}>✕</button>
            </div>
            <div className="modal-body">
              {formError && <div className="alert alert-error">⚠️ {formError}</div>}

              <div className="form-group">
                <label className="form-label">Categoría del problema *</label>
                <select className="form-control" value={form.categoria}
                  onChange={e => setForm(f => ({ ...f, categoria: e.target.value }))}>
                  <option value="">— Selecciona una categoría —</option>
                  {CATEGORIAS.map(c => <option key={c}>{c}</option>)}
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Prioridad</label>
                <div style={{ display: 'flex', gap: 8 }}>
                  {PRIORIDADES.map(p => (
                    <button key={p}
                      className={`hora-btn ${form.prioridad === p ? 'selected' : ''}`}
                      style={{ flex: 1, color: form.prioridad === p ? 'white' : PRIORIDAD_COLOR[p],
                               background: form.prioridad === p ? PRIORIDAD_COLOR[p] : undefined }}
                      onClick={() => setForm(f => ({ ...f, prioridad: p }))}>
                      {p}
                    </button>
                  ))}
                </div>
              </div>

              <div className="form-group">
                <label className="form-label">Descripción del problema *</label>
                <textarea className="form-control" rows={5}
                  placeholder="Describe el problema con el mayor detalle posible..."
                  value={form.descripcion}
                  onChange={e => setForm(f => ({ ...f, descripcion: e.target.value }))} />
                <small className="text-muted">{form.descripcion.length} caracteres (mín. 10)</small>
              </div>
            </div>
            <div className="modal-footer">
              <button className="btn btn-ghost" onClick={() => setModal(false)}>Cancelar</button>
              <button className="btn btn-primary" disabled={saving} onClick={crear}>
                {saving ? 'Enviando...' : '📤 Enviar Ticket'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
