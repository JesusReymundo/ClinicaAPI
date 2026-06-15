import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { getMedicos, getCitasPaciente, createCita } from '../api/clinicaApi';

const HORAS = ['08:00','09:00','10:00','11:00','14:00','15:00','16:00','17:00'];
const MOTIVOS_SUGERIDOS = [
  'Consulta general preventiva','Dolor de cabeza frecuente','Control de presión arterial',
  'Fiebre y síntomas respiratorios','Dolor muscular o articular','Problema dermatológico',
  'Evaluación cardiovascular','Consulta de seguimiento','Otro motivo',
];

export default function SolicitarCita() {
  const { user }   = useAuth();
  const navigate   = useNavigate();
  const [medicos, setMedicos]         = useState([]);
  const [citasExistentes, setCitas]   = useState([]);
  const [step, setStep]               = useState(1); // 1=especialidad, 2=fecha/hora, 3=medico, 4=confirmar
  const [especialidad, setEspecialidad] = useState('');
  const [fecha, setFecha]             = useState('');
  const [hora, setHora]               = useState('');
  const [medicoId, setMedicoId]       = useState('');
  const [motivo, setMotivo]           = useState('');
  const [motivoCustom, setMotivoCustom] = useState('');
  const [loading, setLoading]         = useState(true);
  const [saving, setSaving]           = useState(false);
  const [error, setError]             = useState('');
  const [success, setSuccess]         = useState(false);

  useEffect(() => {
    (async () => {
      try {
        const [meds, citas] = await Promise.all([
          getMedicos(),
          getCitasPaciente(user.pacienteId),
        ]);
        setMedicos(meds);
        setCitas(citas);
      } catch {
        setError('No se pudo conectar con la API.');
      } finally { setLoading(false); }
    })();
  }, [user.pacienteId]);

  const especialidades = [...new Set(medicos.map(m => m.especialidad).filter(Boolean))].sort();

  const medicosFiltrados = medicos.filter(m => m.especialidad === especialidad);

  // Validación de límites mensuales
  const validarLimites = () => {
    if (!fecha) return null;
    const mes = new Date(fecha).getMonth();
    const anio = new Date(fecha).getFullYear();
    const citasMes = citasExistentes.filter(c => {
      const d = new Date(c.fechaHora);
      return d.getMonth() === mes && d.getFullYear() === anio &&
             !['Cancelada','Anulada'].includes(c.estado);
    });
    const citasMesEsp = citasMes.filter(c => c.especialidadMedico === especialidad);
    if (citasMes.length >= 6) return 'Superaste el límite de 6 citas totales por mes.';
    if (citasMesEsp.length >= 2) return `Ya tienes 2 citas de ${especialidad} este mes (límite máximo).`;
    return null;
  };

  const limiteError = step >= 2 ? validarLimites() : null;

  const confirmar = async () => {
    const motivoFinal = motivo === 'Otro motivo' ? motivoCustom.trim() : motivo;
    if (!motivoFinal) { setError('Ingresa el motivo de la consulta'); return; }
    const limite = validarLimites();
    if (limite) { setError(limite); return; }
    setSaving(true);
    setError('');
    try {
      await createCita({
        pacienteId: user.pacienteId,
        medicoId: Number(medicoId),
        fechaHora: new Date(`${fecha}T${hora}:00`).toISOString(),
        motivo: motivoFinal,
        observaciones: null,
      });
      setSuccess(true);
    } catch (e) {
      setError(e.response?.data?.message || 'Error al registrar la cita');
    } finally { setSaving(false); }
  };

  if (loading) return <div className="loading-wrap"><div className="spinner" /><div className="loading-text">Cargando...</div></div>;

  if (success) {
    return (
      <div className="solicitar-success">
        <div className="success-icon">✅</div>
        <h2>¡Cita registrada con éxito!</h2>
        <p>Tu cita de <strong>{especialidad}</strong> fue agendada para el <strong>{new Date(`${fecha}T${hora}`).toLocaleString('es-PE', { weekday:'long', day:'2-digit', month:'long', hour:'2-digit', minute:'2-digit' })}</strong>.</p>
        <div style={{ display:'flex', gap:12, justifyContent:'center', marginTop:20 }}>
          <button className="btn btn-primary" onClick={() => navigate('/citas')}>Ver mis citas</button>
          <button className="btn btn-ghost" onClick={() => { setSuccess(false); setStep(1); setEspecialidad(''); setFecha(''); setHora(''); setMedicoId(''); setMotivo(''); }}>Solicitar otra</button>
        </div>
      </div>
    );
  }

  const hoy = new Date().toISOString().split('T')[0];

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">➕ Solicitar Cita Médica</h1>
          <p className="page-subtitle">Agenda tu consulta en 4 simples pasos</p>
        </div>
      </div>

      {error && <div className="alert alert-error">⚠️ {error}</div>}
      {limiteError && <div className="alert alert-warning">⚠️ {limiteError}</div>}

      {/* Stepper */}
      <div className="stepper">
        {['Especialidad','Fecha y Hora','Médico','Confirmar'].map((s, i) => (
          <div key={s} className={`step-item ${step > i + 1 ? 'done' : step === i + 1 ? 'active' : ''}`}>
            <div className="step-circle">{step > i + 1 ? '✓' : i + 1}</div>
            <div className="step-label">{s}</div>
          </div>
        ))}
      </div>

      <div className="solicitar-card">
        {/* STEP 1: Especialidad */}
        {step === 1 && (
          <div>
            <h3 className="step-title">Selecciona la especialidad</h3>
            <div className="especialidad-grid">
              {especialidades.map(esp => (
                <button
                  key={esp}
                  className={`esp-card ${especialidad === esp ? 'selected' : ''}`}
                  onClick={() => setEspecialidad(esp)}
                >
                  <span className="esp-icon">
                    {esp === 'Cardiología' || esp === 'Cardiologia' ? '❤️'
                     : esp === 'Pediatría' || esp === 'Pediatria' ? '👶'
                     : esp === 'Dermatología' || esp === 'Dermatologia' ? '🔬'
                     : esp === 'Traumatología' || esp === 'Traumatologia' ? '🦴'
                     : '🩺'}
                  </span>
                  <span>{esp}</span>
                  <small>{medicos.filter(m => m.especialidad === esp).length} médicos disponibles</small>
                </button>
              ))}
            </div>
            <div className="step-actions">
              <button className="btn btn-primary" disabled={!especialidad} onClick={() => setStep(2)}>
                Siguiente →
              </button>
            </div>
          </div>
        )}

        {/* STEP 2: Fecha y Hora */}
        {step === 2 && (
          <div>
            <h3 className="step-title">Elige fecha y hora</h3>
            <div className="fecha-hora-grid">
              <div className="form-group">
                <label className="form-label">Fecha de la cita</label>
                <input type="date" className="form-control" min={hoy}
                  value={fecha} onChange={e => setFecha(e.target.value)} />
              </div>
              <div className="form-group">
                <label className="form-label">Hora preferida</label>
                <div className="horas-grid">
                  {HORAS.map(h => (
                    <button key={h} className={`hora-btn ${hora === h ? 'selected' : ''}`}
                      onClick={() => setHora(h)}>{h}</button>
                  ))}
                </div>
              </div>
            </div>
            <div className="step-actions">
              <button className="btn btn-ghost" onClick={() => setStep(1)}>← Atrás</button>
              <button className="btn btn-primary"
                disabled={!fecha || !hora || !!limiteError}
                onClick={() => setStep(3)}>
                Siguiente →
              </button>
            </div>
          </div>
        )}

        {/* STEP 3: Médico */}
        {step === 3 && (
          <div>
            <h3 className="step-title">Médicos disponibles en {especialidad}</h3>
            <p className="step-sub">Para el {new Date(`${fecha}T${hora}`).toLocaleString('es-PE', { weekday:'long', day:'2-digit', month:'long' })} a las {hora}</p>
            {medicosFiltrados.length === 0 ? (
              <div className="empty-wrap">
                <div className="empty-icon">🩺</div>
                <div className="empty-text">No hay médicos disponibles para esta especialidad</div>
              </div>
            ) : (
              <div className="medicos-disponibles">
                {medicosFiltrados.map(m => (
                  <button
                    key={m.id}
                    className={`medico-card ${medicoId === String(m.id) ? 'selected' : ''}`}
                    onClick={() => setMedicoId(String(m.id))}
                  >
                    <div className="medico-avatar">
                      {(m.nombre || '?')[0]}
                    </div>
                    <div className="medico-info">
                      <div className="medico-nombre">Dr. {m.nombre} {m.apellido}</div>
                      <div className="medico-esp">{m.especialidad}</div>
                      {m.consultorio && <div className="medico-consul">📍 {m.consultorio}</div>}
                      {m.tarifaConsulta && <div className="medico-tarifa">💰 S/ {m.tarifaConsulta}</div>}
                    </div>
                    {medicoId === String(m.id) && <span className="check-mark">✓</span>}
                  </button>
                ))}
              </div>
            )}
            <div className="step-actions">
              <button className="btn btn-ghost" onClick={() => setStep(2)}>← Atrás</button>
              <button className="btn btn-primary" disabled={!medicoId} onClick={() => setStep(4)}>
                Siguiente →
              </button>
            </div>
          </div>
        )}

        {/* STEP 4: Confirmar */}
        {step === 4 && (
          <div>
            <h3 className="step-title">Confirma tu cita</h3>
            <div className="confirm-card">
              <div className="confirm-row"><span>Especialidad:</span><strong>{especialidad}</strong></div>
              <div className="confirm-row"><span>Fecha y hora:</span><strong>{new Date(`${fecha}T${hora}`).toLocaleString('es-PE', { weekday:'long', day:'2-digit', month:'long', year:'numeric', hour:'2-digit', minute:'2-digit' })}</strong></div>
              <div className="confirm-row"><span>Médico:</span><strong>Dr. {(() => { const m = medicos.find(m => String(m.id) === medicoId); return m ? `${m.nombre} ${m.apellido}` : ''; })()}</strong></div>
            </div>
            <div className="form-group" style={{ marginTop: 20 }}>
              <label className="form-label">Motivo de la consulta *</label>
              <div className="motivos-list">
                {MOTIVOS_SUGERIDOS.map(mot => (
                  <button key={mot} className={`motivo-btn ${motivo === mot ? 'selected' : ''}`}
                    onClick={() => setMotivo(mot)}>{mot}</button>
                ))}
              </div>
              {motivo === 'Otro motivo' && (
                <textarea className="form-control" style={{ marginTop: 8 }} rows={3}
                  placeholder="Describe tu motivo..."
                  value={motivoCustom} onChange={e => setMotivoCustom(e.target.value)} />
              )}
            </div>
            <div className="step-actions">
              <button className="btn btn-ghost" onClick={() => setStep(3)}>← Atrás</button>
              <button className="btn btn-success" disabled={saving || !motivo} onClick={confirmar}>
                {saving ? 'Registrando...' : '✅ Confirmar Cita'}
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
