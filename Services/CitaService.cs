using ClinicaAPI.DTOs;
using ClinicaAPI.Exceptions;
using ClinicaAPI.Models;
using ClinicaAPI.Services.Interfaces;

namespace ClinicaAPI.Services;

public class CitaService : ICitaService
{
    private readonly List<Cita> _citas = new();
    private readonly IPacienteService _pacienteService;
    private readonly IMedicoService _medicoService;
    private int _nextId = 1;

    public CitaService(IPacienteService pacienteService, IMedicoService medicoService)
    {
        _pacienteService = pacienteService;
        _medicoService = medicoService;
    }

    public IEnumerable<CitaResponseDto> ObtenerTodas() =>
        _citas.Select(MapToDto);

    public CitaResponseDto ObtenerPorId(int id)
    {
        var cita = _citas.FirstOrDefault(c => c.Id == id)
            ?? throw new NotFoundException($"Cita con ID {id} no encontrada");
        return MapToDto(cita);
    }

    public IEnumerable<CitaResponseDto> ObtenerPorPaciente(int pacienteId)
    {
        _pacienteService.ObtenerPorId(pacienteId);
        return _citas.Where(c => c.PacienteId == pacienteId).Select(MapToDto);
    }

    public IEnumerable<CitaResponseDto> ObtenerPorMedico(int medicoId)
    {
        _medicoService.ObtenerPorId(medicoId);
        return _citas.Where(c => c.MedicoId == medicoId).Select(MapToDto);
    }

    public IEnumerable<CitaResponseDto> ObtenerPorEstado(EstadoCita estado) =>
        _citas.Where(c => c.Estado == estado).Select(MapToDto);

    public CitaResponseDto Crear(CitaCreateDto dto)
    {
        var paciente = _pacienteService.ObtenerPorId(dto.PacienteId);
        var medico = _medicoService.ObtenerPorId(dto.MedicoId);

        if (dto.FechaHora <= DateTime.Now)
            throw new BusinessException("La fecha de la cita debe ser futura");

        var conflicto = _citas.Any(c =>
            c.MedicoId == dto.MedicoId &&
            c.Estado != EstadoCita.Cancelada &&
            Math.Abs((c.FechaHora - dto.FechaHora).TotalMinutes) < 30);

        if (conflicto)
            throw new BusinessException("El médico ya tiene una cita en ese horario (margen de 30 minutos)");

        var cita = new Cita
        {
            Id = _nextId++,
            PacienteId = dto.PacienteId,
            MedicoId = dto.MedicoId,
            FechaHora = dto.FechaHora,
            Motivo = dto.Motivo,
            Observaciones = dto.Observaciones,
            Estado = EstadoCita.Pendiente
        };

        _citas.Add(cita);
        return MapToDto(cita);
    }

    public CitaResponseDto Actualizar(int id, CitaUpdateDto dto)
    {
        var cita = _citas.FirstOrDefault(c => c.Id == id)
            ?? throw new NotFoundException($"Cita con ID {id} no encontrada");

        if (cita.Estado == EstadoCita.Cancelada)
            throw new BusinessException("No se puede modificar una cita cancelada");

        _pacienteService.ObtenerPorId(dto.PacienteId);
        _medicoService.ObtenerPorId(dto.MedicoId);

        if (dto.FechaHora <= DateTime.Now)
            throw new BusinessException("La fecha de la cita debe ser futura");

        cita.PacienteId = dto.PacienteId;
        cita.MedicoId = dto.MedicoId;
        cita.FechaHora = dto.FechaHora;
        cita.Motivo = dto.Motivo;
        cita.Observaciones = dto.Observaciones;
        cita.Estado = dto.Estado;

        return MapToDto(cita);
    }

    public CitaResponseDto Cancelar(int id)
    {
        var cita = _citas.FirstOrDefault(c => c.Id == id)
            ?? throw new NotFoundException($"Cita con ID {id} no encontrada");

        if (cita.Estado == EstadoCita.Cancelada)
            throw new BusinessException("La cita ya está cancelada");

        if (cita.Estado == EstadoCita.Completada)
            throw new BusinessException("No se puede cancelar una cita que ya fue completada");

        cita.Estado = EstadoCita.Cancelada;
        return MapToDto(cita);
    }

    public void Eliminar(int id)
    {
        var cita = _citas.FirstOrDefault(c => c.Id == id)
            ?? throw new NotFoundException($"Cita con ID {id} no encontrada");
        _citas.Remove(cita);
    }

    private CitaResponseDto MapToDto(Cita c)
    {
        PacienteResponseDto? paciente = null;
        MedicoResponseDto? medico = null;

        try { paciente = _pacienteService.ObtenerPorId(c.PacienteId); } catch { }
        try { medico = _medicoService.ObtenerPorId(c.MedicoId); } catch { }

        return new CitaResponseDto
        {
            Id = c.Id,
            PacienteId = c.PacienteId,
            NombrePaciente = paciente != null ? $"{paciente.Nombre} {paciente.Apellido}" : "Desconocido",
            MedicoId = c.MedicoId,
            NombreMedico = medico != null ? $"Dr. {medico.Nombre} {medico.Apellido}" : "Desconocido",
            EspecialidadMedico = medico?.Especialidad ?? string.Empty,
            FechaHora = c.FechaHora,
            Motivo = c.Motivo,
            Estado = c.Estado,
            Observaciones = c.Observaciones
        };
    }
}
