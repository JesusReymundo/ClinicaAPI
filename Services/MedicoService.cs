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

    private IQueryable<Medico> MedicosConIncludes() =>
        _db.Medicos
            .Include(m => m.Usuario)
            .Include(m => m.ColegiosMedico)
            .Include(m => m.Tarifas).ThenInclude(t => t.Especialidad)
            .AsNoTracking();

    public IEnumerable<MedicoResponseDto> ObtenerTodos() =>
        MedicosConIncludes().Select(MapToDto).ToList();

    public MedicoResponseDto ObtenerPorId(int id)
    {
        var medico = MedicosConIncludes()
            .FirstOrDefault(m => m.IdMedico == id)
            ?? throw new NotFoundException($"Médico con ID {id} no encontrado");
        return MapToDto(medico);
    }

    public IEnumerable<MedicoResponseDto> ObtenerPorEspecialidad(string especialidad) =>
        MedicosConIncludes()
            .Where(m => m.Tarifas.Any(t => t.Especialidad!.Nombre.Contains(especialidad) && t.Activo))
            .Select(MapToDto)
            .ToList();

    public MedicoResponseDto Crear(MedicoCreateDto dto)
    {
        if (_db.ColegiosMedico.Any(c => c.Numero == dto.ColegioMedico))
            throw new BusinessException($"Ya existe un médico con el número de colegio {dto.ColegioMedico}");

        var especialidad = _db.Especialidades.FirstOrDefault(e => e.Nombre == dto.Especialidad)
            ?? new Especialidad { Nombre = dto.Especialidad, Activo = true };
        if (especialidad.IdEspecialidad == 0) { _db.Especialidades.Add(especialidad); _db.SaveChanges(); }

        var usuario = new Usuario
        {
            IdRol = 2,
            Nombres = dto.Nombre,
            Apellidos = dto.Apellido,
            TipoDocumento = "DNI",
            NumeroDocumento = dto.ColegioMedico.Replace("-", "").PadLeft(8, '0')[..8],
            Username = dto.ColegioMedico,
            PasswordHash = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(dto.ColegioMedico)),
            Activo = true
        };
        _db.Usuarios.Add(usuario);
        _db.SaveChanges();

        if (!string.IsNullOrEmpty(dto.Telefono))
            _db.Contactos.Add(new Contacto
            {
                IdUsuario = usuario.IdUsuario,
                TipoContacto = "Celular",
                Valor = dto.Telefono,
                EsPrincipal = true
            });
        _db.SaveChanges();

        var medico = new Medico { IdUsuario = usuario.IdUsuario, Activo = true };
        _db.Medicos.Add(medico);
        _db.SaveChanges();

        _db.ColegiosMedico.Add(new Models.ColegioMedico { IdMedico = medico.IdMedico, Numero = dto.ColegioMedico });
        _db.MedicoEspecialidades.Add(new MedicoEspecialidad { IdMedico = medico.IdMedico, IdEspecialidad = especialidad.IdEspecialidad });
        _db.Tarifas.Add(new Tarifa { IdMedico = medico.IdMedico, IdEspecialidad = especialidad.IdEspecialidad, Monto = 0, Activo = true });
        _db.SaveChanges();

        return ObtenerPorId(medico.IdMedico);
    }

    public MedicoResponseDto Actualizar(int id, MedicoUpdateDto dto)
    {
        var medico = _db.Medicos
            .Include(m => m.Usuario)
            .Include(m => m.ColegiosMedico)
            .Include(m => m.Tarifas)
            .FirstOrDefault(m => m.IdMedico == id)
            ?? throw new NotFoundException($"Médico con ID {id} no encontrado");

        if (_db.ColegiosMedico.Any(c => c.Numero == dto.ColegioMedico && c.IdMedico != id))
            throw new BusinessException($"Ya existe otro médico con el número de colegio {dto.ColegioMedico}");

        var especialidad = _db.Especialidades.FirstOrDefault(e => e.Nombre == dto.Especialidad)
            ?? new Especialidad { Nombre = dto.Especialidad, Activo = true };
        if (especialidad.IdEspecialidad == 0) { _db.Especialidades.Add(especialidad); _db.SaveChanges(); }

        medico.Usuario!.Nombres = dto.Nombre;
        medico.Usuario.Apellidos = dto.Apellido;
        medico.Usuario.FechaModificacion = DateTime.Now;
        medico.FechaModificacion = DateTime.Now;

        var colegio = medico.ColegiosMedico.FirstOrDefault(c => c.Activo);
        if (colegio != null) colegio.Numero = dto.ColegioMedico;
        else _db.ColegiosMedico.Add(new Models.ColegioMedico { IdMedico = medico.IdMedico, Numero = dto.ColegioMedico });

        if (!medico.Tarifas.Any(t => t.IdEspecialidad == especialidad.IdEspecialidad))
            _db.Tarifas.Add(new Tarifa { IdMedico = medico.IdMedico, IdEspecialidad = especialidad.IdEspecialidad, Monto = 0, Activo = true });

        var tel = _db.Contactos.FirstOrDefault(c => c.IdUsuario == medico.IdUsuario && c.TipoContacto == "Celular");
        if (tel != null) tel.Valor = dto.Telefono;
        else if (!string.IsNullOrEmpty(dto.Telefono))
            _db.Contactos.Add(new Contacto { IdUsuario = medico.IdUsuario, TipoContacto = "Celular", Valor = dto.Telefono });

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
        Especialidad = m.Tarifas.FirstOrDefault(t => t.Activo)?.Especialidad?.Nombre ?? string.Empty,
        ColegioMedico = m.ColegiosMedico.FirstOrDefault(c => c.Activo)?.Numero ?? string.Empty,
        Telefono = string.Empty
    };
}
