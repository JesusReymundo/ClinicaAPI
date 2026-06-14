import { createContext, useContext, useState } from 'react';

const AuthContext = createContext(null);

const USUARIOS = [
  { id: 1, username: 'admin',    password: 'admin123',  role: 'admin',    nombre: 'Admin',   apellido: 'Sistema', medicoId: null, pacienteId: null },
  { id: 2, username: 'doctor',   password: 'medico123', role: 'doctor',   nombre: 'Carlos',  apellido: 'García',  medicoId: 1,    pacienteId: null },
  { id: 3, username: 'paciente', password: 'cita123',   role: 'paciente', nombre: 'Juan',    apellido: 'Pérez',   medicoId: null, pacienteId: 1 },
];

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    try { return JSON.parse(localStorage.getItem('clinica_user') || 'null'); }
    catch { return null; }
  });

  const login = (username, password) => {
    const found = USUARIOS.find(u => u.username === username && u.password === password);
    if (!found) return false;
    const { password: _, ...safe } = found;
    setUser(safe);
    localStorage.setItem('clinica_user', JSON.stringify(safe));
    return true;
  };

  const logout = () => { setUser(null); localStorage.removeItem('clinica_user'); };

  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
