using ClinicaAPI.DTOs;
using ClinicaAPI.Exceptions;
using ClinicaAPI.Models;
using ClinicaAPI.Services.Interfaces;

namespace ClinicaAPI.Services;

public class MedicoService : IMedicoService
{
    private readonly List<Medico> _medicos = new();
    private int _nextId = 1;

    public MedicoService()
    {
        _medicos.Add(new Medico { Id = _nextId++, Nombre = "Carlos", Apellido = "López", Especialidad = "Cardiología", ColegioMedico = "CMP-12345", Telefono = "999888777" });
        _medicos.Add(new Medico { Id = _nextId++, Nombre = "Ana", Apellido = "Torres", Especialidad = "Pediatría", ColegioMedico = "CMP-67890", Telefono = "998877665" });
    }

    public IEnumerable<MedicoResponseDto> ObtenerTodos() =>
        _medicos.Select(MapToDto);

    public MedicoResponseDto ObtenerPorId(int id)
    {
        var medico = _medicos.FirstOrDefault(m => m.Id == id)
            ?? throw new NotFoundException($"Médico con ID {id} no encontrado");
        return MapToDto(medico);
    }

    public IEnumerable<MedicoResponseDto> ObtenerPorEspecialidad(string especialidad) =>
        _medicos
            .Where(m => m.Especialidad.Contains(especialidad, StringComparison.OrdinalIgnoreCase))
            .Select(MapToDto);

    public MedicoResponseDto Crear(MedicoCreateDto dto)
    {
        if (_medicos.Any(m => m.ColegioMedico == dto.ColegioMedico))
            throw new BusinessException($"Ya existe un médico con el número de colegio {dto.ColegioMedico}");

        var medico = new Medico
        {
            Id = _nextId++,
            Nombre = dto.Nombre,
            Apellido = dto.Apellido,
            Especialidad = dto.Especialidad,
            ColegioMedico = dto.ColegioMedico,
            Telefono = dto.Telefono
        };

        _medicos.Add(medico);
        return MapToDto(medico);
    }

    public MedicoResponseDto Actualizar(int id, MedicoUpdateDto dto)
    {
        var medico = _medicos.FirstOrDefault(m => m.Id == id)
            ?? throw new NotFoundException($"Médico con ID {id} no encontrado");

        if (_medicos.Any(m => m.ColegioMedico == dto.ColegioMedico && m.Id != id))
            throw new BusinessException($"Ya existe otro médico con el número de colegio {dto.ColegioMedico}");

        medico.Nombre = dto.Nombre;
        medico.Apellido = dto.Apellido;
        medico.Especialidad = dto.Especialidad;
        medico.ColegioMedico = dto.ColegioMedico;
        medico.Telefono = dto.Telefono;

        return MapToDto(medico);
    }

    public void Eliminar(int id)
    {
        var medico = _medicos.FirstOrDefault(m => m.Id == id)
            ?? throw new NotFoundException($"Médico con ID {id} no encontrado");
        _medicos.Remove(medico);
    }

    private static MedicoResponseDto MapToDto(Medico m) => new()
    {
        Id = m.Id,
        Nombre = m.Nombre,
        Apellido = m.Apellido,
        Especialidad = m.Especialidad,
        ColegioMedico = m.ColegioMedico,
        Telefono = m.Telefono
    };
}
