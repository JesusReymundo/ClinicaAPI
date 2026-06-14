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

    public IEnumerable<PacienteResponseDto> ObtenerTodos() =>
        _db.Pacientes
            .Include(p => p.Usuario)
            .Include(p => p.TipoAsegurado)
            .Include(p => p.Empresa)
            .AsNoTracking()
            .Select(MapToDto)
            .ToList();

    public PacienteResponseDto ObtenerPorId(int id)
    {
        var paciente = _db.Pacientes
            .Include(p => p.Usuario)
            .Include(p => p.TipoAsegurado)
            .Include(p => p.Empresa)
            .AsNoTracking()
            .FirstOrDefault(p => p.IdPaciente == id)
            ?? throw new NotFoundException($"Paciente con ID {id} no encontrado");
        return MapToDto(paciente);
    }

    public PacienteResponseDto Crear(PacienteCreateDto dto)
    {
        if (_db.Usuarios.Any(u => u.DNI == dto.Dni))
            throw new BusinessException($"Ya existe un paciente con el DNI {dto.Dni}");

        var usuario = new Usuario
        {
            IdRol = 3,
            Nombres = dto.Nombre,
            Apellidos = dto.Apellido,
            DNI = dto.Dni,
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
            IdTipoAsegurado = 1
        };
        _db.Pacientes.Add(paciente);
        _db.SaveChanges();

        return ObtenerPorId(paciente.IdPaciente);
    }

    public PacienteResponseDto Actualizar(int id, PacienteUpdateDto dto)
    {
        var paciente = _db.Pacientes.Include(p => p.Usuario).FirstOrDefault(p => p.IdPaciente == id)
            ?? throw new NotFoundException($"Paciente con ID {id} no encontrado");

        if (_db.Usuarios.Any(u => u.DNI == dto.Dni && u.IdUsuario != paciente.IdUsuario))
            throw new BusinessException($"Ya existe otro paciente con el DNI {dto.Dni}");

        paciente.Usuario!.Nombres = dto.Nombre;
        paciente.Usuario.Apellidos = dto.Apellido;
        paciente.Usuario.DNI = dto.Dni;
        paciente.Usuario.FechaNacimiento = dto.FechaNacimiento;
        paciente.Usuario.FechaModificacion = DateTime.Now;

        var telContacto = _db.Contactos.FirstOrDefault(c => c.IdUsuario == paciente.IdUsuario && c.TipoContacto == "Telefono");
        if (telContacto != null) telContacto.Valor = dto.Telefono;
        else _db.Contactos.Add(new Contacto { IdUsuario = paciente.IdUsuario, TipoContacto = "Telefono", Valor = dto.Telefono });

        var emailContacto = _db.Contactos.FirstOrDefault(c => c.IdUsuario == paciente.IdUsuario && c.TipoContacto == "Email");
        if (emailContacto != null) emailContacto.Valor = dto.Email;
        else _db.Contactos.Add(new Contacto { IdUsuario = paciente.IdUsuario, TipoContacto = "Email", Valor = dto.Email });

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

    private static PacienteResponseDto MapToDto(Paciente p) => new()
    {
        Id = p.IdPaciente,
        Nombre = p.Usuario?.Nombres ?? string.Empty,
        Apellido = p.Usuario?.Apellidos ?? string.Empty,
        Dni = p.Usuario?.DNI ?? string.Empty,
        Telefono = string.Empty,
        Email = string.Empty,
        FechaNacimiento = p.Usuario?.FechaNacimiento ?? DateTime.MinValue
    };
}
