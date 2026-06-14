import { useEffect, useState, useCallback } from 'react';
import { useAuth } from '../context/AuthContext';
import { getCitas, getCitasMedico, getCitasPaciente, getPacientes, getMedicos, createCita, updateCita, cancelarCita, anularCita, deleteCita } from '../api/clinicaApi';

const emptyForm = { pacienteId: '', medicoId: '', fechaHora: '', motivo: '', observaciones: '', estado: 'Pendiente' };
const ESTADOS   = ['Pendiente','Confirmada','Completada','Cancelada','Anulada'];
const BADGE     = { Pendiente:'badge badge-pendiente', Confirmada:'badge badge-confirmada', Cancelada:'badge badge-cancelada', Completada:'badge badge-completada', Anulada:'badge badge-anulada' };
const BADGE_DOT = { Pendiente:'#F59E0B', Confirmada:'#3B82F6', Cancelada:'#EF4444', Completada:'#10B981', Anulada:'#F97316' };

const fmtFecha = f => new Date(f).toLocaleString('es-PE', { day:'2-digit', month:'short', year:'numeric', hour:'2-digit', minute:'2-digit' });
const localDT  = () => { const d = new Date(); d.setMinutes(d.getMinutes() + 30 - d.getTimezoneOffset()); return d.toISOString().slice(0,16); };
const toLocalDT= f => { const d = new Date(f); d.setMinutes(d.getMinutes()-d.getTimezoneOffset()); return d.toISOString().slice(0,16); };

