using ClinicaAPI.Data;
using ClinicaAPI.DTOs;
using ClinicaAPI.Exceptions;
using ClinicaAPI.Models;
using ClinicaAPI.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace ClinicaAPI.Services;

public class MedicoService : IMedicoService
{
    private readonly ClinicaDbContext _db;

    public MedicoService(ClinicaDbContext db) => _db = db;

    public IEnumerable<MedicoResponseDto> ObtenerTodos() =>
        _db.Medicos
            .Include(m => m.Usuario)
            .Include(m => m.EspecialidadNav)
            .AsNoTracking()
            .Select(MapToDto)
            .ToList();

    public MedicoResponseDto ObtenerPorId(int id)
    {
        var medico = _db.Medicos
            .Include(m => m.Usuario)
            .Include(m => m.EspecialidadNav)
            .AsNoTracking()
            .FirstOrDefault(m => m.IdMedico == id)
            ?? throw new NotFoundException($"Médico con ID {id} no encontrado");
        return MapToDto(medico);
    }

    public IEnumerable<MedicoResponseDto> ObtenerPorEspecialidad(string especialidad) =>
        _db.Medicos
            .Include(m => m.Usuario)
            .Include(m => m.EspecialidadNav)
            .AsNoTracking()
            .Where(m => m.EspecialidadNav!.Nombre.Contains(especialidad))
            .Select(MapToDto)
            .ToList();

    public MedicoResponseDto Crear(MedicoCreateDto dto)
    {
        if (_db.Medicos.Any(m => m.ColegioMedico == dto.ColegioMedico))
            throw new BusinessException($"Ya existe un médico con el número de colegio {dto.ColegioMedico}");

        var especialidad = _db.Especialidades.FirstOrDefault(e => e.Nombre == dto.Especialidad)
            ?? new Especialidad { Nombre = dto.Especialidad, Activo = true };
        if (especialidad.IdEspecialidad == 0)
        {
            _db.Especialidades.Add(especialidad);
            _db.SaveChanges();
        }

        var usuario = new Usuario
        {
            IdRol = 2,
            Nombres = dto.Nombre,
            Apellidos = dto.Apellido,
            DNI = dto.ColegioMedico.Replace("-", "").PadLeft(8, '0')[..8],
            Username = dto.ColegioMedico,
            PasswordHash = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(dto.ColegioMedico)),
            Activo = true
        };
        _db.Usuarios.Add(usuario);
        _db.SaveChanges();

        if (!string.IsNullOrEmpty(dto.Telefono))
            _db.Contactos.Add(new Contacto { IdUsuario = usuario.IdUsuario, TipoContacto = "Telefono", Valor = dto.Telefono, EsPrincipal = true });
        _db.SaveChanges();

        var medico = new Medico
        {
            IdUsuario = usuario.IdUsuario,
            IdEspecialidad = especialidad.IdEspecialidad,
            ColegioMedico = dto.ColegioMedico
        };
        _db.Medicos.Add(medico);
        _db.SaveChanges();

        return ObtenerPorId(medico.IdMedico);
    }

    public MedicoResponseDto Actualizar(int id, MedicoUpdateDto dto)
    {
        var medico = _db.Medicos.Include(m => m.Usuario).FirstOrDefault(m => m.IdMedico == id)
            ?? throw new NotFoundException($"Médico con ID {id} no encontrado");

        if (_db.Medicos.Any(m => m.ColegioMedico == dto.ColegioMedico && m.IdMedico != id))
            throw new BusinessException($"Ya existe otro médico con el número de colegio {dto.ColegioMedico}");

        var especialidad = _db.Especialidades.FirstOrDefault(e => e.Nombre == dto.Especialidad)
            ?? new Especialidad { Nombre = dto.Especialidad, Activo = true };
        if (especialidad.IdEspecialidad == 0) { _db.Especialidades.Add(especialidad); _db.SaveChanges(); }

        medico.Usuario!.Nombres = dto.Nombre;
        medico.Usuario.Apellidos = dto.Apellido;
        medico.Usuario.FechaModificacion = DateTime.Now;
        medico.ColegioMedico = dto.ColegioMedico;
        medico.IdEspecialidad = especialidad.IdEspecialidad;

        var telContacto = _db.Contactos.FirstOrDefault(c => c.IdUsuario == medico.IdUsuario && c.TipoContacto == "Telefono");
        if (telContacto != null) telContacto.Valor = dto.Telefono;
        else _db.Contactos.Add(new Contacto { IdUsuario = medico.IdUsuario, TipoContacto = "Telefono", Valor = dto.Telefono });

        _db.SaveChanges();
        return ObtenerPorId(id);
    }

    public void Eliminar(int id)
    {
        var medico = _db.Medicos.FirstOrDefault(m => m.IdMedico == id)
            ?? throw new NotFoundException($"Médico con ID {id} no encontrado");
        _db.Medicos.Remove(medico);
        _db.SaveChanges();
    }

    private static MedicoResponseDto MapToDto(Medico m) => new()
    {
        Id = m.IdMedico,
        Nombre = m.Usuario?.Nombres ?? string.Empty,
        Apellido = m.Usuario?.Apellidos ?? string.Empty,
        Especialidad = m.EspecialidadNav?.Nombre ?? string.Empty,
        ColegioMedico = m.ColegioMedico,
        Telefono = string.Empty
    };
}
