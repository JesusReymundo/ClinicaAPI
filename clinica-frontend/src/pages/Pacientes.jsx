import { useEffect, useState, useCallback } from 'react';
import { getPacientes, getPaciente, createPaciente, updatePaciente, deletePaciente, getCitasPaciente } from '../api/clinicaApi';

const emptyForm = { nombre: '', apellido: '', dni: '', fechaNacimiento: '', telefono: '', email: '', grupoSanguineo: '', alergias: '' };
const badgeE = e => ({ Pendiente: 'badge badge-pendiente', Confirmada: 'badge badge-confirmada', Cancelada: 'badge badge-cancelada', Completada: 'badge badge-completada', Anulada: 'badge badge-anulada' }[e] || 'badge');
const calcEdad = f => { if (!f || f === '0001-01-01') return '—'; const d = new Date(f); if (isNaN(d)) return '—'; let e = new Date().getFullYear()-d.getFullYear(); return e > 0 ? `${e} años` : '—'; };
const fmtFecha = f => new Date(f).toLocaleString('es-PE', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
const fmtDate  = f => { if (!f || f.startsWith('0001')) return '—'; return new Date(f).toLocaleDateString('es-PE', { day: '2-digit', month: 'long', year: 'numeric' }); };
const colors   = ['#6B21A8','#0284C7','#059669','#D97706','#DC2626','#7C3AED','#0891B2'];
const getColor = name => colors[(name.charCodeAt(0) + (name.charCodeAt(1) || 0)) % colors.length];

const GRUPOS_SANG = ['A+','A-','B+','B-','AB+','AB-','O+','O-'];

export default function Pacientes() {
  const [pacientes, setPacientes]     = useState([]);
  const [loading, setLoading]         = useState(true);
  const [search, setSearch]           = useState('');
  const [filtroGrupo, setFiltroGrupo] = useState('');
  const [modal, setModal]             = useState(false);
  const [editing, setEditing]         = useState(null);
  const [form, setForm]               = useState(emptyForm);
  const [formError, setFormError]     = useState('');
  const [saving, setSaving]           = useState(false);
  const [drawer, setDrawer]           = useState(null);
  const [drawerCitas, setDrawerCitas] = useState([]);
  const [drawerLoading, setDrawerLoading] = useState(false);
  const [apiError, setApiError]       = useState('');

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const data = await getPacientes();
      setPacientes(data);
      setApiError('');
    } catch {
      setApiError('No se pudo conectar con la API. Asegúrate de que la API esté corriendo en el puerto 5024.');
    } finally { setLoading(false); }
  }, []);

  useEffect(() => { load(); }, [load]);

  const filtered = pacientes.filter(p => {
    const texto = `${p.nombre} ${p.apellido} ${p.dni} ${p.email} ${p.telefono}`.toLowerCase();
    const matchText = texto.includes(search.toLowerCase());
    const matchGrupo = !filtroGrupo || p.grupoSanguineo === filtroGrupo;
    return matchText && matchGrupo;
  });

  const openCreate = () => { setEditing(null); setForm(emptyForm); setFormError(''); setModal(true); };
  const openEdit   = p => {
    setEditing(p.id);
    setForm({ nombre: p.nombre, apellido: p.apellido, dni: p.dni,
               fechaNacimiento: p.fechaNacimiento?.slice(0,10) || '',
               telefono: p.telefono || '', email: p.email || '',
               grupoSanguineo: p.grupoSanguineo || '', alergias: p.alergias || '' });
    setFormError(''); setModal(true);
  };

  const openDrawer = async p => {
    setDrawer(p); setDrawerCitas([]); setDrawerLoading(true);
    try { const citas = await getCitasPaciente(p.id); setDrawerCitas(citas); }
    catch { setDrawerCitas([]); }
    finally { setDrawerLoading(false); }
  };

  const save = async () => {
    if (!form.nombre.trim() || !form.apellido.trim() || !form.dni.trim()) { setFormError('Nombre, apellido y DNI son obligatorios'); return; }
    if (!/^\d{8}$/.test(form.dni)) { setFormError('El DNI debe tener exactamente 8 dígitos'); return; }
    if (!form.fechaNacimiento) { setFormError('La fecha de nacimiento es obligatoria'); return; }
    setSaving(true);
    try {
      const payload = { ...form };
      if (editing) await updatePaciente(editing, payload);
      else await createPaciente(payload);
      setModal(false); await load();
    } catch (e) { setFormError(e.response?.data?.message || e.response?.data?.detail || 'Error al guardar'); }
    finally { setSaving(false); }
  };

  const remove = async id => {
    if (!confirm('¿Desea eliminar permanentemente este paciente y todos sus datos?')) return;
    try { await deletePaciente(id); await load(); if (drawer?.id === id) setDrawer(null); }
    catch (e) { alert(e.response?.data?.message || 'No se pudo eliminar'); }
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">👥 Pacientes</h1>
          <p className="page-subtitle">Gestión completa del registro de pacientes</p>
        </div>
        <button className="btn btn-primary" onClick={openCreate}>+ Nuevo Paciente</button>
      </div>

      {apiError && <div className="alert alert-error">⚠️ {apiError}</div>}

      <div className="table-card">
        <div className="table-toolbar">
          <div className="toolbar-left">
            <input className="search-input" placeholder="Buscar por nombre, DNI, email..."
              value={search} onChange={e => setSearch(e.target.value)} />
            <select className="filter-select" value={filtroGrupo} onChange={e => setFiltroGrupo(e.target.value)}>
              <option value="">Todos los grupos</option>
              {GRUPOS_SANG.map(g => <option key={g}>{g}</option>)}
            </select>
          </div>
          <div className="toolbar-right">
            <span className="record-count">{filtered.length} paciente(s)</span>
            <button className="btn btn-ghost btn-sm" onClick={load}>↻ Actualizar</button>
          </div>
        </div>

        {loading ? (
          <div className="loading-wrap"><div className="spinner" /><div className="loading-text">Cargando pacientes...</div></div>
        ) : filtered.length === 0 ? (
          <div className="empty-wrap">
            <div className="empty-icon">👤</div>
            <div className="empty-text">{search ? 'No se encontraron resultados' : 'No hay pacientes registrados aún'}</div>
            {!search && <button className="btn btn-primary btn-sm" onClick={openCreate}>Registrar primer paciente</button>}
          </div>
        ) : (
          <table>
            <thead>
              <tr><th>#</th><th>Paciente</th><th>DNI</th><th>Edad</th><th>Teléfono</th><th>Email</th><th>Grupo Sang.</th><th>Alergias</th><th>Acciones</th></tr>
            </thead>
            <tbody>
              {filtered.map(p => {
                const color = getColor(p.nombre);
                const ini = `${p.nombre[0]}${p.apellido[0]}`;
                return (
                  <tr key={p.id}>
                    <td className="text-muted text-sm">#{p.id}</td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                        <div style={{ width: 34, height: 34, borderRadius: '50%', background: color, color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 12, fontWeight: 700, flexShrink: 0 }}>{ini}</div>
                        <div>
                          <div className="td-name">{p.nombre} {p.apellido}</div>
                          <div className="td-sub">{fmtDate(p.fechaNacimiento)}</div>
                        </div>
                      </div>
                    </td>
                    <td><span className="td-mono">{p.dni}</span></td>
                    <td>{calcEdad(p.fechaNacimiento)}</td>
                    <td>{p.telefono || <span className="text-muted">—</span>}</td>
                    <td style={{ fontSize: 12 }}>{p.email || <span className="text-muted">—</span>}</td>
                    <td>
                      {p.grupoSanguineo
                        ? <span style={{ background: '#FEF3C7', color: '#92400E', padding: '2px 8px', borderRadius: 20, fontSize: 12, fontWeight: 700 }}>{p.grupoSanguineo}</span>
                        : <span className="text-muted">—</span>}
                    </td>
                    <td style={{ maxWidth: 120, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', fontSize: 12 }}>
                      {p.alergias || <span className="text-muted">Ninguna</span>}
                    </td>
                    <td>
                      <div className="actions">
                        <button className="btn btn-info btn-xs" onClick={() => openDrawer(p)}>📋 Ficha</button>
                        <button className="btn btn-warning btn-xs" onClick={() => openEdit(p)}>✏️</button>
                        <button className="btn btn-danger btn-xs" onClick={() => remove(p.id)}>🗑️</button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>

      {/* ── MODAL CREAR/EDITAR ── */}
      {modal && (
        <div className="modal-overlay" onClick={e => e.target === e.currentTarget && setModal(false)}>
          <div className="modal">
            <div className="modal-header">
              <h3>{editing ? '✏️ Editar Paciente' : '➕ Nuevo Paciente'}</h3>
              <button className="modal-close" onClick={() => setModal(false)}>✕</button>
            </div>
            <div className="modal-body">
              {formError && <div className="alert alert-error">⚠️ {formError}</div>}
              <div style={{ fontSize: 11, fontWeight: 700, color: '#94A3B8', textTransform: 'uppercase', letterSpacing: 1, marginBottom: 12 }}>Datos Personales</div>
              <div className="form-row">
                <div className="form-group">
                  <label>Nombre *</label>
                  <input value={form.nombre} onChange={e => setForm({...form, nombre: e.target.value})} placeholder="Ej: Juan Carlos" />
                </div>
                <div className="form-group">
                  <label>Apellido *</label>
                  <input value={form.apellido} onChange={e => setForm({...form, apellido: e.target.value})} placeholder="Ej: Pérez García" />
                </div>
              </div>
              <div className="form-row">
                <div className="form-group">
                  <label>DNI * (8 dígitos)</label>
                  <input value={form.dni} onChange={e => setForm({...form, dni: e.target.value.replace(/\D/g,'')})} placeholder="12345678" maxLength={8} />
                </div>
                <div className="form-group">
                  <label>Fecha de Nacimiento *</label>
                  <input type="date" value={form.fechaNacimiento} onChange={e => setForm({...form, fechaNacimiento: e.target.value})} max={new Date().toISOString().slice(0,10)} />
                </div>
              </div>
              <div style={{ fontSize: 11, fontWeight: 700, color: '#94A3B8', textTransform: 'uppercase', letterSpacing: 1, margin: '16px 0 12px' }}>Contacto</div>
              <div className="form-row">
                <div className="form-group">
                  <label>Teléfono</label>
                  <input value={form.telefono} onChange={e => setForm({...form, telefono: e.target.value})} placeholder="999 888 777" />
                </div>
                <div className="form-group">
                  <label>Email</label>
                  <input type="email" value={form.email} onChange={e => setForm({...form, email: e.target.value})} placeholder="correo@ejemplo.com" />
                </div>
              </div>
              <div style={{ fontSize: 11, fontWeight: 700, color: '#94A3B8', textTransform: 'uppercase', letterSpacing: 1, margin: '16px 0 12px' }}>Información Médica</div>
              <div className="form-row">
                <div className="form-group">
                  <label>Grupo Sanguíneo</label>
                  <select value={form.grupoSanguineo} onChange={e => setForm({...form, grupoSanguineo: e.target.value})}>
                    <option value="">No especificado</option>
                    {GRUPOS_SANG.map(g => <option key={g} value={g}>{g}</option>)}
                  </select>
                </div>
                <div className="form-group">
                  <label>Alergias conocidas</label>
                  <input value={form.alergias} onChange={e => setForm({...form, alergias: e.target.value})} placeholder="Ej: Penicilina, Polen..." />
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

      {/* ── DRAWER FICHA DEL PACIENTE ── */}
      {drawer && (
        <>
          <div className="drawer-overlay" onClick={() => setDrawer(null)} />
          <div className="drawer">
            <div className="drawer-header">
              <div>
                <div className="drawer-avatar" style={{ background: getColor(drawer.nombre) }}>
                  {drawer.nombre[0]}{drawer.apellido[0]}
                </div>
                <div className="drawer-name">{drawer.nombre} {drawer.apellido}</div>
                <div className="drawer-sub">Paciente · ID #{drawer.id} · DNI {drawer.dni}</div>
              </div>
              <button className="drawer-close" onClick={() => setDrawer(null)}>✕</button>
            </div>
            <div className="drawer-body">
              <div className="info-section">
                <div className="info-section-title">Datos Personales</div>
                <div className="info-row"><span className="info-label">Nombre completo</span><span className="info-value">{drawer.nombre} {drawer.apellido}</span></div>
                <div className="info-row"><span className="info-label">DNI</span><span className="info-value td-mono">{drawer.dni}</span></div>
                <div className="info-row"><span className="info-label">Fecha de Nac.</span><span className="info-value">{fmtDate(drawer.fechaNacimiento)}</span></div>
                <div className="info-row"><span className="info-label">Edad</span><span className="info-value">{calcEdad(drawer.fechaNacimiento)}</span></div>
              </div>
              <div className="info-section">
                <div className="info-section-title">Contacto</div>
                <div className="info-row"><span className="info-label">Teléfono</span><span className="info-value">{drawer.telefono || <span className="muted">No registrado</span>}</span></div>
                <div className="info-row"><span className="info-label">Email</span><span className="info-value" style={{ fontSize: 12 }}>{drawer.email || <span className="muted">No registrado</span>}</span></div>
              </div>
              <div className="info-section">
                <div className="info-section-title">Información Médica</div>
                <div className="info-row">
                  <span className="info-label">Grupo Sanguíneo</span>
                  <span className="info-value">
                    {drawer.grupoSanguineo
                      ? <span style={{ background:'#FEF3C7',color:'#92400E',padding:'2px 10px',borderRadius:20,fontWeight:700 }}>{drawer.grupoSanguineo}</span>
                      : '—'}
                  </span>
                </div>
                <div className="info-row"><span className="info-label">Alergias</span><span className="info-value" style={{ fontSize: 12 }}>{drawer.alergias || 'Ninguna registrada'}</span></div>
              </div>

              <div className="info-section">
                <div className="info-section-title">Historial de Citas ({drawerCitas.length})</div>
              </div>
              {drawerLoading ? (
                <div className="loading-wrap" style={{ padding: 20 }}><div className="spinner" /><div className="loading-text">Cargando historial...</div></div>
              ) : drawerCitas.length === 0 ? (
                <div className="empty-wrap" style={{ padding: 20 }}><div className="empty-icon" style={{ fontSize: 28 }}>📭</div><div className="empty-text">Sin citas registradas</div></div>
              ) : (
                drawerCitas.map(c => (
                  <div key={c.id} className="cita-hist-item">
                    <div className="cita-hist-dot" style={{ background: { Pendiente:'#F59E0B', Confirmada:'#3B82F6', Cancelada:'#EF4444', Completada:'#10B981', Anulada:'#F97316' }[c.estado] || '#94A3B8' }} />
                    <div className="cita-hist-info">
                      <div className="cita-hist-title">{c.nombreMedico}</div>
                      <div className="cita-hist-meta">{c.especialidadMedico} · {fmtFecha(c.fechaHora)}</div>
                      <div className="cita-hist-meta" style={{ marginTop: 3 }}>
                        {c.motivo} — <span className={badgeE(c.estado)} style={{ display: 'inline-flex', fontSize: 10 }}>{c.estado}</span>
                      </div>
                    </div>
                  </div>
                ))
              )}

              <div style={{ padding: 16, display: 'flex', gap: 8 }}>
                <button className="btn btn-warning btn-sm" style={{ flex: 1 }} onClick={() => { setDrawer(null); openEdit(drawer); }}>✏️ Editar Paciente</button>
                <button className="btn btn-danger btn-sm" style={{ flex: 1 }} onClick={() => { remove(drawer.id); }}>🗑️ Eliminar</button>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
