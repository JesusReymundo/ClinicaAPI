using ClinicaAPI.Data;
using ClinicaAPI.DTOs;
using ClinicaAPI.Exceptions;
using ClinicaAPI.Models;
using ClinicaAPI.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace ClinicaAPI.Services;

public class CitaService : ICitaService
{
    private readonly ClinicaDbContext _db;

    public CitaService(ClinicaDbContext db) => _db = db;

    public IEnumerable<CitaResponseDto> ObtenerTodas() =>
        _db.Citas
            .Include(c => c.Paciente).ThenInclude(p => p!.Usuario)
            .Include(c => c.MedicoNav).ThenInclude(m => m!.Usuario)
            .Include(c => c.MedicoNav).ThenInclude(m => m!.EspecialidadNav)
            .AsNoTracking()
            .Select(MapToDto)
            .ToList();

    public CitaResponseDto ObtenerPorId(int id)
    {
        var cita = _db.Citas
            .Include(c => c.Paciente).ThenInclude(p => p!.Usuario)
            .Include(c => c.MedicoNav).ThenInclude(m => m!.Usuario)
            .Include(c => c.MedicoNav).ThenInclude(m => m!.EspecialidadNav)
            .AsNoTracking()
            .FirstOrDefault(c => c.Id == id)
            ?? throw new NotFoundException($"Cita con ID {id} no encontrada");
        return MapToDto(cita);
    }

    public IEnumerable<CitaResponseDto> ObtenerPorPaciente(int pacienteId)
    {
        if (!_db.Pacientes.Any(p => p.IdPaciente == pacienteId))
            throw new NotFoundException($"Paciente con ID {pacienteId} no encontrado");
        return _db.Citas
            .Include(c => c.Paciente).ThenInclude(p => p!.Usuario)
            .Include(c => c.MedicoNav).ThenInclude(m => m!.Usuario)
            .Include(c => c.MedicoNav).ThenInclude(m => m!.EspecialidadNav)
            .Where(c => c.PacienteId == pacienteId)
            .AsNoTracking()
            .Select(MapToDto)
            .ToList();
    }

    public IEnumerable<CitaResponseDto> ObtenerPorMedico(int medicoId)
    {
        if (!_db.Medicos.Any(m => m.IdMedico == medicoId))
            throw new NotFoundException($"Médico con ID {medicoId} no encontrado");
        return _db.Citas
            .Include(c => c.Paciente).ThenInclude(p => p!.Usuario)
            .Include(c => c.MedicoNav).ThenInclude(m => m!.Usuario)
            .Include(c => c.MedicoNav).ThenInclude(m => m!.EspecialidadNav)
            .Where(c => c.MedicoId == medicoId)
            .AsNoTracking()
            .Select(MapToDto)
            .ToList();
    }

    public IEnumerable<CitaResponseDto> ObtenerPorEstado(EstadoCita estado) =>
        _db.Citas
            .Include(c => c.Paciente).ThenInclude(p => p!.Usuario)
            .Include(c => c.MedicoNav).ThenInclude(m => m!.Usuario)
            .Include(c => c.MedicoNav).ThenInclude(m => m!.EspecialidadNav)
            .Where(c => c.IdEstado == (int)estado)
            .AsNoTracking()
            .Select(MapToDto)
            .ToList();

    public CitaResponseDto Crear(CitaCreateDto dto)
    {
        if (!_db.Pacientes.Any(p => p.IdPaciente == dto.PacienteId))
            throw new NotFoundException($"Paciente con ID {dto.PacienteId} no encontrado");
        if (!_db.Medicos.Any(m => m.IdMedico == dto.MedicoId))
            throw new NotFoundException($"Médico con ID {dto.MedicoId} no encontrado");
        if (dto.FechaHora <= DateTime.Now)
            throw new BusinessException("La fecha de la cita debe ser futura");

        var conflicto = _db.Citas.Any(c =>
            c.MedicoId == dto.MedicoId &&
            c.IdEstado != (int)EstadoCita.Cancelada &&
            Math.Abs(EF.Functions.DateDiffMinute(c.FechaHora, dto.FechaHora)) < 30);
        if (conflicto)
            throw new BusinessException("El médico ya tiene una cita en ese horario (margen de 30 minutos)");

        var cita = new Cita
        {
            PacienteId = dto.PacienteId,
            MedicoId = dto.MedicoId,
            FechaHora = dto.FechaHora,
            Motivo = dto.Motivo,
            Observaciones = dto.Observaciones,
            Estado = EstadoCita.Pendiente
        };
        _db.Citas.Add(cita);
        _db.SaveChanges();
        return ObtenerPorId(cita.Id);
    }

    public CitaResponseDto Actualizar(int id, CitaUpdateDto dto)
    {
        var cita = _db.Citas.FirstOrDefault(c => c.Id == id)
            ?? throw new NotFoundException($"Cita con ID {id} no encontrada");
        if (cita.Estado == EstadoCita.Cancelada)
            throw new BusinessException("No se puede modificar una cita cancelada");
        if (!_db.Pacientes.Any(p => p.IdPaciente == dto.PacienteId))
            throw new NotFoundException($"Paciente con ID {dto.PacienteId} no encontrado");
        if (!_db.Medicos.Any(m => m.IdMedico == dto.MedicoId))
            throw new NotFoundException($"Médico con ID {dto.MedicoId} no encontrado");
        if (dto.FechaHora <= DateTime.Now)
            throw new BusinessException("La fecha de la cita debe ser futura");

        cita.PacienteId = dto.PacienteId;
        cita.MedicoId = dto.MedicoId;
        cita.FechaHora = dto.FechaHora;
        cita.Motivo = dto.Motivo;
        cita.Observaciones = dto.Observaciones;
        cita.Estado = dto.Estado;
        cita.FechaModificacion = DateTime.Now;
        _db.SaveChanges();
        return ObtenerPorId(id);
    }

    public CitaResponseDto Cancelar(int id)
    {
        var cita = _db.Citas.FirstOrDefault(c => c.Id == id)
            ?? throw new NotFoundException($"Cita con ID {id} no encontrada");
        if (cita.Estado == EstadoCita.Cancelada)
            throw new BusinessException("La cita ya está cancelada");
        if (cita.Estado == EstadoCita.Completada)
            throw new BusinessException("No se puede cancelar una cita que ya fue completada");

        cita.Estado = EstadoCita.Cancelada;
        cita.FechaModificacion = DateTime.Now;
        _db.SaveChanges();
        return ObtenerPorId(id);
    }

    public void Eliminar(int id)
    {
        var cita = _db.Citas.FirstOrDefault(c => c.Id == id)
            ?? throw new NotFoundException($"Cita con ID {id} no encontrada");
        _db.Citas.Remove(cita);
        _db.SaveChanges();
    }

    private static CitaResponseDto MapToDto(Cita c) => new()
    {
        Id = c.Id,
        PacienteId = c.PacienteId,
        NombrePaciente = c.Paciente?.Usuario != null
            ? $"{c.Paciente.Usuario.Nombres} {c.Paciente.Usuario.Apellidos}" : "Desconocido",
        MedicoId = c.MedicoId,
        NombreMedico = c.MedicoNav?.Usuario != null
            ? $"Dr. {c.MedicoNav.Usuario.Nombres} {c.MedicoNav.Usuario.Apellidos}" : "Desconocido",
        EspecialidadMedico = c.MedicoNav?.EspecialidadNav?.Nombre ?? string.Empty,
        FechaHora = c.FechaHora,
        Motivo = c.Motivo,
        Estado = c.Estado,
        Observaciones = c.Observaciones
    };
}
