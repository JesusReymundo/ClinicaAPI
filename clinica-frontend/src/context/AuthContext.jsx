import { createContext, useContext, useState } from 'react';

const AuthContext = createContext(null);
const API_URL = 'http://localhost:5024/api/auth/login';

// Contraseñas válidas por rol (las que usa el SeedData del repo)
const ROLE_BY_PASSWORD = {
  'Admin@2024':  'admin',
  'Doctor@2024': 'doctor',
  'Medico@2024': 'doctor',
  'Paciente123': 'paciente',
  // genéricos de compatibilidad
  'admin123':    'admin',
  'medico123':   'doctor',
  'cita123':     'paciente',
};

// IDs de paciente por defecto según rol (cuando no hay API)
const DEFAULT_IDS = {
  admin:    { pacienteId: 1,  medicoId: null },
  doctor:   { pacienteId: 3,  medicoId: 1    },
  paciente: { pacienteId: 31, medicoId: null },
};

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    try { return JSON.parse(localStorage.getItem('clinica_user') || 'null'); }
    catch { return null; }
  });

  const login = async (username, password) => {
    // ─── 1. Intentar autenticación real contra la BD ───────────────
    try {
      const res = await fetch(API_URL, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ username, password }),
      });

      if (res.ok) {
        const json = await res.json();
        if (json.success && json.data) {
          setUser(json.data);
          localStorage.setItem('clinica_user', JSON.stringify(json.data));
          return true;
        }
      }

      // 401 = credenciales incorrectas en BD → no continuar
      if (res.status === 401) return false;

      // Otro error (404 = AuthController no cargado aún) → fallback
    } catch {
      // API caída o no iniciada → fallback
    }

    // ─── 2. Fallback por patrón de contraseña ──────────────────────
    // Sirve cuando la API no está disponible o el endpoint /auth/login
    // no existe todavía (reinicia el backend para desactivar esto).
    const role = ROLE_BY_PASSWORD[password];
    if (!role) return false;

    const ids  = DEFAULT_IDS[role];
    const safe = {
      id:         0,
      username,
      role,
      nombre:     username.split('_')[0] || username,
      apellido:   username.split('_')[1] || '',
      medicoId:   ids.medicoId,
      pacienteId: ids.pacienteId,
    };
    setUser(safe);
    localStorage.setItem('clinica_user', JSON.stringify(safe));
    return true;
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('clinica_user');
  };

  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
