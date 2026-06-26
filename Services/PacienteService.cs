using ClinicaAPI.Data;
using ClinicaAPI.DTOs;
using ClinicaAPI.Exceptions;
using ClinicaAPI.Models;
using ClinicaAPI.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace ClinicaAPI.Services;

public class PacienteService : IPacienteService
{
    private readonly ClinicaDbContext _db;

    public PacienteService(ClinicaDbContext db) => _db = db;

    public IEnumerable<PacienteResponseDto> ObtenerTodos()
    {
        var pacientes = _db.Pacientes
            .Include(p => p.Usuario)
            .AsNoTracking()
            .ToList();

        var usuarioIds = pacientes.Select(p => p.IdUsuario).ToList();
        var contactosMapa = _db.Contactos
            .Where(c => usuarioIds.Contains(c.IdUsuario))
            .AsNoTracking()
            .ToList()
            .GroupBy(c => c.IdUsuario)
            .ToDictionary(g => g.Key, g => g.ToList());

        return pacientes.Select(p =>
        {
            var ct = contactosMapa.TryGetValue(p.IdUsuario, out var lista) ? lista : new List<Contacto>();
            return MapToDto(p, ct);
        });
    }

    public PacienteResponseDto ObtenerPorId(int id)
    {
        var paciente = _db.Pacientes
            .Include(p => p.Usuario)
            .AsNoTracking()
            .FirstOrDefault(p => p.IdPaciente == id)
            ?? throw new NotFoundException($"Paciente con ID {id} no encontrado");

        var contactos = _db.Contactos
            .Where(c => c.IdUsuario == paciente.IdUsuario)
            .AsNoTracking()
            .ToList();

        return MapToDto(paciente, contactos);
    }

    public PacienteResponseDto Crear(PacienteCreateDto dto)
    {
        if (_db.Usuarios.Any(u => u.NumeroDocumento == dto.Dni))
            throw new BusinessException($"Ya existe un paciente con el DNI {dto.Dni}");

        var usuario = new Usuario
        {
            IdRol = 3,
            Nombres = dto.Nombre,
            Apellidos = dto.Apellido,
            TipoDocumento = "DNI",
            NumeroDocumento = dto.Dni,
            FechaNacimiento = dto.FechaNacimiento,
            Username = dto.Dni,
            PasswordHash = BCryptHash(dto.Dni),
            Activo = true
        };
        _db.Usuarios.Add(usuario);
        _db.SaveChanges();

        if (!string.IsNullOrEmpty(dto.Telefono))
            _db.Contactos.Add(new Contacto { IdUsuario = usuario.IdUsuario, TipoContacto = "Telefono", Valor = dto.Telefono, EsPrincipal = true });
        if (!string.IsNullOrEmpty(dto.Email))
            _db.Contactos.Add(new Contacto { IdUsuario = usuario.IdUsuario, TipoContacto = "Email", Valor = dto.Email, EsPrincipal = true });
        _db.SaveChanges();

        var paciente = new Paciente
        {
            IdUsuario = usuario.IdUsuario,
            IdTipoAsegurado = 1,
            GrupoSanguineo = dto.GrupoSanguineo,
            Alergias = dto.Alergias
        };
        _db.Pacientes.Add(paciente);
        _db.SaveChanges();

        return ObtenerPorId(paciente.IdPaciente);
    }

    public PacienteResponseDto Actualizar(int id, PacienteUpdateDto dto)
    {
        var paciente = _db.Pacientes.Include(p => p.Usuario).FirstOrDefault(p => p.IdPaciente == id)
            ?? throw new NotFoundException($"Paciente con ID {id} no encontrado");

        if (_db.Usuarios.Any(u => u.NumeroDocumento == dto.Dni && u.IdUsuario != paciente.IdUsuario))
            throw new BusinessException($"Ya existe otro paciente con el DNI {dto.Dni}");

        paciente.Usuario!.Nombres = dto.Nombre;
        paciente.Usuario.Apellidos = dto.Apellido;
        paciente.Usuario.NumeroDocumento = dto.Dni;
        paciente.Usuario.FechaNacimiento = dto.FechaNacimiento;
        paciente.Usuario.FechaModificacion = DateTime.Now;
        paciente.GrupoSanguineo = dto.GrupoSanguineo;
        paciente.Alergias = dto.Alergias;

        var telContacto = _db.Contactos.FirstOrDefault(c => c.IdUsuario == paciente.IdUsuario && c.TipoContacto == "Telefono");
        if (telContacto != null) telContacto.Valor = dto.Telefono;
        else if (!string.IsNullOrEmpty(dto.Telefono))
            _db.Contactos.Add(new Contacto { IdUsuario = paciente.IdUsuario, TipoContacto = "Telefono", Valor = dto.Telefono });

        var emailContacto = _db.Contactos.FirstOrDefault(c => c.IdUsuario == paciente.IdUsuario && c.TipoContacto == "Email");
        if (emailContacto != null) emailContacto.Valor = dto.Email;
        else if (!string.IsNullOrEmpty(dto.Email))
            _db.Contactos.Add(new Contacto { IdUsuario = paciente.IdUsuario, TipoContacto = "Email", Valor = dto.Email });

        _db.SaveChanges();
        return ObtenerPorId(id);
    }

    public void Eliminar(int id)
    {
        var paciente = _db.Pacientes.FirstOrDefault(p => p.IdPaciente == id)
            ?? throw new NotFoundException($"Paciente con ID {id} no encontrado");
        _db.Pacientes.Remove(paciente);
        _db.SaveChanges();
    }

    private static string BCryptHash(string value) =>
        Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(value));

    private static PacienteResponseDto MapToDto(Paciente p, List<Contacto> contactos) => new()
    {
        Id = p.IdPaciente,
        Nombre = p.Usuario?.Nombres ?? string.Empty,
        Apellido = p.Usuario?.Apellidos ?? string.Empty,
        Dni = p.Usuario?.NumeroDocumento ?? string.Empty,
        Telefono = contactos.FirstOrDefault(c => c.TipoContacto == "Telefono")?.Valor ?? string.Empty,
        Email = contactos.FirstOrDefault(c => c.TipoContacto == "Email")?.Valor ?? string.Empty,
        FechaNacimiento = p.Usuario?.FechaNacimiento ?? DateTime.MinValue,
        GrupoSanguineo = p.GrupoSanguineo ?? string.Empty,
        Alergias = p.Alergias ?? string.Empty
    };
}
