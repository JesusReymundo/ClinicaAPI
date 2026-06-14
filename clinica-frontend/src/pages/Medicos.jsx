import { useEffect, useState, useCallback } from 'react';
import { getMedicos, createMedico, updateMedico, deleteMedico, getCitasMedico } from '../api/clinicaApi';

const emptyForm = { nombre: '', apellido: '', especialidad: '', colegioMedico: '', telefono: '' };

const ESPECIALIDADES = [
  'Cardiología','Pediatría','Ginecología','Traumatología','Neurología',
  'Dermatología','Oftalmología','Medicina General','Psiquiatría','Oncología',
  'Endocrinología','Gastroenterología','Neumología','Urología','Geriatría'
];

const ESP_COLORS = {
  'Cardiología':'#DC2626','Pediatría':'#0284C7','Ginecología':'#DB2777',
  'Traumatología':'#D97706','Neurología':'#7C3AED','Dermatología':'#059669',
  'Oftalmología':'#0891B2','Medicina General':'#6B21A8','Psiquiatría':'#65A30D',
  'Oncología':'#EA580C','Endocrinología':'#8B5CF6','Gastroenterología':'#14B8A6',
  'Neumología':'#3B82F6','Urología':'#F59E0B','Geriatría':'#6366F1',
};

const getEspColor = esp => ESP_COLORS[esp] || '#6B21A8';
const badgeE = e => ({ Pendiente:'badge badge-pendiente', Confirmada:'badge badge-confirmada', Cancelada:'badge badge-cancelada', Completada:'badge badge-completada', Anulada:'badge badge-anulada' }[e] || 'badge');
const fmtFecha = f => new Date(f).toLocaleString('es-PE', { day:'2-digit', month:'short', year:'numeric', hour:'2-digit', minute:'2-digit' });

