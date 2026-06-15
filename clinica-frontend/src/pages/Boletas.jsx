import { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { getCitasPaciente } from '../api/clinicaApi';

const fmtFecha = f => new Date(f).toLocaleDateString('es-PE', {
  day: '2-digit', month: 'long', year: 'numeric',
});
const fmtMonto = n => `S/ ${Number(n).toFixed(2)}`;

const TARIFA = {
  'Cardiología': 120, 'Cardiologia': 120,
  'Medicina General': 80, 'Medicina general': 80,
  'Pediatría': 90, 'Pediatria': 90,
  'Dermatología': 100, 'Dermatologia': 100,
  'Traumatología': 110, 'Traumatologia': 110,
};

function getFacturaA(pacienteId) {
  if (pacienteId >= 51 && pacienteId <= 65) return { tipo: 'Corporativo', label: 'Empresa Corporativa' };
  if (pacienteId >= 66 && pacienteId <= 80) return { tipo: 'EsSalud', label: 'EsSalud' };
  if (pacienteId >= 81) return { tipo: 'SIS', label: 'SIS' };
  return { tipo: 'Particular', label: 'Pago Particular' };
}

function generarBoleta(cita, pacienteId, nombreAsegurado, index) {
  const subtotal = TARIFA[cita.especialidadMedico] || 80;
  const igv = Math.round(subtotal * 0.18 * 100) / 100;
  const total = Math.round(subtotal * 1.18 * 100) / 100;
  const factura = getFacturaA(pacienteId);
  return {
    numero: `F001-${String(cita.id).padStart(6, '0')}`,
    fecha: cita.fechaHora,
    asegurado: nombreAsegurado,
    facturaA: factura.label,
    tipoFactura: factura.tipo,
    paciente: cita.nombrePaciente,
    medico: cita.nombreMedico,
    especialidad: cita.especialidadMedico,
    motivo: cita.motivo,
    subtotal,
    igv,
    total,
    estado: index % 6 === 0 ? 'Pendiente' : 'Pagado',
    citaId: cita.id,
  };
}

const TIPO_BADGE = {
  Particular:   { bg: '#EDE9FE', color: '#6B21A8' },
  Corporativo:  { bg: '#DBEAFE', color: '#1D4ED8' },
  EsSalud:      { bg: '#D1FAE5', color: '#059669' },
  SIS:          { bg: '#FEF3C7', color: '#D97706' },
};

export default function Boletas() {
  const { user } = useAuth();
  const [boletas, setBoletas]   = useState([]);
  const [loading, setLoading]   = useState(true);
  const [error, setError]       = useState('');
  const [selected, setSelected] = useState(null);
  const [filtro, setFiltro]     = useState('Todos');

  const nombreAsegurado = `${user.nombre} ${user.apellido}`;

  useEffect(() => {
    (async () => {
      try {
        if (!user.pacienteId) { setBoletas([]); setLoading(false); return; }
        const citas = await getCitasPaciente(user.pacienteId);
        const completadas = citas.filter(c => c.estado === 'Completada');
        setBoletas(completadas.map((c, i) => generarBoleta(c, user.pacienteId, nombreAsegurado, i)));
      } catch {
        setError('No se pudo cargar las boletas. Verifica que la API esté activa.');
      } finally { setLoading(false); }
    })();
  }, [user]);

  const filtradas = filtro === 'Todos' ? boletas : boletas.filter(b => b.estado === filtro);
  const totalPagado = boletas.filter(b => b.estado === 'Pagado').reduce((s, b) => s + b.total, 0);
  const facturaInfo = getFacturaA(user.pacienteId || 1);
  const tipoBadge = TIPO_BADGE[facturaInfo.tipo] || TIPO_BADGE.Particular;

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">🧾 Mis Boletas</h1>
          <p className="page-subtitle">Historial de facturas y comprobantes de pago</p>
        </div>
      </div>

      {error && <div className="alert alert-error">⚠️ {error}</div>}

      {/* Info del titular */}
      <div className="boleta-titular-card">
        <div className="titular-info">
          <div className="titular-avatar">{nombreAsegurado[0]}</div>
          <div>
            <div className="titular-nombre">{nombreAsegurado}</div>
            <div className="titular-sub">Titular de la cuenta · Paciente #{user.pacienteId}</div>
          </div>
        </div>
        <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
          <span style={{ fontSize: 13, color: '#64748B' }}>Facturación:</span>
          <span style={{ background: tipoBadge.bg, color: tipoBadge.color, padding: '4px 14px', borderRadius: 20, fontWeight: 600, fontSize: 13 }}>
            {facturaInfo.label}
          </span>
        </div>
      </div>

      {!loading && boletas.length > 0 && (
        <div className="stats-row" style={{ marginBottom: 20 }}>
          <div className="stat-card-mini">
            <div className="stat-mini-val">{boletas.length}</div>
            <div className="stat-mini-label">Total boletas</div>
          </div>
          <div className="stat-card-mini">
            <div className="stat-mini-val">{boletas.filter(b => b.estado === 'Pagado').length}</div>
            <div className="stat-mini-label">Pagadas</div>
          </div>
          <div className="stat-card-mini">
            <div className="stat-mini-val">{boletas.filter(b => b.estado === 'Pendiente').length}</div>
            <div className="stat-mini-label">Pendientes</div>
          </div>
          <div className="stat-card-mini" style={{ background: '#f0fdf4' }}>
            <div className="stat-mini-val" style={{ color: '#059669' }}>{fmtMonto(totalPagado)}</div>
            <div className="stat-mini-label">Total pagado</div>
          </div>
        </div>
      )}

      <div className="tab-bar">
        {['Todos', 'Pagado', 'Pendiente'].map(f => (
          <button key={f} className={`tab ${filtro === f ? 'active' : ''}`} onClick={() => setFiltro(f)}>
            {f} <span className="tab-count">{(f === 'Todos' ? boletas : boletas.filter(b => b.estado === f)).length}</span>
          </button>
        ))}
      </div>

      <div className="table-card">
        {loading ? (
          <div className="loading-wrap"><div className="spinner" /><div className="loading-text">Cargando boletas...</div></div>
        ) : filtradas.length === 0 ? (
          <div className="empty-wrap">
            <div className="empty-icon">🧾</div>
            <div className="empty-text">
              {boletas.length === 0
                ? 'Aún no tienes boletas. Se generan tras consultas completadas.'
                : 'No hay boletas con ese filtro.'}
            </div>
          </div>
        ) : (
          <table>
            <thead>
              <tr>
                <th>N° Boleta</th>
                <th>Fecha</th>
                <th>Asegurado</th>
                <th>Factura a</th>
                <th>Médico</th>
                <th>Subtotal</th>
                <th>IGV (18%)</th>
                <th>Total</th>
                <th>Estado</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {filtradas.map(b => {
                const tb = TIPO_BADGE[b.tipoFactura] || TIPO_BADGE.Particular;
                return (
                  <tr key={b.numero}>
                    <td><span className="td-mono">{b.numero}</span></td>
                    <td style={{ whiteSpace: 'nowrap', fontSize: 13 }}>{fmtFecha(b.fecha)}</td>
                    <td>
                      <div className="td-name" style={{ fontSize: 13 }}>{b.asegurado}</div>
                    </td>
                    <td>
                      <span style={{ background: tb.bg, color: tb.color, padding: '2px 10px', borderRadius: 20, fontSize: 12, fontWeight: 600 }}>
                        {b.facturaA}
                      </span>
                    </td>
                    <td style={{ fontSize: 13 }}>{b.medico || '—'}</td>
                    <td>{fmtMonto(b.subtotal)}</td>
                    <td>{fmtMonto(b.igv)}</td>
                    <td><strong>{fmtMonto(b.total)}</strong></td>
                    <td>
                      <span className={b.estado === 'Pagado' ? 'badge badge-completada' : 'badge badge-pendiente'}>
                        {b.estado}
                      </span>
                    </td>
                    <td>
                      <button className="btn btn-ghost btn-xs" onClick={() => setSelected(b)}>
                        👁️ Ver
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>

      {/* Modal detalle boleta */}
      {selected && (
        <div className="modal-overlay" onClick={() => setSelected(null)}>
          <div className="modal-box boleta-modal" onClick={e => e.stopPropagation()}>
            <div className="boleta-header">
              <div className="boleta-logo">🏥 Clínica IDAT</div>
              <div className="boleta-tipo">BOLETA DE VENTA ELECTRÓNICA</div>
              <div className="boleta-num">{selected.numero}</div>
            </div>
            <div className="boleta-body">
              <div className="boleta-row"><span>Fecha emisión:</span><span>{fmtFecha(selected.fecha)}</span></div>
              <div className="boleta-row"><span>Asegurado:</span><strong>{selected.asegurado}</strong></div>
              <div className="boleta-row"><span>Factura a:</span>
                <span style={{ background: (TIPO_BADGE[selected.tipoFactura] || TIPO_BADGE.Particular).bg, color: (TIPO_BADGE[selected.tipoFactura] || TIPO_BADGE.Particular).color, padding: '2px 10px', borderRadius: 20, fontSize: 12, fontWeight: 600 }}>
                  {selected.facturaA}
                </span>
              </div>
              <div className="boleta-row"><span>Médico:</span><span>{selected.medico}</span></div>
              <div className="boleta-row"><span>Especialidad:</span><span>{selected.especialidad}</span></div>
              <div className="boleta-row"><span>Motivo:</span><span>{selected.motivo}</span></div>
              <hr style={{ margin: '10px 0', borderColor: '#E2E8F0' }} />
              <div className="boleta-row"><span>Consulta médica:</span><span>{fmtMonto(selected.subtotal)}</span></div>
              <div className="boleta-row"><span>IGV (18%):</span><span>{fmtMonto(selected.igv)}</span></div>
              <div className="boleta-row boleta-total"><span>TOTAL:</span><span>{fmtMonto(selected.total)}</span></div>
              <div className="boleta-estado" style={{ color: selected.estado === 'Pagado' ? '#059669' : '#D97706' }}>
                Estado: {selected.estado}
              </div>
            </div>
            <div style={{ textAlign: 'center', marginTop: 16 }}>
              <button className="btn btn-ghost" onClick={() => setSelected(null)}>Cerrar</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
