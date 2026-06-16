import { BrowserRouter, Routes, Route, NavLink, Navigate, useNavigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Pacientes from './pages/Pacientes';
import Medicos from './pages/Medicos';
import Citas from './pages/Citas';
import SolicitarCita from './pages/SolicitarCita';
import MisCitasPaciente from './pages/MisCitasPaciente';
import Boletas from './pages/Boletas';
import Tickets from './pages/Tickets';
import GestionTickets from './pages/GestionTickets';
import './App.css';

const ROL_CONFIG = {
  admin: {
    color: '#6B21A8', label: 'Administrador',
    nav: [
      { to: '/',                   icon: '📊', label: 'Dashboard',          exact: true },
      { to: '/pacientes',          icon: '👥', label: 'Pacientes' },
      { to: '/medicos',            icon: '🩺', label: 'Médicos' },
      { to: '/citas',              icon: '📅', label: 'Citas Médicas' },
      { to: '/mis-citas-paciente', icon: '🏥', label: 'Mis Citas (Personal)' },
      { to: '/boletas',            icon: '🧾', label: 'Mis Boletas' },
      { to: '/tickets',            icon: '🎫', label: 'Tickets Soporte' },
    ],
  },
  doctor: {
    color: '#0284C7', label: 'Médico',
    nav: [
      { to: '/',                   icon: '📊', label: 'Mi Panel',             exact: true },
      { to: '/citas',              icon: '📅', label: 'Mis Citas (Médico)' },
      { to: '/mis-citas-paciente', icon: '🏥', label: 'Mis Citas (Paciente)' },
      { to: '/pacientes',          icon: '👥', label: 'Pacientes' },
      { to: '/boletas',            icon: '🧾', label: 'Mis Boletas' },
      { to: '/tickets',            icon: '🎫', label: 'Reportar Problema' },
    ],
  },
  paciente: {
    color: '#059669', label: 'Paciente',
    nav: [
      { to: '/',               icon: '🏥', label: 'Inicio',          exact: true },
      { to: '/solicitar-cita', icon: '➕', label: 'Solicitar Cita' },
      { to: '/mis-citas-paciente', icon: '📅', label: 'Mis Citas' },
      { to: '/boletas',        icon: '🧾', label: 'Mis Boletas' },
      { to: '/tickets',        icon: '🎫', label: 'Reportar Problema' },
    ],
  },
};

function Sidebar() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const cfg = ROL_CONFIG[user.role];
  const initials = `${user.nombre[0]}${user.apellido[0]}`;

  const handleLogout = () => { logout(); navigate('/login'); };

  return (
    <aside className="sidebar">
      <div className="sidebar-brand">
        <span className="brand-icon">🏥</span>
        <div>
          <div className="brand-name">Clínica IDAT</div>
          <div className="brand-sub">Sistema Médico</div>
        </div>
      </div>

      <div className="sidebar-user">
        <div className="user-avatar" style={{ background: cfg.color }}>
          {initials}
        </div>
        <div>
          <div className="user-name">{user.nombre} {user.apellido}</div>
          <div className="user-role">{cfg.label}</div>
        </div>
      </div>

      <div className="sidebar-section-title">Menú principal</div>
      <nav className="sidebar-nav">
        {cfg.nav.map(link => (
          <NavLink key={link.to} to={link.to} end={link.exact}
            className={({ isActive }) => isActive ? 'nav-item active' : 'nav-item'}>
            <span className="nav-icon">{link.icon}</span>
            {link.label}
          </NavLink>
        ))}
      </nav>

      <button className="btn-logout" onClick={handleLogout}>
        🚪 Cerrar Sesión
      </button>
      <div className="sidebar-footer">IDAT · 5to Ciclo · 2024</div>
    </aside>
  );
}

function Layout() {
  const { user } = useAuth();
  const cfg = ROL_CONFIG[user.role];

  return (
    <div className="app-layout">
      <Sidebar />
      <div className="main-wrapper">
        <header className="top-header">
          <div className="header-date">
            📅 {new Date().toLocaleDateString('es-PE', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
          </div>
          <div className="header-right">
            <div className="header-api-status">
              <div className="api-dot" />
              API conectada
            </div>
            <span className="header-role-badge"
              style={{ background: cfg.color + '18', color: cfg.color }}>
              {cfg.label}
            </span>
          </div>
        </header>
        <main className="main-content">
          <Routes>
            <Route path="/"                   element={<Dashboard />} />
            <Route path="/pacientes"          element={<Pacientes />} />
            <Route path="/medicos"            element={<Medicos />} />
            <Route path="/citas"              element={<Citas />} />
            <Route path="/solicitar-cita"     element={<SolicitarCita />} />
            <Route path="/mis-citas-paciente" element={<MisCitasPaciente />} />
            <Route path="/boletas"            element={<Boletas />} />
            <Route path="/tickets"            element={user.role === 'admin' ? <GestionTickets /> : <Tickets />} />
          </Routes>
        </main>
      </div>
    </div>
  );
}

function ProtectedApp() {
  const { user } = useAuth();
  if (!user) return <Navigate to="/login" replace />;
  return <Layout />;
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginGuard />} />
          <Route path="/*" element={<ProtectedApp />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

function LoginGuard() {
  const { user } = useAuth();
  if (user) return <Navigate to="/" replace />;
  return <Login />;
}