export default function Citas() {
  const { user } = useAuth();
  const [citas, setCitas]           = useState([]);
  const [pacientes, setPacientes]   = useState([]);
  const [medicos, setMedicos]       = useState([]);
  const [loading, setLoading]       = useState(true);
  const [tab, setTab]               = useState('Todas');
  const [search, setSearch]         = useState('');
  const [modal, setModal]           = useState(false);
  const [editing, setEditing]       = useState(null);
  const [form, setForm]             = useState(emptyForm);
  const [formError, setFormError]   = useState('');
  const [saving, setSaving]         = useState(false);
  const [drawer, setDrawer]         = useState(null);
  const [apiError, setApiError]     = useState('');
  const [confirming, setConfirming] = useState(null); // id de cita siendo procesada

  const load = useCallback(async () => {
    setLoading(true);
    try {
      let citasData;
      if (user.role === 'doctor' && user.medicoId)       citasData = await getCitasMedico(user.medicoId);
      else if (user.role === 'paciente' && user.pacienteId) citasData = await getCitasPaciente(user.pacienteId);
      else                                                    citasData = await getCitas();

      const [pacs, meds] = await Promise.all([getPacientes(), getMedicos()]);
      setCitas(citasData);
      setPacientes(pacs);
      setMedicos(meds);
      setApiError('');
    } catch { setApiError('No se pudo conectar con la API. Asegúrate de que esté corriendo en el puerto 5024.'); }
    finally { setLoading(false); }
  }, [user]);

  useEffect(() => { load(); }, [load]);

  const counts = ESTADOS.reduce((acc, e) => { acc[e] = citas.filter(c => c.estado === e).length; return acc; }, {});

  const filtered = citas.filter(c => {
    const matchTab  = tab === 'Todas' || c.estado === tab;
    const matchText = !search || `${c.nombrePaciente} ${c.nombreMedico} ${c.motivo} ${c.especialidadMedico}`.toLowerCase().includes(search.toLowerCase());
    return matchTab && matchText;
  });

  const openCreate = () => {
    setEditing(null);
    setForm({ ...emptyForm, fechaHora: localDT() });
    setFormError(''); setModal(true);
  };
  const openEdit = c => {
    setEditing(c.id);
    setForm({ pacienteId: c.pacienteId, medicoId: c.medicoId, fechaHora: toLocalDT(c.fechaHora), motivo: c.motivo, observaciones: c.observaciones || '', estado: c.estado });
    setFormError(''); setModal(true);
  };

  const save = async () => {
    if (!form.pacienteId || !form.medicoId) { setFormError('Seleccione paciente y médico'); return; }
    if (!form.fechaHora) { setFormError('Seleccione fecha y hora'); return; }
    if (!form.motivo.trim() || form.motivo.trim().length < 5) { setFormError('El motivo debe tener al menos 5 caracteres'); return; }
    setSaving(true);
    try {
      const payload = { pacienteId: Number(form.pacienteId), medicoId: Number(form.medicoId), fechaHora: new Date(form.fechaHora).toISOString(), motivo: form.motivo, observaciones: form.observaciones || null };
      if (editing) await updateCita(editing, { ...payload, estado: form.estado });
      else await createCita(payload);
      setModal(false); await load();
    } catch (e) { setFormError(e.response?.data?.message || e.response?.data?.detail || 'Error al guardar'); }
    finally { setSaving(false); }
  };

  const accionEstado = async (id, accion) => {
    setConfirming(id);
    try {
      if (accion === 'cancelar') {
        await cancelarCita(id);
      } else if (accion === 'anular') {
        await anularCita(id);
      } else {
        const cita = citas.find(c => c.id === id);
        const nuevoEstado = accion === 'confirmar' ? 'Confirmada' : 'Completada';
        await updateCita(id, {
          pacienteId: cita.pacienteId, medicoId: cita.medicoId,
          fechaHora: new Date(cita.fechaHora).toISOString(),
          motivo: cita.motivo, observaciones: cita.observaciones || null, estado: nuevoEstado
        });
      }
      await load();
    } catch (e) { alert(e.response?.data?.message || 'Error al actualizar estado'); }
    finally { setConfirming(null); }
  };

  const remove = async id => {
    if (!confirm('¿Eliminar esta cita permanentemente?')) return;
    try { await deleteCita(id); await load(); if (drawer?.id === id) setDrawer(null); }
    catch (e) { alert(e.response?.data?.message || 'Error al eliminar'); }
  };

  const AccionesCita = ({ c }) => {
    const busy = confirming === c.id;
    const esFinal = c.estado === 'Cancelada' || c.estado === 'Completada' || c.estado === 'Anulada';
    if (esFinal) {
      return (
        <div className="actions">
          <button className="btn btn-ghost btn-xs" onClick={() => setDrawer(c)}>Ver</button>
          <button className="btn btn-danger btn-xs" onClick={() => remove(c.id)} disabled={busy}>🗑️</button>
        </div>
      );
    }
    return (
      <div className="actions">
        {c.estado === 'Pendiente' && user.role !== 'paciente' && (
          <button className="btn btn-info btn-xs" onClick={() => accionEstado(c.id, 'confirmar')} disabled={busy}>
            {busy ? '...' : '✔ Confirmar'}
          </button>
        )}
        {c.estado === 'Confirmada' && user.role !== 'paciente' && (
          <button className="btn btn-success btn-xs" onClick={() => accionEstado(c.id, 'completar')} disabled={busy}>
            {busy ? '...' : '✅ Completar'}
          </button>
        )}
        {user.role !== 'paciente' && (
          <>
            <button className="btn btn-warning btn-xs" onClick={() => openEdit(c)} disabled={busy}>✏️</button>
            <button className="btn btn-cancel btn-xs" onClick={() => accionEstado(c.id, 'cancelar')} disabled={busy} title="Cancelar (clínica)">✕</button>
          </>
        )}
        {user.role === 'paciente' && (
          <button className="btn btn-cancel btn-xs" onClick={() => accionEstado(c.id, 'anular')} disabled={busy} title="Anular mi cita">⊘ Anular</button>
        )}
        <button className="btn btn-danger btn-xs" onClick={() => remove(c.id)} disabled={busy}>🗑️</button>
      </div>
    );
  };

  const tituloPage = user.role === 'doctor' ? '📅 Mis Citas' : user.role === 'paciente' ? '📅 Mis Citas Médicas' : '📅 Gestión de Citas';

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">{tituloPage}</h1>
          <p className="page-subtitle">Administre y controle el estado de las citas médicas</p>
        </div>
        {user.role !== 'doctor' && (
          <button className="btn btn-primary" onClick={openCreate}>+ Nueva Cita</button>
        )}
      </div>

      {apiError && <div className="alert alert-error">⚠️ {apiError}</div>}

      {/* Tabs de estado */}
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
        <div className="table-toolbar">
          <div className="toolbar-left">
            <input className="search-input" placeholder="Buscar por paciente, médico, motivo..."
              value={search} onChange={e => setSearch(e.target.value)} />
          </div>
          <div className="toolbar-right">
            <span className="record-count">{filtered.length} cita(s)</span>
            <button className="btn btn-ghost btn-sm" onClick={load}>↻ Actualizar</button>
          </div>
        </div>

        {loading ? (
          <div className="loading-wrap"><div className="spinner" /><div className="loading-text">Cargando citas...</div></div>
        ) : filtered.length === 0 ? (
          <div className="empty-wrap">
            <div className="empty-icon">📭</div>
            <div className="empty-text">{search ? 'Sin resultados' : tab !== 'Todas' ? `No hay citas ${tab.toLowerCase()}s` : 'No hay citas registradas'}</div>
            {tab === 'Todas' && !search && <button className="btn btn-primary btn-sm" onClick={openCreate}>Crear primera cita</button>}
          </div>
        ) : (
          <table>
            <thead>
              <tr>
                <th>#</th>
                <th>Paciente</th>
                <th>Médico</th>
                <th>Fecha y Hora</th>
                <th>Motivo</th>
                <th>Observaciones</th>
                <th>Estado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map(c => (
                <tr key={c.id}>
                  <td className="text-muted text-sm">#{c.id}</td>
                  <td>
                    <div className="td-name">{c.nombrePaciente}</div>
                  </td>
                  <td>
                    <div className="td-name">{c.nombreMedico}</div>
                    <div className="td-sub">{c.especialidadMedico}</div>
                  </td>
                  <td style={{ whiteSpace: 'nowrap', fontSize: 12 }}>
                    {fmtFecha(c.fechaHora)}
                  </td>
                  <td style={{ maxWidth: 160, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', fontSize: 12 }}>
                    {c.motivo}
                  </td>
                  <td style={{ maxWidth: 140, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', fontSize: 12, color: '#94A3B8' }}>
                    {c.observaciones || '—'}
                  </td>
                  <td>
                    <span className={BADGE[c.estado] || 'badge'}>{c.estado}</span>
                  </td>
                  <td>
                    <AccionesCita c={c} />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* ── MODAL CREAR / EDITAR ── */}
      {modal && (
        <div className="modal-overlay" onClick={e => e.target === e.currentTarget && setModal(false)}>
          <div className="modal">
            <div className="modal-header">
              <h3>{editing ? '✏️ Editar Cita' : '📅 Nueva Cita Médica'}</h3>
              <button className="modal-close" onClick={() => setModal(false)}>✕</button>
            </div>
            <div className="modal-body">
              {formError && <div className="alert alert-error">⚠️ {formError}</div>}

              <div className="form-row">
                <div className="form-group">
                  <label>Paciente *</label>
                  <select value={form.pacienteId} onChange={e => setForm({...form, pacienteId: e.target.value})}>
                    <option value="">Seleccionar paciente</option>
                    {pacientes.map(p => <option key={p.id} value={p.id}>{p.nombre} {p.apellido} — DNI {p.dni}</option>)}
                  </select>
                </div>
                <div className="form-group">
                  <label>Médico *</label>
                  <select value={form.medicoId} onChange={e => setForm({...form, medicoId: e.target.value})}>
                    <option value="">Seleccionar médico</option>
                    {medicos.map(m => <option key={m.id} value={m.id}>Dr. {m.nombre} {m.apellido} — {m.especialidad}</option>)}
                  </select>
                </div>
              </div>

              <div className="form-group">
                <label>Fecha y Hora de la Cita *</label>
                <input type="datetime-local" value={form.fechaHora} onChange={e => setForm({...form, fechaHora: e.target.value})}
                  min={new Date().toISOString().slice(0,16)} />
                <div className="form-hint">La cita debe ser en una fecha futura</div>
              </div>

              <div className="form-group">
                <label>Motivo de Consulta *</label>
                <input value={form.motivo} onChange={e => setForm({...form, motivo: e.target.value})}
                  placeholder="Ej: Dolor de cabeza persistente, control rutinario..." />
                <div className="form-hint">Mínimo 5 caracteres</div>
              </div>

              <div className="form-group">
                <label>Observaciones adicionales</label>
                <textarea rows={2} value={form.observaciones} onChange={e => setForm({...form, observaciones: e.target.value})}
                  placeholder="Información adicional relevante para el médico..." />
              </div>

              {editing && (
                <div className="form-group">
                  <label>Estado de la cita</label>
                  <select value={form.estado} onChange={e => setForm({...form, estado: e.target.value})}>
                    {ESTADOS.map(e => <option key={e} value={e}>{e}</option>)}
                  </select>
                </div>
              )}
            </div>
            <div className="modal-footer">
              <button className="btn btn-cancel" onClick={() => setModal(false)}>Cancelar</button>
              <button className="btn btn-primary" onClick={save} disabled={saving}>
                {saving ? '⏳ Guardando...' : (editing ? '💾 Actualizar Cita' : '✅ Registrar Cita')}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ── DRAWER DETALLE CITA ── */}
      {drawer && (
        <>
          <div className="drawer-overlay" onClick={() => setDrawer(null)} />
          <div className="drawer">
            <div className="drawer-header">
              <div>
                <div className="drawer-avatar" style={{ background: BADGE_DOT[drawer.estado] }}>📅</div>
                <div className="drawer-name">Cita #{drawer.id}</div>
                <div className="drawer-sub">{fmtFecha(drawer.fechaHora)}</div>
              </div>
              <button className="drawer-close" onClick={() => setDrawer(null)}>✕</button>
            </div>
            <div className="drawer-body">
              <div className="info-section">
                <div className="info-section-title">Estado</div>
                <div style={{ padding: '8px 0' }}>
                  <span className={BADGE[drawer.estado] || 'badge'} style={{ fontSize: 14, padding: '6px 16px' }}>{drawer.estado}</span>
                </div>
              </div>
              <div className="info-section">
                <div className="info-section-title">Paciente</div>
                <div className="info-row"><span className="info-label">Nombre</span><span className="info-value">{drawer.nombrePaciente}</span></div>
              </div>
              <div className="info-section">
                <div className="info-section-title">Médico</div>
                <div className="info-row"><span className="info-label">Nombre</span><span className="info-value">{drawer.nombreMedico}</span></div>
                <div className="info-row"><span className="info-label">Especialidad</span><span className="info-value">{drawer.especialidadMedico}</span></div>
              </div>
              <div className="info-section">
                <div className="info-section-title">Detalle de la Cita</div>
                <div className="info-row"><span className="info-label">Fecha y Hora</span><span className="info-value" style={{ fontSize: 12 }}>{fmtFecha(drawer.fechaHora)}</span></div>
                <div className="info-row"><span className="info-label">Motivo</span><span className="info-value" style={{ fontSize: 12 }}>{drawer.motivo}</span></div>
                {drawer.observaciones && <div className="info-row"><span className="info-label">Observaciones</span><span className="info-value" style={{ fontSize: 12 }}>{drawer.observaciones}</span></div>}
              </div>
              <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 8 }}>
                {user.role !== 'paciente' && drawer.estado === 'Pendiente' && (
                  <button className="btn btn-info" onClick={() => { accionEstado(drawer.id, 'confirmar'); setDrawer(null); }}>✔ Confirmar Cita</button>
                )}
                {user.role !== 'paciente' && drawer.estado === 'Confirmada' && (
                  <button className="btn btn-success" onClick={() => { accionEstado(drawer.id, 'completar'); setDrawer(null); }}>✅ Marcar Completada</button>
                )}
                {user.role !== 'paciente' && (drawer.estado === 'Pendiente' || drawer.estado === 'Confirmada') && (
                  <button className="btn btn-cancel" onClick={() => { accionEstado(drawer.id, 'cancelar'); setDrawer(null); }} title="Cancelar (clínica — el paciente no llegó)">✕ Cancelar Cita</button>
                )}
                {user.role === 'paciente' && (drawer.estado === 'Pendiente' || drawer.estado === 'Confirmada') && (
                  <button className="btn btn-cancel" onClick={() => { accionEstado(drawer.id, 'anular'); setDrawer(null); }} title="Anular mi cita">⊘ Anular mi Cita</button>
                )}
                <button className="btn btn-danger" onClick={() => { remove(drawer.id); setDrawer(null); }}>🗑️ Eliminar Cita</button>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