export default function Medicos() {
  const [medicos, setMedicos]       = useState([]);
  const [loading, setLoading]       = useState(true);
  const [search, setSearch]         = useState('');
  const [filtroEsp, setFiltroEsp]   = useState('');
  const [vista, setVista]           = useState('cards'); // 'cards' | 'tabla'
  const [modal, setModal]           = useState(false);
  const [editing, setEditing]       = useState(null);
  const [form, setForm]             = useState(emptyForm);
  const [formError, setFormError]   = useState('');
  const [saving, setSaving]         = useState(false);
  const [drawer, setDrawer]         = useState(null);
  const [drawerCitas, setDrawerCitas] = useState([]);
  const [drawerLoading, setDrawerLoading] = useState(false);
  const [apiError, setApiError]     = useState('');

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const data = await getMedicos();
      setMedicos(data);
      setApiError('');
    } catch { setApiError('No se pudo conectar con la API.'); }
    finally { setLoading(false); }
  }, []);

  useEffect(() => { load(); }, [load]);

  const filtered = medicos.filter(m => {
    const texto = `${m.nombre} ${m.apellido} ${m.especialidad} ${m.colegioMedico}`.toLowerCase();
    return texto.includes(search.toLowerCase()) && (!filtroEsp || m.especialidad === filtroEsp);
  });

  const especialidadesExistentes = [...new Set(medicos.map(m => m.especialidad))].sort();

  const openCreate = () => { setEditing(null); setForm(emptyForm); setFormError(''); setModal(true); };
  const openEdit = m => {
    setEditing(m.id);
    setForm({ nombre: m.nombre, apellido: m.apellido, especialidad: m.especialidad, colegioMedico: m.colegioMedico, telefono: m.telefono || '' });
    setFormError(''); setModal(true);
  };

  const openDrawer = async m => {
    setDrawer(m); setDrawerCitas([]); setDrawerLoading(true);
    try { const citas = await getCitasMedico(m.id); setDrawerCitas(citas); }
    catch { setDrawerCitas([]); }
    finally { setDrawerLoading(false); }
  };

  const save = async () => {
    if (!form.nombre.trim() || !form.apellido.trim() || !form.especialidad || !form.colegioMedico.trim()) {
      setFormError('Todos los campos con * son obligatorios'); return;
    }
    setSaving(true);
    try {
      if (editing) await updateMedico(editing, form);
      else await createMedico(form);
      setModal(false); await load();
    } catch (e) { setFormError(e.response?.data?.message || e.response?.data?.detail || 'Error al guardar'); }
    finally { setSaving(false); }
  };

  const remove = async id => {
    if (!confirm('¿Eliminar este médico del sistema?')) return;
    try { await deleteMedico(id); await load(); if (drawer?.id === id) setDrawer(null); }
    catch (e) { alert(e.response?.data?.message || 'No se pudo eliminar'); }
  };

  const MedicoCard = ({ m }) => {
    const color = getEspColor(m.especialidad);
    const ini   = `${m.nombre[0]}${m.apellido[0]}`;
    const myColor = color + '22';
    return (
      <div className="medico-card">
        <div className="medico-card-top">
          <div className="medico-card-avatar" style={{ background: color }}>{ini}</div>
          <div className="medico-card-info">
            <div className="medico-card-name">Dr. {m.nombre} {m.apellido}</div>
            <div className="medico-card-esp">
              <span className="badge-specialty" style={{ background: myColor, color }}>{m.especialidad}</span>
            </div>
            <div className="medico-card-cmp">CMP · {m.colegioMedico}</div>
          </div>
        </div>
        <div className="medico-card-details">
          {m.telefono && <div className="medico-card-detail">📞 {m.telefono}</div>}
        </div>
        <div className="medico-card-actions">
          <button className="btn btn-info btn-sm" style={{ flex: 1 }} onClick={() => openDrawer(m)}>📋 Ver Perfil</button>
          <button className="btn btn-warning btn-sm" onClick={() => openEdit(m)}>✏️</button>
          <button className="btn btn-danger btn-sm" onClick={() => remove(m.id)}>🗑️</button>
        </div>
      </div>
    );
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">🩺 Médicos</h1>
          <p className="page-subtitle">Registro y gestión del personal médico</p>
        </div>
        <button className="btn btn-primary" onClick={openCreate}>+ Nuevo Médico</button>
      </div>

      {apiError && <div className="alert alert-error">⚠️ {apiError}</div>}

      <div className="table-card">
        <div className="table-toolbar">
          <div className="toolbar-left">
            <input className="search-input" placeholder="Buscar médico, especialidad, CMP..."
              value={search} onChange={e => setSearch(e.target.value)} />
            <select className="filter-select" value={filtroEsp} onChange={e => setFiltroEsp(e.target.value)}>
              <option value="">Todas las especialidades</option>
              {especialidadesExistentes.map(e => <option key={e}>{e}</option>)}
            </select>
          </div>
          <div className="toolbar-right">
            <span className="record-count">{filtered.length} médico(s)</span>
            <button className={`btn btn-sm ${vista === 'cards' ? 'btn-primary' : 'btn-ghost'}`} onClick={() => setVista('cards')}>⊞ Tarjetas</button>
            <button className={`btn btn-sm ${vista === 'tabla' ? 'btn-primary' : 'btn-ghost'}`} onClick={() => setVista('tabla')}>☰ Tabla</button>
          </div>
        </div>

        {loading ? (
          <div className="loading-wrap"><div className="spinner" /><div className="loading-text">Cargando médicos...</div></div>
        ) : filtered.length === 0 ? (
          <div className="empty-wrap">
            <div className="empty-icon">🩺</div>
            <div className="empty-text">{search ? 'Sin resultados para la búsqueda' : 'No hay médicos registrados'}</div>
            {!search && <button className="btn btn-primary btn-sm" onClick={openCreate}>Registrar primer médico</button>}
          </div>
        ) : vista === 'cards' ? (
          <div style={{ padding: 20 }}>
            <div className="medico-cards">
              {filtered.map(m => <MedicoCard key={m.id} m={m} />)}
            </div>
          </div>
        ) : (
          <table>
            <thead>
              <tr><th>#</th><th>Médico</th><th>Especialidad</th><th>N° Colegio</th><th>Teléfono</th><th>Acciones</th></tr>
            </thead>
            <tbody>
              {filtered.map(m => {
                const color = getEspColor(m.especialidad);
                return (
                  <tr key={m.id}>
                    <td className="text-muted text-sm">#{m.id}</td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                        <div style={{ width: 34, height: 34, borderRadius: '50%', background: color, color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 12, fontWeight: 700 }}>{m.nombre[0]}{m.apellido[0]}</div>
                        <div className="td-name">Dr. {m.nombre} {m.apellido}</div>
                      </div>
                    </td>
                    <td><span className="badge-specialty" style={{ background: color+'22', color }}>{m.especialidad}</span></td>
                    <td><span className="td-mono">{m.colegioMedico}</span></td>
                    <td>{m.telefono || <span className="text-muted">—</span>}</td>
                    <td>
                      <div className="actions">
                        <button className="btn btn-info btn-xs" onClick={() => openDrawer(m)}>📋 Perfil</button>
                        <button className="btn btn-warning btn-xs" onClick={() => openEdit(m)}>✏️</button>
                        <button className="btn btn-danger btn-xs" onClick={() => remove(m.id)}>🗑️</button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>

      {/* ── MODAL ── */}
      {modal && (
        <div className="modal-overlay" onClick={e => e.target === e.currentTarget && setModal(false)}>
          <div className="modal">
            <div className="modal-header">
              <h3>{editing ? '✏️ Editar Médico' : '➕ Nuevo Médico'}</h3>
              <button className="modal-close" onClick={() => setModal(false)}>✕</button>
            </div>
            <div className="modal-body">
              {formError && <div className="alert alert-error">⚠️ {formError}</div>}
              <div className="form-row">
                <div className="form-group">
                  <label>Nombre *</label>
                  <input value={form.nombre} onChange={e => setForm({...form, nombre: e.target.value})} placeholder="Ej: Carlos" />
                </div>
                <div className="form-group">
                  <label>Apellido *</label>
                  <input value={form.apellido} onChange={e => setForm({...form, apellido: e.target.value})} placeholder="Ej: García Ríos" />
                </div>
              </div>
              <div className="form-group">
                <label>Especialidad *</label>
                <select value={form.especialidad} onChange={e => setForm({...form, especialidad: e.target.value})}>
                  <option value="">Seleccionar especialidad</option>
                  {ESPECIALIDADES.map(e => <option key={e} value={e}>{e}</option>)}
                </select>
              </div>
              <div className="form-row">
                <div className="form-group">
                  <label>N° Colegio Médico *</label>
                  <input value={form.colegioMedico} onChange={e => setForm({...form, colegioMedico: e.target.value})} placeholder="CMP-12345" />
                  <div className="form-hint">Número de colegiatura médica (CMP)</div>
                </div>
                <div className="form-group">
                  <label>Teléfono de contacto</label>
                  <input value={form.telefono} onChange={e => setForm({...form, telefono: e.target.value})} placeholder="999 888 777" />
                </div>
              </div>
            </div>
            <div className="modal-footer">
              <button className="btn btn-cancel" onClick={() => setModal(false)}>Cancelar</button>
              <button className="btn btn-primary" onClick={save} disabled={saving}>
                {saving ? '⏳ Guardando...' : (editing ? '💾 Actualizar' : '✅ Registrar')}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ── DRAWER PERFIL MÉDICO ── */}
      {drawer && (
        <>
          <div className="drawer-overlay" onClick={() => setDrawer(null)} />
          <div className="drawer">
            <div className="drawer-header" style={{ background: `linear-gradient(135deg, #1e3a5f, ${getEspColor(drawer.especialidad)})` }}>
              <div>
                <div className="drawer-avatar" style={{ background: getEspColor(drawer.especialidad) }}>
                  {drawer.nombre[0]}{drawer.apellido[0]}
                </div>
                <div className="drawer-name">Dr. {drawer.nombre} {drawer.apellido}</div>
                <div className="drawer-sub">{drawer.especialidad} · CMP {drawer.colegioMedico}</div>
              </div>
              <button className="drawer-close" onClick={() => setDrawer(null)}>✕</button>
            </div>
            <div className="drawer-body">
              <div className="info-section">
                <div className="info-section-title">Datos Profesionales</div>
                <div className="info-row"><span className="info-label">Nombre completo</span><span className="info-value">Dr. {drawer.nombre} {drawer.apellido}</span></div>
                <div className="info-row"><span className="info-label">Especialidad</span>
                  <span className="info-value">
                    <span className="badge-specialty" style={{ background: getEspColor(drawer.especialidad)+'22', color: getEspColor(drawer.especialidad) }}>{drawer.especialidad}</span>
                  </span>
                </div>
                <div className="info-row"><span className="info-label">N° Colegio Médico</span><span className="info-value td-mono">{drawer.colegioMedico}</span></div>
                <div className="info-row"><span className="info-label">Teléfono</span><span className="info-value">{drawer.telefono || '—'}</span></div>
              </div>

              <div className="info-section">
                <div className="info-section-title">
                  Historial de Citas ({drawerCitas.length})
                  {drawerCitas.length > 0 && (
                    <span style={{ marginLeft: 8, fontSize: 11, fontWeight: 400, color: '#10B981' }}>
                      · {drawerCitas.filter(c => c.estado === 'Completada').length} completadas
                    </span>
                  )}
                </div>
              </div>
              {drawerLoading ? (
                <div className="loading-wrap" style={{ padding: 20 }}><div className="spinner" /><div className="loading-text">Cargando citas...</div></div>
              ) : drawerCitas.length === 0 ? (
                <div className="empty-wrap" style={{ padding: 20 }}><div className="empty-icon" style={{ fontSize: 28 }}>📭</div><div className="empty-text">Sin citas asignadas</div></div>
              ) : (
                drawerCitas.slice(0, 10).map(c => (
                  <div key={c.id} className="cita-hist-item">
                    <div className="cita-hist-dot" style={{ background: {Pendiente:'#F59E0B',Confirmada:'#3B82F6',Cancelada:'#EF4444',Completada:'#10B981',Anulada:'#F97316'}[c.estado] || '#94A3B8' }} />
                    <div className="cita-hist-info">
                      <div className="cita-hist-title">{c.nombrePaciente}</div>
                      <div className="cita-hist-meta">{fmtFecha(c.fechaHora)} · {c.motivo}</div>
                      <div className="cita-hist-meta" style={{ marginTop: 3 }}>
                        <span className={badgeE(c.estado)} style={{ display:'inline-flex', fontSize:10 }}>{c.estado}</span>
                      </div>
                    </div>
                  </div>
                ))
              )}

              <div style={{ padding: 16, display: 'flex', gap: 8 }}>
                <button className="btn btn-warning btn-sm" style={{ flex: 1 }} onClick={() => { setDrawer(null); openEdit(drawer); }}>✏️ Editar</button>
                <button className="btn btn-danger btn-sm" style={{ flex: 1 }} onClick={() => remove(drawer.id)}>🗑️ Eliminar</button>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
