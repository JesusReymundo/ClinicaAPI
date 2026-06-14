import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:5024/api',
  headers: { 'Content-Type': 'application/json' },
});

// Extrae .data.data de la respuesta envuelta { success, data }
const d = r => r.data.data;

// PACIENTES
export const getPacientes   = () => api.get('/pacientes').then(d);
export const getPaciente    = id => api.get(`/pacientes/${id}`).then(d);
export const createPaciente = body => api.post('/pacientes', body).then(d);
export const updatePaciente = (id, body) => api.put(`/pacientes/${id}`, body).then(d);
export const deletePaciente = id => api.delete(`/pacientes/${id}`);

// MEDICOS
export const getMedicos   = () => api.get('/medicos').then(d);
export const getMedico    = id => api.get(`/medicos/${id}`).then(d);
export const createMedico = body => api.post('/medicos', body).then(d);
export const updateMedico = (id, body) => api.put(`/medicos/${id}`, body).then(d);
export const deleteMedico = id => api.delete(`/medicos/${id}`);

// CITAS
export const getCitas         = () => api.get('/citas').then(d);
export const getCita          = id => api.get(`/citas/${id}`).then(d);
export const getCitasPaciente = id => api.get(`/citas/paciente/${id}`).then(d);
export const getCitasMedico   = id => api.get(`/citas/medico/${id}`).then(d);
export const getCitasEstado   = estado => api.get(`/citas/estado/${estado}`).then(d);
export const createCita       = body => api.post('/citas', body).then(d);
export const updateCita       = (id, body) => api.put(`/citas/${id}`, body).then(d);
export const cancelarCita     = id => api.patch(`/citas/${id}/cancelar`).then(d);
export const anularCita       = id => api.patch(`/citas/${id}/anular`).then(d);
export const deleteCita       = id => api.delete(`/citas/${id}`);
